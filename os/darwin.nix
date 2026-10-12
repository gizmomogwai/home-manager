{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    choose-gui
    ghostty-bin
    kanata
    raycast
  ];
  home.sessionVariables = {
    CK_OS = "osx";
  };

}
