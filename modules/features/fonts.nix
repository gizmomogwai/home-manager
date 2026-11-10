{
  flake.modules.homeManager.fonts = {
    config,
    pkgs,
    lib,
    ...
  }: let
    nordwand-mono = pkgs.stdenvNoCC.mkDerivation rec {
      pname = "nordwand-mono";
      version = "1.3.4";

      src = pkgs.fetchzip {
        url = "https://github.com/tywr/Nordwand-Mono/releases/download/${version}/NordwandMono-TTF.zip";
        stripRoot = false; # the zip has no top-level directory
        hash = "sha256-PnWIg43vKHbSDk68YfH0NafqGDCZym8440aK/ouhOLw=";
      };

      installPhase = ''
        runHook preInstall
        install -Dm644 --target-directory=$out/share/fonts/truetype *.ttf
        runHook postInstall
      '';

      meta = {
        description = "Nordwand Mono font";
        homepage = "https://github.com/tywr/Nordwand-Mono";
        license = lib.licenses.ofl;
        platforms = lib.platforms.all;
      };
    };
  in {
    home.packages = with pkgs; [
      inter
      iosevka-bin
      nerd-fonts.iosevka-term
      nordwand-mono
    ];
    fonts.fontconfig.enable = true;
    # Font of the picker GUI (clay-selector reads ~/.config/picker/font.ttf).
    xdg.configFile."picker/font.ttf".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.profileDirectory}/share/fonts/truetype/InterVariable.ttf";
  };
}
