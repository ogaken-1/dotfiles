{ pkgs }:
let
  rev = "82bb15e6410095883f28d92025a61937fa80aa09";
  repo = "zeno.zsh";
in
pkgs.stdenvNoCC.mkDerivation {
  pname = repo;
  version = "git-${rev}";
  src = pkgs.fetchFromGitHub {
    owner = "yuki-yano";
    repo = repo;
    rev = rev;
    hash = "sha256-+sDhfZIqQNoDbfA1uNIiS2rl8U6cWtPD4Z14TAec9kw=";
  };
  dontBuild = true;
  postPatch = ''
    sed --in-place '3s/\\$/ --allow-ffi \\/' shells/fish/functions/zeno.fish
    sed --in-place '3s/\\$/ --allow-ffi \\/' shells/fish/functions/zeno-server.fish
    substituteInPlace bin/zeno-server \
      --replace-fail '/usr/bin/env zsh' ${pkgs.zsh}/bin/zsh
    substituteInPlace bin/zeno \
      --replace-fail '/usr/bin/env zsh' ${pkgs.zsh}/bin/zsh
  '';
  installPhase = ''
        runHook preInstall

        mkdir -p $out/share/fish/vendor_functions.d
        cp shells/fish/functions/*.fish $out/share/fish/vendor_functions.d/

        mkdir -p $out/share/zeno
        cp -r src $out/share/zeno/
        cp deno.json $out/share/zeno/

        mkdir -p $out/share/zeno/bin
        cp bin/* $out/share/zeno/bin/

        mkdir -p $out/share/fish/vendor_conf.d
        cat > $out/share/fish/vendor_conf.d/zeno.fish <<EOF
    # MIT License
    # Copyright (c) 2021 Yuki Yano
    # https://github.com/yuki-yano/zeno.zsh/blob/main/LICENSE
    set -gx ZENO_ROOT $out/share/zeno
    set -gx ZENO_FZF_COMMAND ${pkgs.fzf}/bin/fzf

    if not set -q ZENO_DISABLE_EXECUTE_CACHE_COMMAND
      command ${pkgs.deno}/bin/deno cache \
        --unstable-byonm \
        --no-lock \
        --no-check \
        \$ZENO_ROOT/src/cli.ts
    end

    zeno-enable-sock

    function __zeno_on_pwd_change --on-variable PWD
      zeno-onchpwd
    end

    function __zeno_on_exit --on-event fish_exit
      zeno-stop-server
    end

    function __zeno_set_pid --on-event fish_prompt
      zeno-set-pid
    end

    set -gx ZENO_ENABLE 1
    set -gx ZENO_LOADED 1
    EOF

        runHook postInstall
  '';
}
