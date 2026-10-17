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
        # wraps binary plus .desktop and D-Bus service, so launchers also get GL;
        # identity when targets.genericLinux.nixGL.packages is unset (e.g. flunder)
        else config.lib.nixGL.wrap pkgs.ghostty
      )
    ];
  };
}
