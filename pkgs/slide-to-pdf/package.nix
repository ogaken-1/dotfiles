{
  lib,
  stdenv,
  nodejs,
  pnpm_10,
  pnpmConfigHook,
  fetchPnpmDeps,
  makeWrapper,
  makeFontsConf,
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
    makeWrapper ${nodejs}/bin/node $out/bin/slide-to-pdf \
      --add-flags "$out/lib/slide-to-pdf/slide-to-pdf.mjs" \
      --set CHROMEDRIVER_PATH "${chromedriver}/bin/chromedriver" \
      --set CHROMIUM_PATH "${chromium}/bin/chromium" \
      --set FONTCONFIG_FILE "${fontsConf}"
    runHook postInstall
  '';

  meta = {
    description = "Convert slide HTML to PDF using WebdriverIO";
    license = lib.licenses.mit;
    mainProgram = "slide-to-pdf";
  };
})
