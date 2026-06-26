{
  writeShellApplication,
  coreutils,
  curl,
  jq,
}:
writeShellApplication {
  name = "nerv";
  runtimeInputs = [
    coreutils
    curl
    jq
  ];
  text = ''
    nerv_jq="${./nerv.jq}"
    ${builtins.readFile ./nerv.sh}
  '';
  derivationArgs = {
    postInstall = ''
      install -Dm644 ${./completion.fish} $out/share/fish/vendor_completions.d/nerv.fish
    '';
  };
}
