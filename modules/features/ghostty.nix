{
  flake.modules.homeManager.ghostty = {
    config,
    pkgs,
    ...
  }: {
    home.packages = [
      (
        if pkgs.stdenv.hostPlatform.isDarwin
        then pkgs.ghostty-bin
        else config.lib.nixGL.wrap pkgs.ghostty
      )
    ];
  };
}
