{
  flake.modules.homeManager.dlang = {pkgs, ...}: {
    home.packages = with pkgs; [
      dub
      ldc
    ];
  };
}
