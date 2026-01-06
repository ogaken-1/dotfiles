{ pkgs, ... }:
let
  npiperelay = pkgs.callPackage ../pkgs/npiperelay.nix { };
in
{
  home.sessionVariables = {
    SSH_AUTH_SOCK = "\${XDG_RUNTIME_DIR}/ssh-agent.sock";
  };
  systemd.user.services.ssh-agent-relay = {
    Unit = {
      Description = "SSH Agent Relay to Windows";
      StartLimitIntervalSec = 0;
    };
    Service = {
      Type = "exec";
      KillMode = "process";
      ExecStart = "${pkgs.socat}/bin/socat UNIX-LISTEN:%t/ssh-agent.sock,fork EXEC:\"${npiperelay}/bin/npiperelay.exe -ei -s //./pipe/openssh-ssh-agent\",nofork";
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };
}
