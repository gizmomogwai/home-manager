{
  flake.modules.homeManager.desktop-apps = {pkgs, ...}: {
    home.packages = with pkgs; [
      firefox
      google-chrome
      openscad
      meld
      slack
      speedcrunch
      spotify
      zeal
    ];
  };
}
