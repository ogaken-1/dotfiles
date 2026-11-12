# XSD validation of the origin XML, done once per src. Every consumer (facts, prompts, checks.schema)
# depends on the same derivation (identical inputs give an identical store path).
{ pkgs }:
let
  origin = import ./origin.nix;
in
{
  # src -> derivation whose output is a symlink to src. It only builds when every *.xml under src
  # follows the path convention (src/<kinddir>/<name>.xml), validates against cc.xsd and agrees
  # with its path (key, cc:name, level), so depending on it means depending on the validation.
  validateOrigins =
    { src }:
    pkgs.runCommand "eunomia-validated"
      {
        nativeBuildInputs = [
          pkgs.libxml2
          pkgs.libxslt
          pkgs.findutils
          pkgs.gnugrep
          pkgs.coreutils
        ];
      }
      ''
        export LC_ALL=C
        ${origin.shellFunctions}
        # The src root itself may contain whitespace.
        cd ${pkgs.lib.escapeShellArg src}
        # NUL-separated so that paths with whitespace survive.
        status=0
        while IFS= read -r -d ''' f; do
          # The kind and the name come from the path; a path off the convention is an error.
          if ! eunomia_origin_id "$f"; then
            status=1
            continue
          fi
          if xmllint --noout --nonet --schema ${../schema/cc.xsd} "$f"; then
            # What is written in the file (root element, key, cc:name, level) must agree with the path.
            if ! xsltproc --stringparam file "$f" --stringparam kind "$origin_kind" --stringparam name "$origin_name" \
              ${../xslt/check-origin.xsl} "$f" > /dev/null; then
              status=1
            fi
          else
            status=1
          fi
          # XSLT 1.0 has no CDATA: the generated prompt would carry the content as escaped text
          # (`<` -> `&lt;`) and differ from the origin. Reject CDATA sections holding `<` or `&`.
          # (-z: the whole file is one record, so a section can span lines. A "<![CDATA[" inside an
          # XML comment is also caught; that is accepted.)
          if grep -Pzq '(?s)<!\[CDATA\[(?:(?!\]\]>)[^<&])*[<&]' "$f"; then
            echo "$f: CDATA section contains '<' or '&' (the generated prompt would escape it and differ from the origin)" >&2
            status=1
          fi
        done < <(find . -type f -name '*.xml' -printf '%P\0' | sort -z)
        [ "$status" -eq 0 ] || { echo "schema validation failed" >&2; exit 1; }
        ln -s ${pkgs.lib.escapeShellArg src} $out
      '';
}
