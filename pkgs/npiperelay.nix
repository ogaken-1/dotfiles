{
  stdenvNoCC,
  fetchurl,
  unzip,
  ...
}:
stdenvNoCC.mkDerivation rec {
  pname = "npiperelay";
  version = "0.1.0";
  src = fetchurl {
    url = "https://github.com/jstarks/${pname}/releases/download/v${version}/${pname}_windows_amd64.zip";
    hash = "sha256-a572H/0XwDUHqaPVTYFdzrPa5mmsZ/w79CJdHnZM5fY=";
  };
  nativeBuildInputs = [ unzip ];
  sourceRoot = ".";
  installPhase = ''
    install -Dm755 npiperelay.exe $out/bin/npiperelay.exe
  '';
}
