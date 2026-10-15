{
  flake.modules.homeManager.linux = { pkgs, ... }: {
    home.packages = with pkgs; [
      dive
      evince
      gimp
      rmpc
      rofi
      rofi-calc
      taglib
      vicinae
      vlc
    ];
    home.sessionVariables = {
      CK_OS = "linux";
    };
    # non-NixOS: puts ~/.nix-profile/share into XDG_DATA_DIRS so rofi drun sees home-manager .desktop files
    targets.genericLinux.enable = true;
  };
}
