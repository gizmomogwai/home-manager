{config, ...}: {
  flake.homeConfigurations."gizmo@cks-m4" = config.mkHome {
    system = "aarch64-darwin";
    user = "gizmo";
    homeDirectory = "/Users/gizmo";
    modules = with config.flake.modules.homeManager; [
      common
      darwin
      ({pkgs, ...}: {
        home.packages = [
        ];
      })
    ];
  };
}
