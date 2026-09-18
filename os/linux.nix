{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    dive
    evince
    ghostty
    gimp
    rmpc
    rofi
    rofi-calc
    spotify
    taglib
    vicinae
    vlc
  ];
}
