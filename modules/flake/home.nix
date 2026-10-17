{
  config,
  inputs,
  lib,
  ...
}: {
  options = {
    overlays = lib.mkOption {
      type = lib.types.listOf lib.types.raw;
      default = [];
      description = "nixpkgs overlays applied to every homeConfiguration.";
    };
    mkHome = lib.mkOption {
      type = lib.types.raw;
      readOnly = true;
      description = "{ system, user, homeDirectory, modules } -> homeConfiguration";
    };
  };

  config = {
    mkHome = {
      system,
      user,
      homeDirectory,
      modules,
    }:
      inputs.home-manager.lib.homeManagerConfiguration {
        pkgs = import inputs.nixpkgs {
          inherit system;
          inherit (config) overlays;
          config.allowUnfree = true;
        };
        modules =
          [
            {
              home.username = user;
              home.homeDirectory = homeDirectory;
            }
          ]
          ++ modules;
      };
  };
}
