{
  lib,
  stdenv,
  nodejs,
  pnpm_10,
  pnpmConfigHook,
  fetchPnpmDeps,
  makeWrapper,
  makeFontsConf,
  fontconfig,
  jq,
  chromedriver,
  chromium,
  callPackage,
}:
let
  slideFonts = callPackage ./fonts.nix { };
  fontsConf = makeFontsConf { fontDirectories = slideFonts; };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "slide-to-pdf";
  version = "1.0.0";
  src = ./.;

  nativeBuildInputs = [
    nodejs
    pnpm_10
    pnpmConfigHook
    makeWrapper
    fontconfig
    jq
  ];

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    fetcherVersion = 3;
    hash = "sha256-JkL+6RkHayWkSD5e/BvVs9nkKXFCRlabAJ6+97EHOE4=";
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib/slide-to-pdf $out/bin
    cp -r node_modules $out/lib/slide-to-pdf/
    cp slide-to-pdf.mjs $out/lib/slide-to-pdf/

    # Generate font manifest from Nix-managed fonts
    manifestDir=$out/lib/slide-to-pdf
    manifest=$manifestDir/fonts-manifest.json

    mapWeight() {
      case "$1" in
        0) echo 100 ;;
        40) echo 200 ;;
        50) echo 300 ;;
        80) echo 400 ;;
        100) echo 500 ;;
        180) echo 600 ;;
        200) echo 700 ;;
        205) echo 800 ;;
        210) echo 900 ;;
        *) echo 400 ;;
      esac
    }

    mapSlant() {
      case "$1" in
        0) echo normal ;;
        100) echo italic ;;
        110) echo oblique ;;
        *) echo normal ;;
      esac
    }

    isVariable() {
      case "$1" in
        *-variable.*|*\[wght\]*|*Variable*) return 0 ;;
        *) return 1 ;;
      esac
    }

    entries=()
    for fontDir in ${toString (map (f: "${f}/share/fonts") slideFonts)}; do
      [ -d "$fontDir" ] || continue
      while IFS= read -r -d "" fontFile; do
        fname=$(basename "$fontFile")
        family=$(fc-query --format='%{family[0]}\n' "$fontFile" | head -n1)
        if isVariable "$fname"; then
          weightJson='[100, 900]'
        else
          fcWeight=$(fc-query --format='%{weight}\n' "$fontFile" | head -n1)
          w=$(mapWeight "$fcWeight")
          weightJson="$w"
        fi
        fcSlant=$(fc-query --format='%{slant}\n' "$fontFile" | head -n1)
        style=$(mapSlant "$fcSlant")
        entry=$(jq -n --arg family "$family" --argjson weight "$weightJson" --arg style "$style" --arg path "$fontFile" '{family: $family, weight: $weight, style: $style, path: $path}')
        entries+=("$entry")
      done < <(find -L "$fontDir" -type f \( -name '*.ttf' -o -name '*.otf' \) -print0)
    done

    printf '%s\n' "''${entries[@]}" | jq -s '.' > "$manifest"

    makeWrapper ${nodejs}/bin/node $out/bin/slide-to-pdf \
      --add-flags "$out/lib/slide-to-pdf/slide-to-pdf.mjs" \
      --set CHROMEDRIVER_PATH "${chromedriver}/bin/chromedriver" \
      --set CHROMIUM_PATH "${chromium}/bin/chromium" \
      --set FONTCONFIG_FILE "${fontsConf}" \
      --set SLIDE_FONTS_MANIFEST "$out/lib/slide-to-pdf/fonts-manifest.json"
    runHook postInstall
  '';

  meta = {
    description = "Convert slide HTML to PDF using WebdriverIO";
    license = lib.licenses.mit;
    mainProgram = "slide-to-pdf";
  };
})
