{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  fetchurl,
  biz-ud-gothic,
  mplus-outline-fonts,
  noto-fonts-cjk-sans,
  crimson-pro,
  dm-sans,
  fraunces,
  ibm-plex,
  plus-jakarta-sans,
}:
let
  mkFont =
    {
      pname,
      owner,
      repo,
      rev,
      hash,
    }:
    stdenvNoCC.mkDerivation {
      inherit pname;
      version = builtins.substring 0 8 rev;
      src = fetchFromGitHub {
        inherit
          owner
          repo
          rev
          hash
          ;
      };
      dontBuild = true;
      installPhase = ''
        runHook preInstall
        dest=$out/share/fonts/truetype
        mkdir -p $dest
        find . -type f \( -name '*.ttf' -o -name '*.otf' \) -exec cp {} $dest \;
        runHook postInstall
      '';
      meta = {
        description = "${pname} font from Google Fonts";
        license = lib.licenses.ofl;
        platforms = lib.platforms.all;
      };
    };
in
[
  biz-ud-gothic
  mplus-outline-fonts.githubRelease
  noto-fonts-cjk-sans
  crimson-pro
  dm-sans
  fraunces
  ibm-plex
  plus-jakarta-sans
  (mkFont {
    pname = "zen-kakugothic";
    owner = "googlefonts";
    repo = "zen-kakugothic";
    rev = "2705757e17e42954f3acbdf921ac0ae24d1270cd";
    hash = "sha256-w0OA2w1t/PxMOZ/vkQU31nzFRgFcGcGe7stJ3XWq9UY=";
  })
  (mkFont {
    pname = "zen-marugothic";
    owner = "googlefonts";
    repo = "zen-marugothic";
    rev = "553c872b216d1290e2902a466edcdc9682f0df6a";
    hash = "sha256-nXoHrIISJQ83PrU+T6ksP257SLBydYXEye2V1cUQyM8=";
  })
  (mkFont {
    pname = "zen-oldmincho";
    owner = "googlefonts";
    repo = "zen-oldmincho";
    rev = "490d363e7886839ba1f86971cf874a1d70ad27f0";
    hash = "sha256-RalvmNRpIqy10g6aV7IIyJwnAOSJFUQhb/KDTIJ5rPo=";
  })
  (mkFont {
    pname = "kosugi-maru";
    owner = "googlefonts";
    repo = "kosugi-maru";
    rev = "bd22c671a9ffc10cc4313e6f2fd75f2b86d6b14b";
    hash = "sha256-gMilWV4t/yB3TtMe30IXHUlmSJDkD2THYUfbt3eT+h0=";
  })
  (mkFont {
    pname = "spacemono";
    owner = "googlefonts";
    repo = "spacemono";
    rev = "329858c2c4dbd3476f972a4ae00624b018cf4b81";
    hash = "sha256-qIeq90N3Mh8MBeZZp1QfBj33zTQNiv8k2vec1nFrdNY=";
  })
  (mkFont {
    pname = "unbounded";
    owner = "googlefonts";
    repo = "unbounded";
    rev = "f3ec43228a864a72487e41552e2140efab9884ea";
    hash = "sha256-PkO3A4asxlqSca9qGx7DrxbI6/OmS2itbgaTyVUdza4=";
  })
  (mkFont {
    pname = "playfair";
    owner = "googlefonts";
    repo = "playfair";
    rev = "a49f9f9dc9a2924641cefba3f5e33ac1c5aa4264";
    hash = "sha256-Il2qnr7js2OKFx8iEXQXIIdIwgAXPHLP1oX0kPDlXBY=";
  })
  (mkFont {
    pname = "shippori-mincho";
    owner = "fontdasu";
    repo = "ShipporiMincho";
    rev = "63431fee6c2cfea772325d6251d2935b7cfa7c6d";
    hash = "sha256-Bt8Bkgxt7Mjpy+Xv15UF882zA+nKRIwpnKNJ6jpeHrw=";
  })
  (mkFont {
    pname = "murecho";
    owner = "positype";
    repo = "Murecho-Project";
    rev = "0efba44c1c504efe50edc3ae30da5840461e5d49";
    hash = "sha256-l1m5tv9nfWaPF/wCPQCst1SXTUOS4CAe4a7rmfie/Jc=";
  })
  (mkFont {
    pname = "dela-gothic";
    owner = "syakuzen";
    repo = "DelaGothic";
    rev = "da8b03e57a8977132b3d0358c48c8463374c74ab";
    hash = "sha256-xbnbPk0fpuQUM9pYr4gIRQGAGM3DIZEHocO64TX3eNQ=";
  })
  (mkFont {
    pname = "kaisei-decol";
    owner = "Font-Kai";
    repo = "Kaisei-Decol";
    rev = "1b8a4e1a99f9b38602c17d9b400cbbf697c88a64";
    hash = "sha256-d1nlaB0nsX6RliNpEPOsoXUG3MsxCFMUR0cIc7JgcMc=";
  })
  (mkFont {
    pname = "outfit";
    owner = "Outfitio";
    repo = "Outfit-Fonts";
    rev = "902773808eb372f70fb34e8946dd1ffe604efc79";
    hash = "sha256-k7tAuUdZ6jjPesy1bTJ0mWIm7qXZp0r+cMvja0w2T60=";
  })
  (mkFont {
    pname = "sora";
    owner = "sora-xor";
    repo = "sora-font";
    rev = "7f9a9c5d0ccd1c099cfac420aa27133df1c5fdc4";
    hash = "sha256-35rMWYpO2tv0ZUYVskff6Gl9fUjTeGBA5AvcGnvFp40=";
  })
  (mkFont {
    pname = "bricolage";
    owner = "ateliertriay";
    repo = "bricolage";
    rev = "84745e5b96261ae5f8c6c856e262fe78d1d6efdd";
    hash = "sha256-K79ojosZqVg3S9cfBzI3d7ny+90cLCJq7W4XNotsP14=";
  })
  (mkFont {
    pname = "klee-one";
    owner = "fontworks-fonts";
    repo = "Klee";
    rev = "8b0532731b63ad8a445ca341d8d7d941079b83ab";
    hash = "sha256-zjiV6IeY/IdoqhrCJEze6sWo1+ZiDHlUNOm+PRhesaU=";
  })
  (stdenvNoCC.mkDerivation {
    pname = "manrope";
    version = "2025-04-14";
    src = fetchurl {
      url = "https://github.com/google/fonts/raw/fb629caaa15ad25c051089c98f09cf6c8e30a86b/ofl/manrope/Manrope%5Bwght%5D.ttf";
      name = "Manrope-variable.ttf";
      hash = "sha256-0GOb5F0K8255gXJBnXvRc8S9Tynit2y7adsdEb+LCkA=";
    };
    dontUnpack = true;
    installPhase = ''
      runHook preInstall
      dest=$out/share/fonts/truetype
      mkdir -p $dest
      cp $src $dest/Manrope-variable.ttf
      runHook postInstall
    '';
    meta = {
      description = "Manrope font from Google Fonts";
      license = lib.licenses.ofl;
      platforms = lib.platforms.all;
    };
  })
  (stdenvNoCC.mkDerivation {
    pname = "sawarabi-gothic";
    version = "2025-04-14";
    src = fetchurl {
      url = "https://github.com/google/fonts/raw/bf19077ade7be4fb171532fb14f94391406a01c6/ofl/sawarabigothic/SawarabiGothic-Regular.ttf";
      hash = "sha256-BPL5ERu2nLjTcGwntEh5wsD6xZOhHt9c/ozsHvySx4k=";
    };
    dontUnpack = true;
    installPhase = ''
      runHook preInstall
      dest=$out/share/fonts/truetype
      mkdir -p $dest
      cp $src $dest/SawarabiGothic-Regular.ttf
      runHook postInstall
    '';
    meta = {
      description = "Sawarabi Gothic font from Google Fonts";
      license = lib.licenses.ofl;
      platforms = lib.platforms.all;
    };
  })
]
