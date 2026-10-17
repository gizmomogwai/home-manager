{inputs, ...}: {
  flake.modules.homeManager.own-apps = {pkgs, ...}: {
    home.packages = map (app: inputs.${app}.packages.${pkgs.stdenv.hostPlatform.system}.default) [
      "dime"
      "sesame"
      "worker"
    ];
  };
}
