{
  flake.modules.homeManager.desktop-apps = {pkgs, ...}: {
    home.packages = with pkgs; [
      firefox
      google-chrome
      slack
      spotify
      zeal
    ];
  };
}
