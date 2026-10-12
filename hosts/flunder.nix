{ pkgs, ... }:
{
  home.packages = [
    pkgs.nixgl.nixGLIntel
    pkgs.ghostty # shortcut: not nixGL-wrapped yet, wrap like ESR-ALCS-0002 when on this machine
  ];
}
