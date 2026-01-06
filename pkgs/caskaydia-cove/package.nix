{
  lib,
  stdenvNoCC,
  fetchurl,
  ...
}:
stdenvNoCC.mkDerivation rec {
  pname = "caskaydia-cove";
  version = "3.3.0";
  src = fetchurl {
    url = "https://github.com/ryanoasis/nerd-fonts/releases/download/v${version}/CascadiaCode.tar.xz";
    hash = "sha256-hqweFhmf6cNEiniC5PPpDBHCc5b9R3HFUmYWSOPRj5Y=";
  };
  phases = [
    "unpackPhase"
    "installPhase"
  ];
  unpackPhase = ''
    mkdir -p ./fonts
    tar -xf $src -C ./fonts
  '';
  installPhase = ''
    dest_dir=$out/share/fonts/truetype
    mkdir -p $dest_dir
    cp ./fonts/*.ttf -t $dest_dir
  '';
  meta = with lib; {
    description = "Patched Cascadia Code by nerd-fonts";
    homepage = "https://www.nerdfonts.com";
    version = version;
    license = licenses.mit;
    platforms = platforms.all;
  };
}
