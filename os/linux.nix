{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    dive
    evince
    rmpc
    rofi
    rofi-calc
    spotify
    taglib
    vicinae
    vlc
    zeal
  ];
}
