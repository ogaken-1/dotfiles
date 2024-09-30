{
  programs.git = {
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
}
