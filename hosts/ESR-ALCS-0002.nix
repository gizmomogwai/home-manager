{ pkgs, ... }:
{
  home.packages = [
    (pkgs.nixgl.nvidiaPackages { version = "595.84"; }).nixGLNvidia
  ];
}
