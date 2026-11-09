{inputs, ...}: {
  flake.modules.homeManager.own-apps = {
    config,
    pkgs,
    ...
  }: let
    app = name: inputs.${name}.packages.${pkgs.stdenv.hostPlatform.system}.default;
    openGLApps = [
      "fuzzed-gui"
      "viewed"
    ];
  in {
    home.packages =
      map (name: config.lib.nixGL.wrap (app name)) openGLApps
      ++ map app [
        "dime"
        "donies"
        "sesame"
        "spotify-dl"
        "worker"
      ];
  };
}
