{config, ...}: {
  flake.homeConfigurations."gizmo@flunder" = config.mkHome {
    system = "x86_64-linux";
    user = "gizmo";
    homeDirectory = "/home/gizmo";
    modules = with config.flake.modules.homeManager; [common linux nixgl-intel];
  };
}
