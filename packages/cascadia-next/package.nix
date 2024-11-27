{
  lib,
  stdenvNoCC,
  fetchurl,
  ...
}:
stdenvNoCC.mkDerivation {
  pname = "cascadia-code";
  version = "cascadia-next";
  src = fetchurl {
    url = "https://github.com/microsoft/cascadia-code/releases/download/cascadia-next/CascadiaNextJP.wght.ttf";
    hash = "sha256-r4v57pjisJ03YGa7lx29hK5rsJhCft/oDV1l7+ECRc8=";
  };
  phases = [ "installPhase" ];
  installPhase = ''
    dest_dir=$out/share/fonts/truetype/
    mkdir -p $dest_dir
    cp $src $dest_dir
  '';
  meta = with lib; {
    description = "Cascadia Code with Japanese support.";
    homepage = "https://github.com/microsoft/cascadia-code";
    license = licenses.ofl;
    platforms = platforms.all;
  };
}
