{ inputs, ... }:
{
  imports = [
    # flake.modules.<class>.<name>
    inputs.flake-parts.flakeModules.modules
    # flake.homeConfigurations (mergeable across host files)
    inputs.home-manager.flakeModules.home-manager
  ];
  systems = [ "aarch64-darwin" "x86_64-linux" ];

  perSystem = { system, ... }: {
    packages.home-manager = inputs.home-manager.packages.${system}.home-manager;
  };
}
