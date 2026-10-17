{
  flake.modules.homeManager.desktop-apps = {pkgs, ...}: {
    home.packages = with pkgs; [
      bambu-studio
      firefox
      google-chrome
      openscad
      slack
      spotify
      zeal
    ];
  };
}
