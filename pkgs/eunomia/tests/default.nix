# Regression tests for checks.dl.
# Each directory under ./fixtures is one case: its *.facts are fed to Souffle and
# the resulting CSVs are compared with ./expected/<case>/*.csv (order-insensitive).
{ pkgs, inputs ? null }:
let
  inherit (pkgs) lib;

  checksDl = ../checks.dl;
  outputs = [
    "broken_ref"
    "removed_ref"
    "conflict"
    "unannotated_ref"
  ];

  cases = builtins.readDir ./fixtures |> lib.filterAttrs (_: type: type == "directory") |> builtins.attrNames;

  mkCase =
    name:
    pkgs.runCommand "eunomia-rules-${name}"
      {
        nativeBuildInputs = [
          pkgs.souffle
          pkgs.diffutils
        ];
      }
      ''
        # A fixture may leave out the facts files that are empty for the case.
        cp -r ${./fixtures + "/${name}"} in
        chmod -R u+w in
        for rel in ${lib.escapeShellArgs relations}; do
          [ -f "in/$rel.facts" ] || : > "in/$rel.facts"
        done
        mkdir out
        souffle -F in -D out ${checksDl}

        status=0
        for rel in ${lib.escapeShellArgs outputs}; do
          if [ ! -f "out/$rel.csv" ]; then
            echo "case ${name}: souffle did not produce $rel.csv" >&2
            status=1
            continue
          fi
          # Sort both sides so that row order does not matter; empty files sort to empty.
          sort "out/$rel.csv" > "actual.$rel"
          # Likewise, an expected file that is absent means "no rows".
          if [ -f ${./expected + "/${name}"}/"$rel.csv" ]; then
            sort ${./expected + "/${name}"}/"$rel.csv" > "expected.$rel"
          else
            : > "expected.$rel"
          fi
          if ! diff -u "expected.$rel" "actual.$rel"; then
            echo "case ${name}: $rel.csv differs from expected (see diff above)" >&2
            status=1
          fi
        done
        [ "$status" -eq 0 ] || exit 1
        touch $out
      '';

  perCase = lib.genAttrs cases mkCase;

  # Schema tests: every schema/valid/*.xml must validate against cc.xsd and
  # every schema/invalid/*.xml must be rejected.
  schema =
    pkgs.runCommand "eunomia-schema"
      {
        nativeBuildInputs = [ pkgs.libxml2 ];
      }
      ''
        status=0
        for f in ${./schema/valid}/*.xml; do
          if ! xmllint --noout --nonet --schema ${../schema/cc.xsd} "$f" 2> err; then
            echo "FAIL (expected valid): $(basename "$f")" >&2
            cat err >&2
            status=1
          fi
        done
        for f in ${./schema/invalid}/*.xml; do
          if xmllint --noout --nonet --schema ${../schema/cc.xsd} "$f" 2> err; then
            echo "FAIL (expected invalid): $(basename "$f")" >&2
            status=1
          fi
        done
        [ "$status" -eq 0 ] || exit 1
        touch $out
      '';

  # ===== Fact extraction (to-facts.xsl / lib/facts.nix) =====
  inherit (import ../lib/facts.nix { inherit pkgs; }) extractFacts;

  relations = import ../lib/relations.nix;

  factCases = builtins.readDir ./facts |> lib.filterAttrs (_: type: type == "directory") |> builtins.attrNames;

  mkFactsCase =
    name:
    let
      # A case may carry a hand-written profile (`profile/defined.facts` ...), as the platform
      # profile does in production: built-in skills / agents and the commandsAreSkills flag.
      profileDir = ./facts + "/${name}/profile";
      extracted = extractFacts (
        {
          src = ./facts + "/${name}/src";
          toolNames = realProfileToolNames;
          inherit (realProfile) ambiguousToolNames;
        }
        // lib.optionalAttrs (builtins.pathExists profileDir) { extraFacts = profileDir; }
      );
    in
    pkgs.runCommand "eunomia-facts-${name}" { nativeBuildInputs = [ pkgs.diffutils ]; } ''
      status=0
      for rel in ${lib.escapeShellArgs relations}; do
        if [ ! -f "${extracted}/$rel.facts" ]; then
          echo "case ${name}: $rel.facts was not produced" >&2
          status=1
          continue
        fi
        # Sort both sides so that row order does not matter.
        sort "${extracted}/$rel.facts" > "actual.$rel"
        sort ${./facts + "/${name}/expected"}/"$rel.facts" > "expected.$rel"
        if ! diff -u "expected.$rel" "actual.$rel"; then
          echo "case ${name}: $rel.facts differs from expected (see diff above)" >&2
          status=1
        fi
      done
      [ "$status" -eq 0 ] || exit 1
      touch $out
    '';

  facts = pkgs.linkFarm "eunomia-facts-tests" (lib.genAttrs factCases mkFactsCase);

  # xsl-*.xml pass the XSD but must be rejected by to-facts.xsl (with the file name in the
  # message); schema-*.xml must be rejected by the XSD. The kind and name that the path would give
  # (skills/s.xml) are passed as parameters. Key / name / level mismatches are rejected earlier, by
  # validateOrigins (see originErrors).
  factsErrors =
    pkgs.runCommand "eunomia-facts-errors"
      {
        nativeBuildInputs = [
          pkgs.libxml2
          pkgs.libxslt
        ];
      }
      ''
        status=0
        for f in ${./facts-errors}/xsl-*.xml; do
          n=$(basename "$f")
          if ! xmllint --noout --nonet --schema ${../schema/cc.xsd} "$f" 2> err; then
            echo "FAIL (premise: $n should pass the XSD)" >&2
            cat err >&2
            status=1
          fi
          if xsltproc --stringparam file "$n" --stringparam kind skill --stringparam name s ${../xslt/to-facts.xsl} "$f" > out 2> err; then
            echo "FAIL (expected to-facts.xsl to reject): $n" >&2
            status=1
          elif ! grep -q "$n" err; then
            echo "FAIL (message lacks the file name): $n" >&2
            cat err >&2
            status=1
          fi
        done
        for f in ${./facts-errors}/schema-*.xml; do
          if xmllint --noout --nonet --schema ${../schema/cc.xsd} "$f" 2> err; then
            echo "FAIL (expected XSD to reject): $(basename "$f")" >&2
            status=1
          fi
        done
        [ "$status" -eq 0 ] || exit 1
        touch $out
      '';

  # Origin XML plus hand-written profile facts, merged and run through checks.dl.
  e2e =
    let
      merged = extractFacts {
        src = ./e2e/src;
        extraFacts = ./e2e/profile;
      };
    in
    pkgs.runCommand "eunomia-e2e"
      {
        nativeBuildInputs = [
          pkgs.souffle
          pkgs.diffutils
        ];
      }
      ''
        mkdir out
        souffle -F ${merged} -D out ${checksDl}
        status=0
        for rel in broken_ref removed_ref unannotated_ref; do
          if [ -s "out/$rel.csv" ]; then
            echo "expected no $rel rows:" >&2
            cat "out/$rel.csv" >&2
            status=1
          fi
        done
        if ! diff -u ${./e2e/expected-conflict.csv} out/conflict.csv; then
          echo "conflict.csv differs from expected" >&2
          status=1
        fi
        [ "$status" -eq 0 ] || exit 1
        touch $out
      '';

  # ===== Prompt generation (to-prompt.xsl / to-frontmatter.xsl / lib/prompts.nix) =====
  # Rendered output must match ./prompts/expected byte for byte (diff -r also catches missing or extra files).
  prompts =
    let
      inherit (import ../lib/prompts.nix { inherit pkgs; }) renderPrompts;
      rendered = renderPrompts {
        src = ./prompts/src;
        extraFrontMatter."agent:sample-agent".hooks.PreToolUse = [
          {
            matcher = "Bash";
            hooks = [
              {
                type = "command";
                command = "/nix/store/fake-hook/bin/hook";
              }
            ];
          }
        ];
      };
    in
    pkgs.runCommand "eunomia-prompts" { nativeBuildInputs = [ pkgs.diffutils ]; } ''
      if ! diff -r ${./prompts/expected} ${rendered}; then
        echo "rendered prompts differ from tests/prompts/expected (see diff above)" >&2
        exit 1
      fi
      touch $out
    '';

  # Runs the build script of a runCommand derivation directly and expects a non-zero exit whose
  # stderr contains `pattern` (a failing build cannot be an expectation by itself).
  expectBuildFailure =
    name: drv: pattern:
    pkgs.runCommand "eunomia-fail-${name}"
      {
        nativeBuildInputs = (drv.nativeBuildInputs or [ ]) ++ [ pkgs.gnugrep ];
      }
      ''
        if out=$PWD/target bash -e ${pkgs.writeText "eunomia-fail-${name}-script" drv.buildCommand} 2> err; then
          echo "FAIL: expected the build script to fail" >&2
          exit 1
        fi
        if ! grep -qF -- ${lib.escapeShellArg pattern} err; then
          echo "FAIL: stderr lacks '${pattern}'" >&2
          cat err >&2
          exit 1
        fi
        touch $out
      '';

  # extraFrontMatter values that contain both ' and " must render (extraYaml used to travel via
  # xsltproc --stringparam, which rejects such strings).
  promptsQuoting =
    let
      inherit (import ../lib/prompts.nix { inherit pkgs; }) renderPrompts;
      rendered = renderPrompts {
        src = ./prompts/src;
        extraFrontMatter."agent:sample-agent".hooks.PreToolUse = [
          {
            matcher = "Bash";
            hooks = [
              {
                type = "command";
                command = "bash -c 'foo'";
              }
            ];
          }
        ];
      };
    in
    pkgs.runCommand "eunomia-prompts-quoting" { } ''
      grep -qxF '        - command: "bash -c '"'"'foo'"'"'"' ${rendered}/agents/sample-agent.md
      touch $out
    '';

  # An extraFrontMatter key that the origin already defines would put the key into the YAML twice.
  promptsDuplicateKey =
    let
      inherit (import ../lib/prompts.nix { inherit pkgs; }) renderPrompts;
    in
    expectBuildFailure "duplicate-key"
      (renderPrompts {
        src = ./prompts/src;
        extraFrontMatter."agent:sample-agent".tools = [ "Read" ];
      })
      "agent:sample-agent: key 'tools' is defined by both the origin and extraFrontMatter";

  # toYaml output read back by a YAML parser must equal the original value (control characters,
  # null, empty containers included).
  yamlRoundTrip =
    let
      inherit (import ../lib/yaml.nix) toYaml;
      value = {
        command = "set -e\nfoo\tbar\r\\ \"q\" 'x'";
        nothing = null;
        count = 3;
        ratio = 1.5;
        flag = true;
        emptyAttrs = { };
        emptyList = [ ];
        names = [
          "a"
          "b\nc"
        ];
        listWithEmpty = [
          { }
          { a = "x"; }
        ];
        onlyEmpty = [ { } ];
        hooks.PreToolUse = [
          {
            matcher = "Bash";
            hooks = [
              {
                type = "command";
                command = "set -e\nfoo";
              }
              { }
            ];
          }
          { }
        ];
      };
    in
    pkgs.runCommand "eunomia-yaml-roundtrip"
      {
        nativeBuildInputs = [
          pkgs.yq-go
          pkgs.jq
          pkgs.diffutils
        ];
      }
      ''
        yq -o=json '.' ${pkgs.writeText "eunomia-roundtrip.yaml" (toYaml value)} | jq -S . > actual.json
        echo ${lib.escapeShellArg (builtins.toJSON value)} | jq -S . > expected.json
        diff -u expected.json actual.json
        touch $out
      '';

  # ===== Platform profile -> facts (lib/profile.nix) =====
  profile =
    let
      inherit (import ../lib/profile.nix { inherit pkgs; }) profileFacts appendCustomAgentScopes;
      realPlatform = (import ../lib { inherit pkgs; }).platforms."claude-code-2.1.317";
      small = {
        claudeCode = "9.9.9";
        tools = [
          "Read"
          "Bash"
          "EnterPlanMode"
          "ExitPlanMode"
          "Agent"
        ];
        removed = {
          TodoWrite = null;
          Task = "Agent";
        };
        requires = [
          {
            act = "ExitPlanMode";
            pre = "EnterPlanMode";
          }
        ];
        inherit (realPlatform) mcpNaming;
        builtinSkills = [
          "code-review"
          "simplify"
        ];
        commandsAreSkills = true;
        agents = {
          Explore = {
            userMemory = false;
            projectMemory = false;
          };
          general-purpose = {
            userMemory = true;
            projectMemory = false;
          };
          Plan = null;
        };
        customAgents = {
          userMemory = true;
          projectMemory = false;
        };
      };
      actual = profileFacts {
        platform = small;
        mcp = {
          serena = {
            plugin = "hm";
            tools = [ "find_symbol" ];
          };
          Notion = {
            connector = true;
            tools = [ "notion-search" ];
          };
          fs.tools = [ "read" ];
        };
        permissionsAllow = [
          "Read"
          "Bash(git status *)"
          "mcp__plugin_hm_serena__find_symbol"
          "mcp__plugin_hm_context7__*" # wildcard: not checked
          "mcp__plugin_hm_serena" # server-level: not checked
          "TaskOutput"
          "WebFetch(domain:example.com)"
          # The argument of Skill(...) / Agent(...) is a skill / agent reference.
          "Skill(execute)"
          "Skill(plan-workflow)"
          "Skill( spaced )" # spaces: not checked
          "Agent(Explore)"
          "Skill(foo:*)" # wildcard / colon: argument not checked
          "Skill(foo *)"
          "Skill(*)"
          "Skill"
          "Agent(a b)"
          "Bash(Skill(x))" # not a Skill rule
        ];
        hooks = {
          PreToolUse = [
            {
              matcher = "Bash|TaskOutput";
              hooks = [ ];
            }
            {
              matcher = "Edit.*"; # regex: not checked
              hooks = [ ];
            }
            { matcher = ""; }
          ];
          PostToolUse = [ { hooks = [ ]; } ];
          SessionStart = [ { matcher = "startup"; } ]; # not a tool matcher
        };
        extraDefined.skills = [ "slide-generating" ];
      };
      # Custom agents' scopes go through the production path (appendCustomAgentScopes): an agent
      # from the origin (a `defined` row whose file column is not the platform label) is added.
      withWorker = pkgs.runCommand "eunomia-profile-with-worker" { } ''
        mkdir $out
        cp ${actual}/*.facts $out/
        chmod u+w $out/*.facts
        printf 'agent\tagent:worker\tagents/worker.xml\n' >> $out/defined.facts
      '';
      final = appendCustomAgentScopes {
        platform = small;
        facts = withWorker;
      };
      # commandsAreSkills = false (or absent) emits no flag row.
      flagOff = profileFacts { platform = small // { commandsAreSkills = false; }; };
    in
    pkgs.runCommand "eunomia-profile" { nativeBuildInputs = [ pkgs.diffutils ]; } ''
      status=0
      if grep -q commandsAreSkills ${flagOff}/defined.facts; then
        echo "profile: commandsAreSkills = false must not emit a flag row" >&2
        status=1
      fi
      for rel in ${lib.escapeShellArgs relations}; do
        sort ${actual}/"$rel.facts" > "actual.$rel"
        sort ${./profile/expected}/"$rel.facts" > "expected.$rel"
        if ! diff -u "expected.$rel" "actual.$rel"; then
          echo "profile: $rel.facts differs from expected (see diff above)" >&2
          status=1
        fi
      done
      # Everything but scope_parent is unchanged by the custom-agent step.
      for rel in ${lib.escapeShellArgs (lib.remove "scope_parent" relations)}; do
        if ! diff -u <(sort ${withWorker}/"$rel.facts") <(sort ${final}/"$rel.facts"); then
          echo "profile: custom-agent step changed $rel.facts" >&2
          status=1
        fi
      done
      # The profile's scope_parent plus the custom agent (userMemory only in `small`).
      { cat ${./profile/expected}/scope_parent.facts; printf 'scope:agent:worker\tscope:memory:user\n'; } | sort > expected.scope_parent
      if ! diff -u expected.scope_parent <(sort ${final}/scope_parent.facts); then
        echo "profile: custom agent scope_parent rows differ (see diff above)" >&2
        status=1
      fi
      [ "$status" -eq 0 ] || exit 1
      touch $out
    '';

  # A src root whose path contains whitespace (origin paths below the root follow the
  # <kinddir>/<name>.xml convention, so the root is the only place for a space): validation, fact
  # extraction and generation all work. The root is built, because a store path cannot hold a space.
  spacesSrc = "${
    pkgs.runCommand "eunomia-spaces-src" { } ''
      mkdir -p "$out/src dir"
      cp -r ${./spaces/src}/. "$out/src dir/"
    ''
  }/src dir";

  spacesConfig = mkClaudeConfig {
    src = spacesSrc;
    platform = realProfile;
    memory = null;
  };

  spaces = pkgs.runCommand "eunomia-spaces" { } ''
    # checks.schema / checks.prompts are the shared validation and the generated prompts.
    test -e ${spacesConfig.checks.schema}
    test -e ${spacesConfig.checks.prompts}
    test -f ${spacesConfig.prompts}/skills/spaced/SKILL.md
    test -f ${spacesConfig.prompts}/skills/nested/SKILL.md
    grep -qxF 'name: "spaced"' ${spacesConfig.prompts}/skills/spaced/SKILL.md
    grep -qxF "$(printf 'skill\tskill:spaced\tskills/spaced.xml')" ${spacesConfig.facts}/defined.facts
    grep -qxF "$(printf 'skill\tskill:nested\tskills/nested.xml')" ${spacesConfig.facts}/defined.facts
    test ! -s ${spacesConfig.refsReport}
    touch $out
  '';

  # ===== mkClaudeConfig (lib/default.nix) =====
  inherit (import ../lib { inherit pkgs; }) mkClaudeConfig platforms;

  realProfile = platforms."claude-code-2.1.317";

  # Every name that a tool mention is looked up by: defined tools and removed ones.
  realProfileToolNames = realProfile.tools ++ builtins.attrNames realProfile.removed;

  okConfig = mkClaudeConfig {
    src = ./mkclaude/ok-src;
    platform = realProfile;
    mcp.serena = {
      plugin = "hm";
      tools = [ "find_symbol" ];
    };
    permissionsAllow = [
      "Read"
      "Bash(git status *)"
      "mcp__plugin_hm_serena__find_symbol"
      "mcp__plugin_hm_serena__*"
    ];
    hooks.PreToolUse = [
      {
        matcher = "Bash|Edit";
        hooks = [ ];
      }
    ];
    extra.skills.slide-generating = ./mkclaude/slide-skill;
  };

  mkClaudeConfigOk = pkgs.linkFarm "eunomia-mkclaudeconfig-ok" (
    okConfig.checks
    // {
      # The extra skill is copied next to the skills generated from src.
      layout = pkgs.runCommand "eunomia-mkclaudeconfig-layout" { } ''
        test -f ${okConfig.prompts}/skills/helper/SKILL.md
        test -f ${okConfig.prompts}/skills/slide-generating/SKILL.md
        test -f ${okConfig.prompts}/agents/worker.md
        test -d ${okConfig.prompts}/commands
        test -f ${okConfig.prompts}/memory/user.md
        # Custom agents inherit the memory scopes (generated from the defined rows, no IFD).
        grep -qxF "$(printf 'scope:agent:worker\tscope:memory:user')" ${okConfig.facts}/scope_parent.facts
        touch $out
      '';
    }
  );

  brokenConfigWith =
    args:
    mkClaudeConfig (
      {
        src = ./mkclaude/broken-src;
        platform = realProfile;
        permissionsAllow = [
          "Read"
          "TaskOutput"
        ];
        hooks.PreToolUse = [
          {
            matcher = "TaskOutput|Bash";
            hooks = [ ];
          }
        ];
      }
      // args
    );

  brokenConfig = brokenConfigWith { };

  # A build failure cannot be an expectation, so the report that the refs check prints is compared.
  mkClaudeConfigBroken =
    pkgs.runCommand "eunomia-mkclaudeconfig-broken" { nativeBuildInputs = [ pkgs.diffutils ]; }
      ''
        status=0
        # The last 2 lines are the summary (counts + how to see the whole report), because
        # `nix build` shows only the tail of a failed build log. The lines before it are sorted
        # findings, compared regardless of order.
        head -n -2 ${./mkclaude/expected-broken-lines.txt} | sort > expected.body
        tail -n 2 ${./mkclaude/expected-broken-lines.txt} > expected.summary
        head -n -2 ${brokenConfig.refsReport} | sort > actual.body
        tail -n 2 ${brokenConfig.refsReport} > actual.summary
        if ! diff -u expected.body actual.body; then
          status=1
        fi
        if ! diff -u expected.summary actual.summary; then
          echo "the report must end with the summary lines" >&2
          status=1
        fi
        if [ "$status" -ne 0 ]; then
          echo "--- actual report ---" >&2
          while IFS= read -r line; do echo "$line" >&2; done < ${brokenConfig.refsReport}
          exit 1
        fi
        touch $out
      '';

  # The failing refs check prints the report to stderr (indented); `nix build` shows only the tail
  # of that log, so the last lines must be the summary.
  mkClaudeConfigBrokenCheckTail =
    let
      refs = brokenConfig.checks.refs;
    in
    pkgs.runCommand "eunomia-mkclaudeconfig-broken-check-tail"
      {
        nativeBuildInputs = (refs.nativeBuildInputs or [ ]) ++ [ pkgs.diffutils ];
      }
      ''
        if out=$PWD/target bash -e ${pkgs.writeText "eunomia-refs-check-script" refs.buildCommand} 2> err; then
          echo "FAIL: expected the refs check to fail" >&2
          exit 1
        fi
        tail -n 2 ${./mkclaude/expected-broken-lines.txt} > expected.summary
        tail -n 2 err | sed 's/^  //' > actual.summary
        diff -u expected.summary actual.summary
        touch $out
      '';

  # XSLT 1.0 has no CDATA, so a CDATA section holding `<` or `&` would come out escaped and the
  # generated prompt would differ from the origin: such origins are rejected by validateOrigins.
  inherit (import ../lib/validate.nix { inherit pkgs; }) validateOrigins;

  cdataRejected = expectBuildFailure "cdata" (validateOrigins { src = ./cdata/bad-src; }) "skills/raw-markup.xml: CDATA section contains '<' or '&'";

  cdataPlainOk = pkgs.runCommand "eunomia-cdata-plain-ok" { } ''
    test -e ${validateOrigins { src = ./cdata/ok-src; }}
    touch $out
  '';

  # A reference to a built-in skill (declared in the platform profile) is not dangling.
  builtinSkillConfig = mkClaudeConfig {
    src = ./mkclaude/builtin-src;
    platform = realProfile;
    memory = null;
  };

  mkClaudeConfigBuiltinSkill = pkgs.runCommand "eunomia-mkclaudeconfig-builtin-skill" { } ''
    test ! -s ${builtinSkillConfig.refsReport}
    grep -qxF "$(printf 'skill\tskill:code-review\tclaude-code-2.1.317')" ${builtinSkillConfig.facts}/defined.facts
    touch $out
  '';

  # Successors recorded in the real profile: search moved to Bash (find / grep); the others have none.
  realProfileRemoved =
    let
      actual = (import ../lib/profile.nix { inherit pkgs; }).profileFacts { platform = realProfile; };
    in
    pkgs.runCommand "eunomia-real-profile-removed" { nativeBuildInputs = [ pkgs.diffutils ]; } ''
      printf '%s\t%s\n' \
        tool:Glob tool:Bash \
        tool:Grep tool:Bash \
        tool:Task tool:Agent \
        tool:TaskOutput - \
        tool:TodoWrite - \
        | sort > expected
      sort ${actual}/removed.facts > actual
      diff -u expected actual
      touch $out
    '';

  # With commandsAreSkills, a custom command is also a skill (skill:<n>); without it, it is not.
  commandSkillConfig =
    platform:
    mkClaudeConfig {
      src = ./mkclaude/command-skill-src;
      inherit platform;
      memory = null;
    };

  mkClaudeConfigCommandsAreSkills =
    pkgs.runCommand "eunomia-mkclaudeconfig-commands-are-skills" { nativeBuildInputs = [ pkgs.diffutils ]; }
      ''
        test ! -s ${(commandSkillConfig realProfile).refsReport}
        printf '%s\n' \
          '参照切れ: skill:caller -> skill:ask (skills/caller.xml, 種別: skill)' \
          '要約: 参照切れ 1 件、削除済み 0 件、規範の衝突 0 件、未注釈の参照 0 件（合計 1 件）' \
          '全文は nix log <drv> か、mkClaudeConfig の refsReport をビルドして見る' \
          > expected
        diff -u expected ${(commandSkillConfig (realProfile // { commandsAreSkills = false; })).refsReport}
        touch $out
      '';

  # extra.<kind>.<n> = null places nothing, so it must not count as defined either.
  nullExtraConfig = mkClaudeConfig {
    src = ./mkclaude/null-extra-src;
    platform = realProfile;
    memory = null;
    extra = {
      skills = {
        foo = null;
        bar = ./mkclaude/slide-skill;
      };
      agents.ghost-agent = null;
    };
  };

  mkClaudeConfigNullExtra =
    pkgs.runCommand "eunomia-mkclaudeconfig-null-extra" { nativeBuildInputs = [ pkgs.diffutils ]; }
      ''
        printf '%s\n' \
          '参照切れ: skill:user-skill -> agent:ghost-agent (skills/user-skill.xml, 種別: agent)' \
          '参照切れ: skill:user-skill -> skill:foo (skills/user-skill.xml, 種別: skill)' \
          '要約: 参照切れ 2 件、削除済み 0 件、規範の衝突 0 件、未注釈の参照 0 件（合計 2 件）' \
          '全文は nix log <drv> か、mkClaudeConfig の refsReport をビルドして見る' \
          > expected
        diff -u expected ${nullExtraConfig.refsReport}
        if grep -q 'skill:foo' ${nullExtraConfig.facts}/defined.facts; then
          echo "skill:foo must not be defined" >&2
          exit 1
        fi
        touch $out
      '';

  # extra.agents / extra.commands (Markdown files) are copied into prompts and count as defined.
  placedExtraConfig = mkClaudeConfig {
    src = ./mkclaude/null-extra-src;
    platform = realProfile;
    memory = null;
    extra = {
      skills = {
        foo = ./mkclaude/slide-skill;
        bar = ./mkclaude/slide-skill;
      };
      agents.ghost-agent = ./mkclaude/extra-agent.md;
      commands.extra-command = ./mkclaude/extra-command.md;
    };
  };

  mkClaudeConfigExtraPlacement = pkgs.runCommand "eunomia-mkclaudeconfig-extra-placement" { } ''
    cmp ${./mkclaude/extra-agent.md} ${placedExtraConfig.prompts}/agents/ghost-agent.md
    cmp ${./mkclaude/extra-command.md} ${placedExtraConfig.prompts}/commands/extra-command.md
    grep -qxF "$(printf 'command\tcommand:extra-command\textra')" ${placedExtraConfig.facts}/defined.facts
    # Everything that user-skill refers to is placed, so nothing is reported.
    test ! -s ${placedExtraConfig.refsReport}
    touch $out
  '';

  # An extra agent/command with the same name as one produced from src is a build failure.
  mkClaudeConfigExtraCollision = expectBuildFailure "extra-collision" (mkClaudeConfig {
    src = ./mkclaude/ok-src;
    platform = realProfile;
    extra.agents.worker = ./mkclaude/extra-agent.md;
  }).prompts "extra agent 'worker' collides";

  # memory = "user" (the default) points CLAUDE.md at memory/user.md, so a missing origin fails the build.
  mkClaudeConfigMemoryMissing = expectBuildFailure "memory-missing" (mkClaudeConfig {
    src = ./mkclaude/null-extra-src;
    platform = realProfile;
  }).prompts "memory/user.md was not produced";

  # Only "user" or null are accepted: the project CLAUDE.md must never land in the user's CLAUDE.md.
  mkClaudeConfigMemoryArg =
    let
      attempt =
        memory:
        builtins.tryEval (
          builtins.seq (mkClaudeConfig {
            src = ./mkclaude/ok-src;
            platform = realProfile;
            inherit memory;
          }) true
        );
    in
    assert !(attempt "project").success;
    assert !(attempt "other").success;
    assert (attempt "user").success;
    assert (attempt null).success;
    pkgs.runCommand "eunomia-mkclaudeconfig-memory-arg" { } "touch $out";

  # The ambiguous names are those that cannot be told from ordinary English words; each must be a
  # tool the profile knows (tools or removed), or listing it would be meaningless.
  realProfileAmbiguous =
    pkgs.runCommand "eunomia-real-profile-ambiguous" { nativeBuildInputs = [ pkgs.diffutils ]; }
      ''
        printf '%s\n' Read Edit Write Bash Agent Skill Monitor Workflow Artifact | sort > expected
        printf '%s\n' ${lib.escapeShellArgs realProfile.ambiguousToolNames} | sort > actual
        diff -u expected actual
        ${lib.concatMapStrings (n: ''
          echo "ambiguousToolNames lists '${n}', which is neither a tool nor a removed one" >&2
          exit 1
        '') (builtins.filter (n: !(builtins.elem n realProfileToolNames)) realProfile.ambiguousToolNames)}
        touch $out
      '';

  # Unannotated references end to end: the report lists them (only them, sorted) and the summary
  # counts them. The origin is the one of the facts case; its cc:useTool is an annotated reference.
  unannotatedConfig = mkClaudeConfig {
    src = ./facts/unannotated/src;
    platform = realProfile;
    memory = null;
  };

  mkClaudeConfigUnannotated =
    pkgs.runCommand "eunomia-mkclaudeconfig-unannotated" { nativeBuildInputs = [ pkgs.diffutils ]; }
      ''
        printf '%s\n' \
          '未注釈の参照: skill:unannotated -> tool:Edit (skills/unannotated.xml)' \
          '未注釈の参照: skill:unannotated -> tool:Glob (skills/unannotated.xml)' \
          '未注釈の参照: skill:unannotated -> tool:Grep (skills/unannotated.xml)' \
          '未注釈の参照: skill:unannotated -> tool:Read (skills/unannotated.xml)' \
          '未注釈の参照: skill:unannotated -> tool:TaskOutput (skills/unannotated.xml)' \
          '未注釈の参照: skill:unannotated -> tool:TodoWrite (skills/unannotated.xml)' \
          '未注釈の参照: skill:unannotated -> tool:WebFetch (skills/unannotated.xml)' \
          '未注釈の参照: skill:unannotated -> tool:Write (skills/unannotated.xml)' \
          '未注釈の参照: skill:unannotated -> tool:mcp__x__y (skills/unannotated.xml)' \
          '要約: 参照切れ 0 件、削除済み 0 件、規範の衝突 0 件、未注釈の参照 9 件（合計 9 件）' \
          '全文は nix log <drv> か、mkClaudeConfig の refsReport をビルドして見る' \
          > expected
        diff -u expected ${unannotatedConfig.refsReport}
        # The refs check fails on unannotated references.
        if out=$PWD/target bash -e ${pkgs.writeText "eunomia-unannotated-refs-script" unannotatedConfig.checks.refs.buildCommand} 2> err; then
          echo "FAIL: expected the refs check to fail" >&2
          exit 1
        fi
        touch $out
      '';

  # The argument of Skill(...) / Agent(...) in permissions.allow is a reference to a skill / agent:
  # an undefined skill is dangling, a defined skill and a built-in agent are not, and an argument
  # with a wildcard or a colon is not checked.
  permissionArgsConfig = mkClaudeConfig {
    src = ./mkclaude/permission-args-src;
    platform = realProfile;
    memory = null;
    permissionsAllow = [
      "Skill(execute)"
      "Skill(plan-workflow)"
      "Skill(foo:*)"
      "Skill(bar *)"
      "Agent(Explore)"
      "Agent"
    ];
  };

  mkClaudeConfigPermissionArgs =
    pkgs.runCommand "eunomia-mkclaudeconfig-permission-args" { nativeBuildInputs = [ pkgs.diffutils ]; }
      ''
        printf '%s\n' \
          '参照切れ: settings:permissions.allow -> skill:execute (settings, 種別: skill)' \
          '要約: 参照切れ 1 件、削除済み 0 件、規範の衝突 0 件、未注釈の参照 0 件（合計 1 件）' \
          '全文は nix log <drv> か、mkClaudeConfig の refsReport をビルドして見る' \
          > expected
        diff -u expected ${permissionArgsConfig.refsReport}
        touch $out
      '';

  # Skill / agent / command names in prose end to end, with the real profile: built-in agents and
  # skills are known names, and commandsAreSkills lets /code-review count. The origin is the one
  # of the facts case; its annotated references are checked (skill:feedback does not exist).
  unannotatedNamesConfig = mkClaudeConfig {
    src = ./facts/unannotated-names/src;
    platform = realProfile;
    memory = null;
  };

  mkClaudeConfigUnannotatedNames =
    pkgs.runCommand "eunomia-mkclaudeconfig-unannotated-names" { nativeBuildInputs = [ pkgs.diffutils ]; }
      ''
        printf '%s\n' \
          '参照切れ: skill:names -> skill:feedback (skills/names.xml, 種別: skill)' \
          '未注釈の参照: skill:names -> agent:code-reviewer (skills/names.xml)' \
          '未注釈の参照: skill:names -> agent:explore (skills/names.xml)' \
          '未注釈の参照: skill:names -> agent:worker (skills/names.xml)' \
          '未注釈の参照: skill:names -> agent:zzz (skills/names.xml)' \
          '未注釈の参照: skill:names -> command:ask (skills/names.xml)' \
          '未注釈の参照: skill:names -> command:ask-user (skills/names.xml)' \
          '未注釈の参照: skill:names -> skill:code-review (skills/names.xml)' \
          '未注釈の参照: skill:names -> skill:feedback (skills/names.xml)' \
          '未注釈の参照: skill:names -> skill:impl-workflow (skills/names.xml)' \
          '未注釈の参照: skill:names -> skill:plan-workflow (skills/names.xml)' \
          '未注釈の参照: skill:names -> skill:simplify (skills/names.xml)' \
          '未注釈の参照: skill:names -> skill:xfeedback (skills/names.xml)' \
          '未注釈の参照: skill:names -> skill:yyy (skills/names.xml)' \
          '要約: 参照切れ 1 件、削除済み 0 件、規範の衝突 0 件、未注釈の参照 13 件（合計 14 件）' \
          '全文は nix log <drv> か、mkClaudeConfig の refsReport をビルドして見る' \
          > expected
        diff -u expected ${unannotatedNamesConfig.refsReport}
        touch $out
      '';

  # Kind and name come from the path (<kinddir>/<name>.xml): an origin that leaves out the root
  # `key`, `cc:name` and the memory `level` gives the same facts and prompts as one that writes
  # them out.
  deriveFromPath =
    let
      inherit (import ../lib/prompts.nix { inherit pkgs; }) renderPrompts;
      factsOf =
        src:
        extractFacts {
          inherit src;
          toolNames = realProfileToolNames;
          inherit (realProfile) ambiguousToolNames;
        };
      explicit = ./derive/full-src;
      omitted = ./derive/omitted-src;
    in
    pkgs.runCommand "eunomia-derive-from-path" { nativeBuildInputs = [ pkgs.diffutils ]; } ''
      diff -r ${factsOf explicit} ${factsOf omitted}
      diff -r ${renderPrompts { src = explicit; }} ${renderPrompts { src = omitted; }}
      # The derived values are really used: facts key, front-matter name, output path, default scope.
      grep -qxF "$(printf 'skill\tskill:greet\tskills/greet.xml')" ${factsOf omitted}/defined.facts
      grep -qxF "$(printf 'scope\tscope:memory:project\tmemory/project.xml')" ${factsOf omitted}/defined.facts
      grep -qxF "$(printf 'memory:project#no-edit\tF\tagent:*\tcc:invoke\ttool:Edit\tscope:memory:project')" ${factsOf omitted}/norm.facts
      grep -qxF 'name: "greet"' ${renderPrompts { src = omitted; }}/skills/greet/SKILL.md
      test -f ${renderPrompts { src = omitted; }}/memory/project.md
      touch $out
    '';

  # Origins that break the path convention or disagree with the path are rejected by
  # validateOrigins (checks.schema), naming the file and what differs.
  originErrorCases = {
    key-mismatch = "skills/foo.xml: key 'skill:bar' does not match 'skill:foo' derived from the path";
    name-mismatch = "skills/foo.xml: cc:name 'bar' does not match the file name 'foo'";
    level-mismatch = "memory/project.xml: level 'user' does not match the file name 'project'";
    root-kind-mismatch = "skills/foo.xml: root element cc:agent does not match the directory 'skills' (expected cc:skill)";
    too-deep = "skills/sub/foo.xml: nested directories are not allowed";
    unknown-kinddir = "widgets/foo.xml: unknown kind directory 'widgets'";
    no-kinddir = "foo.xml: not under a kind directory";
    bad-name = "skills/bad name.xml: invalid name 'bad name'";
    bad-memory-name = "memory/team.xml: memory name must be 'user' or 'project'";
  };

  originErrors = pkgs.linkFarm "eunomia-origin-errors" (
    originErrorCases
    |> lib.mapAttrs (
      case: pattern:
      expectBuildFailure "origin-${case}" (validateOrigins { src = ./origin-errors + "/${case}"; }) pattern
    )
  );

  # Evaluates a generated module together with the locked home-manager.
  evalHm =
    module:
    inputs.home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules = [
        module
        {
          home = {
            username = "tester";
            homeDirectory = "/home/tester";
            stateVersion = "25.05";
          };
          programs.claude-code = {
            enable = true;
            package = null;
          };
        }
      ];
    };

  homeManagerModule =
    let
      hm = evalHm okConfig.homeManagerModule;
      files = hm.config.home-files;
    in
    pkgs.runCommand "eunomia-home-manager-module" { } ''
      test -f ${files}/.claude/skills/helper/SKILL.md
      test -f ${files}/.claude/skills/slide-generating/SKILL.md
      test -f ${files}/.claude/agents/worker.md
      test -d ${files}/.claude/commands
      # CLAUDE.md must hold the generated memory, not a store path string.
      cmp ${files}/.claude/CLAUDE.md ${okConfig.prompts}/memory/user.md
      # The placed content is the verified copy of prompts: byte for byte the same.
      diff -r ${okConfig.prompts} ${okConfig.verifiedPrompts}
      touch $out
    '';

  # The placement depends on the checks by default: the option values (what `nix eval` shows) point
  # at verifiedPrompts, and evaluating them builds nothing. Building verifiedPrompts of a broken
  # origin fails with the same report as the refs check (the build script is run directly, as in
  # expectBuildFailure), so that the home-files that contain it cannot be built.
  brokenHmValues = (evalHm brokenConfig.homeManagerModule).config.programs.claude-code;

  homeManagerEnforced =
    assert brokenHmValues.skills == "${brokenConfig.verifiedPrompts}/skills";
    assert brokenHmValues.agentsDir == "${brokenConfig.verifiedPrompts}/agents";
    assert brokenHmValues.commandsDir == "${brokenConfig.verifiedPrompts}/commands";
    pkgs.linkFarm "eunomia-home-manager-enforced" {
      # Same heading and counts as the refs check prints.
      summary = expectBuildFailure "verified-summary" brokenConfig.verifiedPrompts "要約: 参照切れ 3 件、削除済み 4 件、規範の衝突 1 件、未注釈の参照 0 件（合計 8 件）";
      heading = expectBuildFailure "verified-heading" brokenConfig.verifiedPrompts "eunomia: reference/conflict check failed:";
      finding = expectBuildFailure "verified-finding" brokenConfig.verifiedPrompts "  参照切れ: skill:plan-workflow -> skill:ghost (skills/plan-workflow.xml, 種別: skill)";
      # The failing output ends with the two summary lines, like the refs check.
      tail =
        pkgs.runCommand "eunomia-home-manager-enforced-tail"
          {
            nativeBuildInputs = (brokenConfig.verifiedPrompts.nativeBuildInputs or [ ]) ++ [ pkgs.diffutils ];
          }
          ''
            if out=$PWD/target bash -e ${pkgs.writeText "eunomia-verified-script" brokenConfig.verifiedPrompts.buildCommand} 2> err; then
              echo "FAIL: expected verifiedPrompts to fail" >&2
              exit 1
            fi
            tail -n 2 ${./mkclaude/expected-broken-lines.txt} > expected.summary
            tail -n 2 err | sed 's/^  //' > actual.summary
            diff -u expected.summary actual.summary
            touch $out
          '';
    };

  # enforceChecks = false places prompts as before, so a broken origin can still be placed.
  brokenUnenforced = brokenConfigWith { enforceChecks = false; };

  homeManagerUnenforced =
    let
      hm = evalHm brokenUnenforced.homeManagerModule;
      files = hm.config.home-files;
    in
    assert hm.config.programs.claude-code.skills == "${brokenUnenforced.prompts}/skills";
    pkgs.runCommand "eunomia-home-manager-unenforced" { } ''
      test -f ${files}/.claude/skills/plan-workflow/SKILL.md
      test -f ${files}/.claude/agents/bad.md
      cmp ${files}/.claude/CLAUDE.md ${brokenUnenforced.prompts}/memory/user.md
      touch $out
    '';
in
{
  inherit
    perCase
    schema
    facts
    factsErrors
    e2e
    prompts
    promptsQuoting
    promptsDuplicateKey
    yamlRoundTrip
    profile
    spaces
    deriveFromPath
    originErrors
    mkClaudeConfigOk
    mkClaudeConfigBroken
    realProfileRemoved
    cdataRejected
    cdataPlainOk
    mkClaudeConfigBrokenCheckTail
    mkClaudeConfigBuiltinSkill
    mkClaudeConfigCommandsAreSkills
    mkClaudeConfigNullExtra
    mkClaudeConfigExtraPlacement
    mkClaudeConfigExtraCollision
    mkClaudeConfigMemoryMissing
    mkClaudeConfigMemoryArg
    realProfileAmbiguous
    mkClaudeConfigUnannotated
    mkClaudeConfigUnannotatedNames
    mkClaudeConfigPermissionArgs
    ;
  # One derivation that depends on every case.
  rules = pkgs.linkFarm "eunomia-rules" perCase;
}
// lib.optionalAttrs (inputs != null) {
  inherit homeManagerModule homeManagerEnforced homeManagerUnenforced;
}
