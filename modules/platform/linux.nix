{
  flake.modules.homeManager.linux = {pkgs, ...}: {
    home.packages = with pkgs; [
#      bambu-studio
#      dive
      evince
      gimp
      rmpc
      rofi
      rofi-calc
      taglib
      vlc
    ];
    home.sessionVariables = {
      CK_OS = "linux";
    };
    # non-NixOS: puts ~/.nix-profile/share into XDG_DATA_DIRS so rofi drun sees home-manager .desktop files
    targets.genericLinux.enable = true;
  };
}
