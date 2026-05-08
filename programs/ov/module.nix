{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.ov;
  ov = lib.getExe cfg.package;
  delta = lib.getExe config.programs.delta.package;
in
{
  options.programs.ov = {
    enable = lib.mkEnableOption "ov terminal pager";
    package = lib.mkPackageOption pkgs "ov" { };
    defaultPager = lib.mkEnableOption "setting ov as the default PAGER" // {
      default = true;
    };
    manIntegration.enable = lib.mkEnableOption "man pager integration (MANPAGER)" // {
      default = true;
    };
    batIntegration.enable = lib.mkEnableOption "bat pager integration (BAT_PAGER)" // {
      default = config.programs.bat.enable;
    };
    gitIntegration.enable = lib.mkEnableOption "git pager integration" // {
      default = config.programs.git.enable;
    };
    psqlIntegration.enable = lib.mkEnableOption "psql pager integration (PSQL_PAGER)";
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      # Base: install package and ov config
      {
        home.packages = [ cfg.package ];

        # Style settings for man pages (overstrike/overline rendering)
        xdg.configFile."ov/config.yaml".text = builtins.concatStringsSep "\n" [
          "StyleOverStrike:"
          "  Foreground: \"aqua\""
          "  Bold: true"
          "StyleOverLine:"
          "  Foreground: \"red\""
          "  Underline: true"
        ];
      }

      # PAGER
      (lib.mkIf cfg.defaultPager {
        home.sessionVariables.PAGER = lib.mkDefault ov;
      })

      # man
      (lib.mkIf cfg.manIntegration.enable {
        home.sessionVariables.MANPAGER = lib.mkDefault "${ov} --section-delimiter '^[^\\s]' --section-header";
      })

      # bat
      (lib.mkIf cfg.batIntegration.enable {
        home.sessionVariables.BAT_PAGER = lib.mkDefault "${ov} -F -H3";
      })

      # git with delta: use iniContent to override delta's pager.diff/log
      (lib.mkIf (cfg.gitIntegration.enable && config.programs.delta.enable) {
        programs.git.iniContent = {
          delta.pager = "${ov} -F";
          pager = {
            diff = lib.mkForce "${delta} --pager '${ov} -F --section-delimiter \"^diff\" --section-header'";
            log = lib.mkForce "${delta} --pager '${ov} -F --section-delimiter \"^commit\" --section-header-num 3'";
          };
        };
      })

      # git without delta
      (lib.mkIf (cfg.gitIntegration.enable && !config.programs.delta.enable) {
        programs.git.settings.pager = {
          diff = "${ov} -F --section-delimiter '^diff'";
          log = "${ov} -F --section-delimiter '^commit' --section-header-num 3";
        };
      })

      # psql
      (lib.mkIf cfg.psqlIntegration.enable (
        let
          psqlPager = pkgs.writeShellScript "psql-pager" ''
            exec ${ov} -F -C -d '|' -H1 --column-rainbow --align "$@"
          '';
        in
        {
          home.sessionVariables.PSQL_PAGER = lib.mkDefault "${psqlPager}";
        }
      ))

      # NOTE: The following tools have ov integration examples but require
      # their own config files or shell aliases, which are outside the scope
      # of this module:
      #   - mysql/mycli: [client] pager=... in ~/.my.cnf
      #   - pgcli: pager = ... in ~/.config/pgcli/config
      #   - procs: [pager] command = ... in procs config
      #   - top: top -b -c -w512 | ov ... (shell alias)
      #   - ps: ps aux | ov ... (shell alias)
    ]
  );
}
