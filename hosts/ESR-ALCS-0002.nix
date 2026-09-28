{ pkgs, ... }:
{
  home.packages = [
    pkgs.nixgl.auto.nixGLDefault
  ];
}
