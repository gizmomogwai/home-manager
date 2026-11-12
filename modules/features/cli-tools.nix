{inputs, ...}: {
  flake.modules.homeManager.cli-tools = {
    config,
    lib,
    pkgs,
    ...
  }: let
    zellij-unwrapped = pkgs.zellij-unwrapped.overrideAttrs {
      version = "0.46.0";
      src = inputs.zellij;
      cargoHash = "sha256-i3Vh7w9YeGUkGIsbqA2UIiLtMqsSC+/ehdSDIfTckM8=";
    };
    zellij =
      if pkgs.stdenv.hostPlatform.isLinux
      then
        config.lib.nixGL.wrap (pkgs.symlinkJoin {
          pname = "zellij";
          inherit (zellij-unwrapped) version meta;
          paths = [zellij-unwrapped];
          nativeBuildInputs = [pkgs.makeWrapper];
          postBuild = ''
            wrapProgram "$out/bin/zellij" \
              --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath (with pkgs; [
              libX11
              libXcursor
              libXi
              libXrandr
              libxkbcommon
              wayland
              fontconfig
            ])}"
          '';
        })
      else zellij-unwrapped;
    diskonaut = pkgs.rustPlatform.buildRustPackage {
      pname = "diskonaut-ng";
      version = "0.13.2";
      src = inputs.diskonaut;
      cargoLock.lockFile = "${inputs.diskonaut}/Cargo.lock";
      meta = {
        description = "Terminal disk space navigator";
        homepage = "https://github.com/neunenak/diskonaut";
        license = lib.licenses.mit;
        mainProgram = "diskonaut";
      };
    };
  in {
    home.packages = with pkgs; [
      alejandra
      babelfish
      byobu
      devenv
      ditaa
      fastfetch
      fd
      ffmpeg
      fzf
      gdu
      gh
      git
      git-lfs
      git-repo
      htop
      httpie
      jq
      jujutsu
      just
      jj-starship
      lazyjj
      lua
      nix-tree
      nvd
      pandoc
      rclone
      ripgrep
      rsync
      rtk
      tealdeer
      tig
      tree
      zellij
      diskonaut
    ];
  };
}
