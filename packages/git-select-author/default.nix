{
  lib,
  stdenvNoCC,
  ...
}:
stdenvNoCC.mkDerivation rec {
  pname = "git-select-author";
  version = "0.1.0";
  src = ./git-select-author;
  phases = [ "installPhase" ];
  installPhase = ''
    dest=$out/bin
    mkdir -p $dest
    install -m 755 $src $dest/${pname}
  '';
  meta = with lib; {
    description = "Select git author in repository with fzf";
    version = version;
    license = licenses.mit;
    platforms = platforms.all;
  };
}
