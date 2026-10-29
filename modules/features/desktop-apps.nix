{
  flake.modules.homeManager.desktop-apps = {
    config,
    pkgs,
    ...
  }: let
    openGLApps = with pkgs; [
      google-chrome
      slack
    ];
  in {
    home.packages =
      map config.lib.nixGL.wrap openGLApps
      ++ (with pkgs; [
        firefox
        obsidian
        openscad
        meld
        speedcrunch
        spotify
        zeal
      ]);
  };
}
