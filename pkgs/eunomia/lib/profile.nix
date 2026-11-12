# Platform profile + declarations -> Souffle facts directory (the relations of checks.dl).
# Facts are assembled as strings at evaluation time (no IFD).
{ pkgs }:
let
  inherit (pkgs) lib;

  relations = import ./relations.nix;

  # Label stored in the `file` column of profile-derived `defined` rows.
  platformLabel = platform: "claude-code-${platform.claudeCode}";

  row = cols: lib.concatStringsSep "\t" cols;

  # Plural attribute names of `extraDefined` / `extra` -> entity kind.
  extraKinds = {
    skills = "skill";
    agents = "agent";
    commands = "command";
    tools = "tool";
    memory = "memory";
  };

  # Hook events whose matcher is a tool name. Other events (SessionStart etc.) match other things.
  toolMatcherEvents = [
    "PreToolUse"
    "PostToolUse"
    "PostToolUseFailure"
    "PermissionRequest"
  ];

  # A string that can be interpreted as a single tool name. Wildcards and regex syntax do not match.
  # "mcp__<server>" (server-level permission, no tool part) is not a tool name either.
  isToolName =
    s:
    builtins.match "[A-Za-z][A-Za-z0-9_-]*" s != null
    && !(lib.hasPrefix "mcp__" s && builtins.match "mcp__.+__.+" s == null);

  # `Bash(git status *)` -> `Bash`; `mcp__x__y` -> itself.
  permissionToolName =
    rule:
    let
      m = builtins.match "([^(]*)\\(.*" rule;
    in
    lib.strings.trim (if m == null then rule else builtins.head m);

  # `Skill(execute)` -> { kind = "skill"; name = "execute"; }; `Agent(Explore)` -> { kind = "agent"; ... }.
  # Only an argument that is a plain name is a reference: a wildcard, a colon ("foo:*") or a space
  # ("foo *") makes it a pattern, which is not checked. Other rules give null.
  permissionArgRef =
    rule:
    let
      m = builtins.match "(Skill|Agent)\\(([A-Za-z0-9][A-Za-z0-9_.-]*)\\)" (lib.strings.trim rule);
    in
    if m == null then
      null
    else
      {
        kind = if builtins.elemAt m 0 == "Skill" then "skill" else "agent";
        name = builtins.elemAt m 1;
      };

  hookMatcherNames =
    hooks:
    toolMatcherEvents
    |> lib.concatMap (event: hooks.${event} or [ ])
    |> lib.concatMap (entry: lib.splitString "|" (entry.matcher or ""))
    |> map lib.strings.trim;

  mcpToolNames =
    naming: mcp:
    mcp
    |> lib.mapAttrsToList (
      server: decl:
      map (
        tool:
        if decl.plugin or null != null then
          naming.plugin decl.plugin server tool
        else if decl.connector or false then
          naming.connector server tool
        else
          naming.direct server tool
      ) decl.tools
    )
    |> lib.concatLists;

  linesOf = lines: lib.concatMapStrings (l: l + "\n") (lib.unique (lib.sort (a: b: a < b) lines));
in
{
  inherit relations platformLabel;

  # Custom agents' scope_parent rows are not made here: see appendCustomAgentScopes.
  profileFacts =
    {
      platform,
      mcp ? { },
      permissionsAllow ? [ ],
      hooks ? { },
      extraDefined ? { },
    }:
    let
      label = platformLabel platform;
      tools = platform.tools ++ mcpToolNames platform.mcpNaming mcp;
      agentNames = (builtins.attrNames platform.agents) ++ [ "main" ];

      defined =
        (map (n: row [ "tool" "tool:${n}" label ]) tools)
        ++ (map (n: row [ "agent" "agent:${n}" label ]) agentNames)
        ++ (map (n: row [ "skill" "skill:${n}" label ]) (platform.builtinSkills or [ ]))
        # Platform flag, read by checks.dl (kind "flag"): custom commands also count as skills.
        ++ (lib.optional (platform.commandsAreSkills or false) (row [ "flag" "commandsAreSkills" label ]))
        ++ (
          extraDefined
          |> lib.mapAttrsToList (
            plural: names:
            let
              kind = extraKinds.${plural} or (throw "eunomia: unknown extraDefined kind '${plural}'");
            in
            map (n: row [ kind "${kind}:${n}" "extra" ]) names
          )
          |> lib.concatLists
        );

      memoryParents =
        scope: flags:
        (lib.optional flags.userMemory (row [ scope "scope:memory:user" ]))
        ++ (lib.optional flags.projectMemory (row [ scope "scope:memory:project" ]));

      # null (not measured) is treated as inheriting.
      builtinFlags = v: if v == null then { userMemory = true; projectMemory = true; } else v;

      scopeParent =
        (memoryParents "scope:session" {
          userMemory = true;
          projectMemory = true;
        })
        ++ (
          platform.agents
          |> lib.mapAttrsToList (n: v: memoryParents "scope:agent:${n}" (builtinFlags v))
          |> lib.concatLists
        );

      requires = map (r: row [ "tool:${r.act}" "tool:${r.pre}" ]) platform.requires;

      removed = platform.removed |> lib.mapAttrsToList (n: succ: row [ "tool:${n}" (if succ == null then "-" else "tool:${succ}") ]);

      mkRef =
        src: names:
        names |> lib.filter isToolName |> map (n: row [ src "tool" "tool:${n}" "settings" ]);

      # The arguments of Skill(...) / Agent(...) refer to skills / agents (the tool part is a tool ref).
      permissionArgRefs =
        permissionsAllow
        |> map permissionArgRef
        |> lib.filter (r: r != null)
        |> map (r: row [ "settings:permissions.allow" r.kind "${r.kind}:${r.name}" "settings" ]);

      ref =
        (mkRef "settings:permissions.allow" (map permissionToolName permissionsAllow))
        ++ permissionArgRefs
        ++ (mkRef "settings:hooks" (hookMatcherNames hooks));

      contents = {
        inherit defined requires removed ref;
        scope_parent = scopeParent;
        norm = [ ];
        override = [ ];
        # Mentions come from the origins only.
        mention = [ ];
      };
    in
    relations
    |> map (rel: lib.nameValuePair "${rel}.facts" (pkgs.writeText "eunomia-profile-${rel}.facts" (linesOf contents.${rel})))
    |> lib.listToAttrs
    |> pkgs.linkFarm "eunomia-profile-facts";

  # Adds scope_parent rows for custom agents, found from the `defined` rows of the extracted facts
  # (agents whose file column is not the platform label and not agent:main). This avoids IFD:
  # the agent list is only known after src has been processed.
  appendCustomAgentScopes =
    { platform, facts }:
    let
      label = platformLabel platform;
      parents =
        (lib.optional platform.customAgents.userMemory "scope:memory:user")
        ++ (lib.optional platform.customAgents.projectMemory "scope:memory:project");
    in
    pkgs.runCommand "eunomia-facts-final" { nativeBuildInputs = [ pkgs.gawk pkgs.coreutils ]; } ''
      export LC_ALL=C
      mkdir -p $out
      for rel in ${lib.escapeShellArgs relations}; do
        cp ${facts}/$rel.facts $out/$rel.facts
        chmod u+w $out/$rel.facts
      done
      awk -F '\t' -v label=${lib.escapeShellArg label} -v parents=${lib.escapeShellArg (lib.concatStringsSep " " parents)} '
        BEGIN { n = split(parents, p, " ") }
        $1 == "agent" && $2 != "agent:main" && $3 != label {
          for (i = 1; i <= n; i++) print "scope:" $2 "\t" p[i]
        }
      ' ${facts}/defined.facts >> $out/scope_parent.facts
      sort -u $out/scope_parent.facts -o $out/scope_parent.facts
    '';
}
