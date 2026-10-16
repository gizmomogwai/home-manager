{inputs, ...}: {
  flake.modules.homeManager.apps-own = {pkgs, ...}: {
    home.packages = map (app: inputs.${app}.packages.${pkgs.stdenv.hostPlatform.system}.default) [
      "dime"
      "sesame"
      "worker"
    ];
  };
}
