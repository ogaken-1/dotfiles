# eunomia public API: { mkClaudeConfig, platforms }.
{ pkgs }:
let
  inherit (pkgs) lib;
  inherit (import ./facts.nix { inherit pkgs; }) extractFacts;
  inherit (import ./prompts.nix { inherit pkgs; }) renderPrompts;
  inherit (import ./validate.nix { inherit pkgs; }) validateOrigins;
  inherit (import ./profile.nix { inherit pkgs; })
    profileFacts
    appendCustomAgentScopes
    ;

  checksDl = ../checks.dl;

  # platforms/<name>.nix -> { "<name>" = <profile>; }
  platforms =
    builtins.readDir ../platforms
    |> lib.filterAttrs (name: type: type == "regular" && lib.hasSuffix ".nix" name)
    |> lib.mapAttrs' (
      name: _: lib.nameValuePair (lib.removeSuffix ".nix" name) (import (../platforms + "/${name}"))
    );

  # Souffle over a facts directory -> human-readable report (empty when nothing is wrong).
  # The report derivation does not fail on findings, so that tests can compare its text (it still
  # cannot be built when the origins are invalid: the facts depend on the schema validation).
  mkRefsReport =
    facts:
    pkgs.runCommand "eunomia-refs-report"
      {
        nativeBuildInputs = [
          pkgs.souffle
          pkgs.gawk
          pkgs.coreutils
        ];
      }
      ''
        export LC_ALL=C
        mkdir out
        souffle -F ${facts} -D out ${checksDl}
        {
          awk -F '\t' '{ printf "参照切れ: %s -> %s (%s, 種別: %s)\n", $1, $3, $4, $2 }' out/broken_ref.csv
          awk -F '\t' '{
            if ($3 == "-") s = "後継なし"; else s = "後継: " $3
            printf "削除済み（%s）: %s -> %s\n", s, $1, $2
          }' out/removed_ref.csv
          awk -F '\t' '{ printf "規範の衝突: %s <-> %s\n", $1, $2 }' out/conflict.csv
          awk -F '\t' '{ printf "未注釈の参照: %s -> %s (%s)\n", $1, $2, $3 }' out/unannotated_ref.csv
        } | sort > $out

        # `nix build` shows only the last 25 lines of a failed build log, so the counts and the
        # pointer to the full text come last. Nothing is appended when nothing is wrong.
        broken=$(wc -l < out/broken_ref.csv)
        removed=$(wc -l < out/removed_ref.csv)
        conflict=$(wc -l < out/conflict.csv)
        unannotated=$(wc -l < out/unannotated_ref.csv)
        total=$((broken + removed + conflict + unannotated))
        if [ "$total" -gt 0 ]; then
          printf '要約: 参照切れ %d 件、削除済み %d 件、規範の衝突 %d 件、未注釈の参照 %d 件（合計 %d 件）\n' \
            "$broken" "$removed" "$conflict" "$unannotated" "$total" >> $out
          echo '全文は nix log <drv> か、mkClaudeConfig の refsReport をビルドして見る' >> $out
        fi
      '';

  mkClaudeConfig =
    {
      src,
      platform,
      mcp ? { },
      permissionsAllow ? [ ],
      hooks ? { },
      extra ? { },
      extraFrontMatter ? { },
      # "user" writes memory/user.md to ~/.claude/CLAUDE.md; null leaves CLAUDE.md alone.
      # Project memory is generated (memory/project.md) but never placed by home-manager.
      memory ? "user",
      # true: homeManagerModule places verifiedPrompts, so an origin that fails a check cannot be
      # placed. false: it places prompts as they are (for a temporary bypass).
      enforceChecks ? true,
    }:
    if memory != null && memory != "user" then
      throw "eunomia: mkClaudeConfig: memory must be \"user\" or null (got ${builtins.toJSON memory})"
    else
    let
      # null means "not placed": such names are neither copied nor defined.
      extraPlaced = extra |> lib.mapAttrs (_: lib.filterAttrs (_: v: v != null));

      # extra.<kind>.<n> = <path> is copied to prompts: skills as a directory, agents and commands
      # as Markdown files.
      extraCopies =
        (lib.mapAttrsToList (name: path: {
          kind = "skill";
          rel = "skills/${name}";
          inherit name path;
        }) (extraPlaced.skills or { }))
        ++ (lib.mapAttrsToList (name: path: {
          kind = "agent";
          rel = "agents/${name}.md";
          inherit name path;
        }) (extraPlaced.agents or { }))
        ++ (lib.mapAttrsToList (name: path: {
          kind = "command";
          rel = "commands/${name}.md";
          inherit name path;
        }) (extraPlaced.commands or { }));

      rendered = renderPrompts { inherit src extraFrontMatter; };

      prompts =
        pkgs.runCommand "eunomia-prompts-merged" { }
          ''
            mkdir -p $out
            cp -r --no-preserve=mode ${rendered}/. $out/
            mkdir -p $out/skills $out/agents $out/commands
            ${lib.concatMapStringsSep "\n" (c: ''
              if [ -e "$out"/${lib.escapeShellArg c.rel} ]; then
                echo "extra ${c.kind} '${c.name}' collides with a ${c.kind} produced from src" >&2
                exit 1
              fi
              cp -r --no-preserve=mode ${c.path} "$out"/${lib.escapeShellArg c.rel}
            '') extraCopies}
            ${lib.optionalString (memory != null) ''
              if [ ! -f "$out/memory/${memory}.md" ]; then
                echo "memory/${memory}.md was not produced: add memory/${memory}.xml to src or pass memory = null" >&2
                exit 1
              fi
            ''}
          '';

      baseFacts = extractFacts {
        inherit src;
        # Tool names an origin must not write without cc:useTool (mcp__ names need no list).
        toolNames = platform.tools ++ builtins.attrNames platform.removed;
        ambiguousToolNames = platform.ambiguousToolNames or [ ];
        extraFacts = profileFacts {
          inherit
            platform
            mcp
            permissionsAllow
            hooks
            ;
          extraDefined = extraPlaced |> lib.mapAttrs (_: builtins.attrNames);
        };
      };

      facts = appendCustomAgentScopes {
        inherit platform;
        facts = baseFacts;
      };

      refsReport = mkRefsReport facts;

      # Fails with the report (counts last, indented) when it is not empty. Shared by the refs
      # check and verifiedPrompts, so that both print the same text.
      refsGate = ''
        if [ -s ${refsReport} ]; then
          echo "eunomia: reference/conflict check failed:" >&2
          while IFS= read -r line; do echo "  $line" >&2; done < ${refsReport}
          exit 1
        fi
      '';

      checks = {
        # The XSD validation shared by facts and prompts (built once).
        schema = validateOrigins { inherit src; };

        # Generating the prompts is itself the check.
        inherit prompts;

        refs = pkgs.runCommand "eunomia-refs-check" { } ''
          ${refsGate}
          touch $out
        '';
      };

      # prompts that passed every check. It depends on schema, prompts and the refs report (through
      # the same gate as the refs check, not through the refs derivation, so that the failure is
      # reported by this derivation with the report in its own log). Nothing is evaluated by
      # building: referring to this derivation (e.g. reading an option value) is free.
      verifiedPrompts =
        pkgs.runCommand "eunomia-prompts-verified" { }
          ''
            test -e ${checks.schema}
            test -e ${checks.prompts}
            ${refsGate}
            ln -s ${prompts} $out
          '';

      # What home-manager places: the verified prompts, unless enforceChecks is false.
      placed = if enforceChecks then verifiedPrompts else prompts;
    in
    {
      inherit
        prompts
        verifiedPrompts
        facts
        refsReport
        checks
        ;

      homeManagerModule =
        { config, lib, ... }:
        {
          programs.claude-code = {
            skills = "${placed}/skills";
            agentsDir = "${placed}/agents";
            commandsDir = "${placed}/commands";
          };
          # `programs.claude-code.context` (formerly memory.source) takes a Nix path literal; a
          # store path string would be written into CLAUDE.md as text. home.file takes strings.
          home.file = lib.mkIf (memory != null) {
            "${config.programs.claude-code.configDir}/CLAUDE.md".source = "${placed}/memory/${memory}.md";
          };
        };
    };
in
{
  inherit mkClaudeConfig platforms;
}
