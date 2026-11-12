# Prompt generation: origin XML (src) -> skills/<n>/SKILL.md, agents/<n>.md, commands/<n>.md, memory/<level>.md.
{ pkgs }:
let
  inherit (pkgs) lib;
  inherit (import ./yaml.nix) toYaml;
  origin = import ./origin.nix;
  inherit (import ./validate.nix { inherit pkgs; }) validateOrigins;
in
{
  # extraFrontMatter: { "<root key>" = <attrset>; } rendered with toYaml and appended to that
  # entity's front-matter (e.g. hooks that contain store paths).
  renderPrompts =
    {
      src,
      extraFrontMatter ? { },
    }:
    let
      checkedSrc = validateOrigins { inherit src; };
      extraYamlDir =
        extraFrontMatter
        |> lib.mapAttrs (key: value: pkgs.writeText "eunomia-extra-yaml" (toYaml value))
        |> pkgs.linkFarm "eunomia-extra-yaml";
    in
    pkgs.runCommand "eunomia-prompts"
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
        export LC_ALL=C.UTF-8
        ${origin.shellFunctions}
        mkdir -p $out
        # Origins are validated by the shared derivation.
        cd ${checkedSrc}

        : > "$TMPDIR/seen"
        # NUL-separated so that paths with whitespace survive.
        while IFS= read -r -d ''' f; do
          # The kind and the name come from the path (src/<kinddir>/<name>.xml); the key, the output
          # path and the front-matter name are all derived from them.
          eunomia_origin_id "$f" || exit 1
          kind=$origin_kind
          name=$origin_name
          key="$kind:$name"
          case "$kind" in
            skill) rel="skills/$name/SKILL.md" ;;
            agent) rel="agents/$name.md" ;;
            command) rel="commands/$name.md" ;;
            memory) rel="memory/$name.md" ;;
          esac
          if [ -e "$out/$rel" ]; then
            echo "$f: output path $rel is already produced by another origin" >&2
            exit 1
          fi
          echo "$key" >> "$TMPDIR/seen"

          # extraFrontMatter for this origin (appended below, outside XSLT: the YAML may contain
          # both quote kinds, which xsltproc --stringparam cannot take).
          extraYamlFile="${extraYamlDir}/$key"

          # Body: prompt descendants without leading/trailing blank lines, ending with a single newline.
          xsltproc ${../xslt/to-prompt.xsl} "$f" | awk '
            NF || started { started = 1; buf[++n] = $0 }
            END {
              while (n > 0 && buf[n] ~ /^[ \t]*$/) n--
              for (i = 1; i <= n; i++) print buf[i]
            }
          ' > "$TMPDIR/body"

          mkdir -p "$(dirname "$out/$rel")"
          if [ "$kind" = memory ]; then
            cp "$TMPDIR/body" "$out/$rel"
          else
            xsltproc --stringparam name "$name" ${../xslt/to-frontmatter.xsl} "$f" > "$TMPDIR/frontmatter"
            if [ -s "$extraYamlFile" ]; then
              # Top-level keys sit at column 0 on both sides; a key on both sides would appear twice.
              awk -F: '{ print $1 }' "$TMPDIR/frontmatter" > "$TMPDIR/origin-keys"
              while IFS= read -r k; do
                if grep -qxF -- "$k" "$TMPDIR/origin-keys"; then
                  echo "$key: key '$k' is defined by both the origin and extraFrontMatter" >&2
                  exit 1
                fi
              done < <(awk -F: '/^[^ \t]/ { print $1 }' "$extraYamlFile")
            fi
            {
              echo '---'
              cat "$TMPDIR/frontmatter"
              if [ -s "$extraYamlFile" ]; then
                cat "$extraYamlFile"
                echo
              fi
              echo '---'
              echo
              tail -n +1 "$TMPDIR/body"
            } > "$out/$rel"
          fi
        done < <(find . -type f -name '*.xml' -printf '%P\0' | sort -z)

        # extraFrontMatter keys must name an existing origin.
        for k in ${lib.escapeShellArgs (builtins.attrNames extraFrontMatter)}; do
          if ! grep -qxF "$k" "$TMPDIR/seen"; then
            echo "extraFrontMatter key '$k' matches no origin" >&2
            exit 1
          fi
        done
      '';
}
