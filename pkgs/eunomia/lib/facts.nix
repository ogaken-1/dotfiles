# Fact extraction: origin XML (src) -> Souffle facts directory.
{ pkgs }:
let
  relations = import ./relations.nix;
  origin = import ./origin.nix;
  inherit (import ./validate.nix { inherit pkgs; }) validateOrigins;
in
{
  # extraFacts: optional directory of <relation>.facts (e.g. generated from the platform
  # profile); each file is appended to the extracted one.
  #
  # toolNames: tool names (defined and removed ones) whose plain-text occurrences in an origin
  # become `mention` rows; mcp__* names are always mentions. ambiguousToolNames (a subset of
  # toolNames): names that are also ordinary words, mentioned only in backticks (text) or as a
  # whole part of an attribute value.
  #
  # Skill / agent / command names written in prose also become `mention` rows (scan_names in the awk
  # below). Which names are known (defined) comes from the origins' own `defined` rows plus
  # extraFacts' defined.facts (built-in skills / agents, extra placements, the commandsAreSkills flag).
  extractFacts =
    {
      src,
      extraFacts ? null,
      toolNames ? [ ],
      ambiguousToolNames ? [ ],
    }:
    let
      checkedSrc = validateOrigins { inherit src; };
    in
    pkgs.runCommand "eunomia-facts"
      {
        nativeBuildInputs = [
          pkgs.libxml2
          pkgs.libxslt
          pkgs.findutils
          pkgs.gawk
          pkgs.coreutils
        ];
      }
      ''
        export LC_ALL=C
        ${origin.shellFunctions}
        mkdir -p $out
        for rel in ${pkgs.lib.escapeShellArgs relations}; do
          : > "$out/$rel.facts"
        done

        # Origins are validated by the shared derivation; no facts come from an invalid one.
        cd ${checkedSrc}

        : > "$TMPDIR/all"
        # NUL-separated so that paths with whitespace survive.
        while IFS= read -r -d ''' f; do
          # The kind and the name come from the path (src/<kinddir>/<name>.xml).
          eunomia_origin_id "$f" || exit 1
          xsltproc --stringparam file "$f" --stringparam kind "$origin_kind" --stringparam name "$origin_name" \
            ${../xslt/to-facts.xsl} "$f" >> "$TMPDIR/all"
        done < <(find . -type f -name '*.xml' -printf '%P\0' | sort -z)

        # Known names ("<kind>\t<kind>:<name>"): the origins' own `defined` rows and the profile's.
        awk -F '\t' '$1 == "defined" { print $2 "\t" $3 }' "$TMPDIR/all" > "$TMPDIR/known"
        ${
          if extraFacts == null then
            ""
          else
            ''
              if [ -f "${extraFacts}/defined.facts" ]; then
                awk -F '\t' '{ print $1 "\t" $2 }' "${extraFacts}/defined.facts" >> "$TMPDIR/known"
              fi
            ''
        }

        # Split "<relation>\t<cols>" lines into <relation>.facts. "text" / "attr" lines carry a
        # text node / attribute value ("<kind>\t<src>\t<file>\t<string>", tabs and newlines already
        # replaced by spaces): the tool names in them become `mention` rows instead.
        awk -F '\t' -v out="$out" -v rels="${builtins.concatStringsSep " " relations}" \
          -v names=${pkgs.lib.escapeShellArg (builtins.concatStringsSep " " toolNames)} \
          -v ambiguous=${pkgs.lib.escapeShellArg (builtins.concatStringsSep " " ambiguousToolNames)} \
          -v knownfile="$TMPDIR/known" '
          function isword(c) { return c ~ /^[A-Za-z0-9_]$/ }
          function mention(src, name, file) {
            print src "\ttool:" name "\t" file >> (out "/mention.facts")
          }
          # Whether `name` occurs in s with no ASCII alphanumeric or "_" on either side.
          function bounded(s, name,    off, p, start, before) {
            off = 0
            while ((p = index(substr(s, off + 1), name)) > 0) {
              start = off + p
              # substr() with a start below 1 differs between awks, so the first position is explicit.
              before = (start > 1) ? substr(s, start - 1, 1) : ""
              if (!isword(before) && !isword(substr(s, start + length(name), 1)))
                return 1
              off = start
            }
            return 0
          }
          function emit(src, file, kind, name) {
            print src "\t" kind ":" name "\t" file >> (out "/mention.facts")
          }
          # A usable name is lowercase kebab-case, the convention for skills / agents / commands
          # ([a-z][a-z0-9_.-]*, so "CLI", "Git" and "2" are not names; leading dots are dropped), does
          # not follow "_" or "-" and does not end with "." (the end of a sentence).
          function cleanname(run,    nm) {
            nm = run
            sub(/^\.+/, "", nm)
            if (nm !~ /^[a-z][a-z0-9_.-]*$/ || nm ~ /\.$/) return ""
            return nm
          }
          # Skill / agent / command names written in prose:
          #   <name>スキル / エージェント                always (the name runs back to the previous non-name byte)
          #   <name>コマンド, <name> skill / agent / command
          #                                           only a hyphenated or known name (not "the skill", "cat")
          #   /<name>                                 only a defined command, or (commandsAreSkills) a defined skill
          function scan_names(src, file, s,    j, rest, run, nm, lc, kind, p, off, start, prev, after) {
            for (j = 1; j <= 3; j++) {
              rest = s
              while (match(rest, "[A-Za-z0-9_.-]+" jsuf[j])) {
                run = substr(rest, RSTART, RLENGTH - length(jsuf[j]))
                rest = substr(rest, RSTART + RLENGTH)
                nm = cleanname(run)
                if (nm == "") continue
                # Shell commands ("cat", "find") are written the same way, so a command needs the
                # same condition as in English.
                if (jkind[j] == "command" && index(nm, "-") == 0 && !((jkind[j] ":" nm) in known)) continue
                emit(src, file, jkind[j], nm)
              }
            }
            # English: matched on a lower-cased copy (same byte length), so the case is ignored.
            lc = tolower(s)
            off = 0
            while (match(substr(lc, off + 1), /[a-z0-9_.-]+ +(skill|agent|command)([^a-z0-9_-]|$)/)) {
              start = off + RSTART
              p = index(substr(lc, start), " ")
              run = substr(s, start, p - 1)
              kind = substr(lc, start + p - 1)
              sub(/^ +/, "", kind)
              sub(/[^a-z].*$/, "", kind)
              # Continue from the keyword, which can itself be the name of the next pair.
              off = start + p - 1
              nm = cleanname(run)
              if (nm == "") continue
              if (index(nm, "-") > 0 || ((kind ":" nm) in known)) emit(src, file, kind, nm)
            }
            # Slash command: "/name" not glued to a path.
            off = 0
            while (match(substr(s, off + 1), /\/[A-Za-z0-9][A-Za-z0-9_.-]*/)) {
              start = off + RSTART
              nm = substr(s, start + 1, RLENGTH - 1)
              after = substr(s, start + RLENGTH, 1)
              prev = (start > 1) ? substr(s, start - 1, 1) : ""
              off = start + RLENGTH - 1
              if (prev ~ /[A-Za-z0-9_.\/~-]/ || after == "/") continue
              sub(/\.+$/, "", nm)
              if (("command:" nm) in known) emit(src, file, "command", nm)
              else if (cmdskill && (("skill:" nm) in known)) emit(src, file, "skill", nm)
            }
          }
          function scan(kind, src, file, s,    rest, i, k, parts, np) {
            scan_names(src, file, s)
            # Every mcp__ name is a mention, whatever its context.
            rest = s
            while (match(rest, /mcp__[A-Za-z0-9_-]+/)) {
              mention(src, substr(rest, RSTART, RLENGTH), file)
              rest = substr(rest, RSTART + RLENGTH)
            }
            np = split(s, parts, /[\/, ]+/)
            for (k = 1; k <= nnames; k++) {
              name = names_list[k]
              if (name in amb) {
                if (kind == "text") {
                  if (index(s, "`" name "`") > 0) mention(src, name, file)
                } else {
                  for (i = 1; i <= np; i++) if (parts[i] == name) { mention(src, name, file); break }
                }
              } else if (bounded(s, name)) {
                mention(src, name, file)
              }
            }
          }
          BEGIN {
            n = split(rels, a, " "); for (i = 1; i <= n; i++) known[a[i]] = 1
            nnames = split(names, names_list, " ")
            n = split(ambiguous, a, " "); for (i = 1; i <= n; i++) amb[a[i]] = 1
            jsuf[1] = "スキル"; jkind[1] = "skill"
            jsuf[2] = "エージェント"; jkind[2] = "agent"
            jsuf[3] = "コマンド"; jkind[3] = "command"
            while ((getline line < knownfile) > 0) {
              split(line, f, "\t")
              known[f[2]] = 1
              if (f[1] == "flag" && f[2] == "commandsAreSkills") cmdskill = 1
            }
            close(knownfile)
            # With commandsAreSkills every command is also a skill.
            if (cmdskill) {
              for (k in known) if (k ~ /^command:/) derived["skill:" substr(k, 9)] = 1
              for (k in derived) known[k] = 1
            }
          }
          $1 == "text" || $1 == "attr" { scan($1, $2, $3, $4); next }
          {
            if (!($1 in known)) { print "unknown relation: " $1 > "/dev/stderr"; exit 1 }
            print substr($0, length($1) + 2) >> (out "/" $1 ".facts")
          }
        ' "$TMPDIR/all"

        ${
          if extraFacts == null then
            ""
          else
            ''
              for rel in ${pkgs.lib.escapeShellArgs relations}; do
                if [ -f "${extraFacts}/$rel.facts" ]; then
                  cat "${extraFacts}/$rel.facts" >> "$out/$rel.facts"
                fi
              done
            ''
        }

        for rel in ${pkgs.lib.escapeShellArgs relations}; do
          sort -u "$out/$rel.facts" -o "$out/$rel.facts"
        done
      '';
}
