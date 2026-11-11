{
  flake.modules.homeManager.global-cargo-settings = {
    lib,
    pkgs,
    ...
  }: let
    dev-build = pkgs.writeShellApplication {
      name = "dev-build";
      runtimeInputs = [pkgs.gnugrep];
      text = builtins.readFile ./global-cargo-settings/dev-build.sh;
      checkPhase = ''
        ${pkgs.shellcheck}/bin/shellcheck "$target"
        ${pkgs.python3}/bin/python ${./global-cargo-settings/test-dev-build.py} ${./global-cargo-settings/dev-build.sh}
      '';
    };
  in {
    home.sessionVariables.CARGO_TARGET_DIR = "/tmp/cargo-target";

    home.packages = lib.mkIf pkgs.stdenv.hostPlatform.isLinux [dev-build];
    systemd.user.slices = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
      devbuild = {
        Unit.Description = "Low-priority development sessions";
        Slice.CPUWeight = 10;
      };
    };
    programs.fish.functions = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
      devenv = {
        wraps = "devenv";
        body = ''
          set --local executable (command --search devenv)
          or begin
            printf 'devenv executable not found on PATH.\n' >&2
            return 127
          end
          ${lib.getExe dev-build} $executable $argv
        '';
      };
      nix = {
        wraps = "nix";
        body = ''
          set --local executable (command --search nix)
          or begin
            printf 'nix executable not found on PATH.\n' >&2
            return 127
          end
          switch "$argv[1]"
            case develop
              ${lib.getExe dev-build} $executable $argv
            case '*'
              command $executable $argv
          end
        '';
      };
    };
  };
}
