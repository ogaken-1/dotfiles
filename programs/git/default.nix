{ userInfo, ... }:
{
  programs.git = {
    enable = true;
    lfs.enable = true;
    ignores = [
      "**/.envrc"
      "**/.DS_Store"
      "**/.direnv"
      "**/.serena"
      "**/.claude"
    ];
    settings = {
      alias = {
        clean-branches = "! git branch --format='%(refname:short) %(upstream:track)' | grep '\\[gone\\]' | awk '{ print $1 }' | xargs git branch -D";
      };
      credential = {
        helper = "store";
      };
      init = {
        defaultBranch = "main";
      };
      log = {
        follow = true;
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
        name = userInfo.fullName;
        # 1. Use direnv to set email via $GIT_AUTHOR_EMAIL and $GIT_COMMITTER_EMAIL.
        signingKey = userInfo.signingKey;
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
  programs.delta = {
    enable = true;
    enableGitIntegration = true;
  };
}
