{
  programs.git = {
    enable = true;
    delta = {
      enable = true;
    };
    lfs.enable = true;
    ignores = [
      "**/.envrc"
      "**/.DS_Store"
      "**/.direnv"
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
        gpgSign = true;
      };
      tag = {
        gpgSign = true;
      };
      gpg = {
        format = "ssh";
        ssh = {
          allowedSignersFile = "~/.ssh/allowed_signers";
        };
      };
      user = {
        name = "Kento Ogata";
        # 1. Use direnv to set email via $GIT_AUTHOR_EMAIL and $GIT_COMMITTER_EMAIL.
        # 2. Set `user.signingKey` by `git config` command.
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
      rerere = {
        enabled = true;
      };
      delta = {
        navigate = true;
      };
    };
  };
}
