{
  flake.modules.homeManager.linux = {
    config,
    pkgs,
    ...
  }: {
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
    services.picom = {
      enable = true;
      package = config.lib.nixGL.wrap pkgs.picom-pijulius;
      backend = "glx";
      shadow = true;
      settings.corner-radius = 10;
    };
    # non-NixOS: puts ~/.nix-profile/share into XDG_DATA_DIRS so rofi drun sees home-manager .desktop files
    targets.genericLinux.enable = true;
  };
}
