{
  flake.modules.homeManager.darwin = {pkgs, ...}: {
    home.packages = with pkgs; [
      choose-gui
      kanata
      raycast
      vlc-bin
    ];
    home.sessionVariables = {
      CK_OS = "osx";
    };
  };
}
