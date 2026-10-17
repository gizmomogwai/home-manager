{
  flake.modules.homeManager.proton-pass = {pkgs, ...}: {
    home.packages = with pkgs; [
      proton-cli
      proton-pass
    ];
  };
}
