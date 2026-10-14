{ config, ... }:
{
  flake.homeConfigurations."gizmo@flunder" = config.mkHome {
    system = "x86_64-linux";
    user = "gizmo";
    homeDirectory = "/home/gizmo";
    # shortcut: ghostty is not nixGL-wrapped here yet (no nixGL.packages set), add it like nixgl-nvidia when on this machine
    modules = with config.flake.modules.homeManager; [ common linux nixgl-intel ];
  };
}
