final: prev: {
  tmux = prev.tmux.overrideAttrs (old: rec {
    version = "git-${src.rev}";
    src = prev.fetchFromGitHub {
      owner = "tmux";
      repo = "tmux";
      rev = "449f255f3ef0167c6d226148cdaabac70686dde9";
      hash = "sha256-tBh84C7Kt3qjV4oZOcL05dVvBNMFtiCF45uogZvYxiY=";
    };
  });
}
