{ config, pkgs, ... }:
{
  home = {
    username = "ogaken";
    homeDirectory = "/home/ogaken";
    stateVersion = "24.05";
    packages = with pkgs; [
      azure-cli
      bc
      deno
      direnv
      fd
      fzf
      gcc14
      ghq
      gnumake
      gnupg
      gopls
      kubectl
      lua-language-server
      nil
      nix-direnv
      postgresql_16
      ripgrep
      stylua
      tailscale
      tmux
      trash-cli
      vim
      vscode-langservers-extracted
      wget
      yaml-language-server
    ];
  };
  programs = {
    home-manager.enable = true;
    neovim = {
      enable = true;
      defaultEditor = true;
    };
    git = {
      enable = true;
      delta = {
        enable = true;
      };
      ignores = [
        "**/.envrc"
        "**/.DS_Store"
      ];
      aliases = {
        clean-branches = "! git branch --format='%(refname:short) %(upstream:track)' | grep '\\[gone\\]' | awk '{ print $1 }' | xargs git branch -D";
      };
      extraConfig = {
        credential = {
          helper = "store";
        };
        init = {
          defaultBranch = "main";
        };
        ghq = {
          root = "~/repos";
        };
        commit = {
          verbose = "true";
        };
        user = {
          name = "Kento Ogata";
          # Use direnv to set email via $GIT_AUTHOR_EMAIL and $GIT_COMMITTER_EMAIL
        };
        pull = {
          rebase = true;
        };
        rebase = {
          autoSquash = true;
          autoStash = true;
        };
        fetch = {
          prune = true;
        };
        merge = {
          conflictStyle = "diff3";
        };
        diff = {
          colorMoved = "default";
        };
        delta = {
          navigate = true;
        };
      };
    };
    gh = {
      gitCredentialHelper = {
        enable = true;
      };
    };
  };
}
