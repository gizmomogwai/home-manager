{
  flake.modules.homeManager.fonts = { pkgs, ... }: {
    home.packages = with pkgs; [
      iosevka-bin
      nerd-fonts.iosevka-term
    ];
    fonts.fontconfig.enable = true;
  };
}
