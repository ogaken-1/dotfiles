{
  home.file = {
    ".config/nvim/" = {
      source = ./config.d;
      recursive = true;
    };
  };
  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };
}
