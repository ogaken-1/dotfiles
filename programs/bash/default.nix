{
  programs.bash = {
    enable = true;
    initExtra = ''
      if [[ -n "''${CLAUDECODE:-}" ]]; then
        set -o pipefail
      fi
    '';
  };
}
