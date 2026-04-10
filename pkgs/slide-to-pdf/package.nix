{
  lib,
  stdenv,
  nodejs,
  pnpm_10,
  pnpmConfigHook,
  fetchPnpmDeps,
  makeWrapper,
  makeFontsConf,
  playwright-driver,
  biz-ud-gothic,
}:
let
  fontsConf = makeFontsConf { fontDirectories = [ biz-ud-gothic ]; };
  browsers = playwright-driver.selectBrowsers {
    fontconfig_file = fontsConf;
    withChromium = false;
    withFirefox = false;
    withWebkit = false;
  };
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
    hash = "sha256-yJmDp/7N5g5KtP0O4wT5f1S9fXiAQ76QtKR8/vpK/dA=";
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib/slide-to-pdf $out/bin
    cp -r node_modules $out/lib/slide-to-pdf/
    cp slide-to-pdf.mjs $out/lib/slide-to-pdf/
    makeWrapper ${nodejs}/bin/node $out/bin/slide-to-pdf \
      --add-flags "$out/lib/slide-to-pdf/slide-to-pdf.mjs" \
      --set PLAYWRIGHT_BROWSERS_PATH "${browsers}" \
      --set FONTCONFIG_FILE "${fontsConf}"
    runHook postInstall
  '';

  meta = {
    description = "Convert slide HTML to PDF using Playwright";
    license = lib.licenses.mit;
    mainProgram = "slide-to-pdf";
  };
})
