{ config, pkgs, ... }:
{
  home = {
    username = "christian.koestlin";
    homeDirectory = "/Users/christian.koestlin";
    stateVersion = "25.05";

    file = {};

    sessionVariables = {
      EDITOR = "joe";
    };

    enableNixpkgsReleaseCheck = false;
  };
  programs = {
    home-manager.enable = true;
  };
}
