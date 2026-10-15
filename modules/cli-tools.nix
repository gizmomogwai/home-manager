{ inputs, ... }:
{
  flake.modules.homeManager.cli-tools = { pkgs, ... }: {
    home.packages = with pkgs; [
      babelfish
      byobu
      devenv
      # dropbox
      fd
      firefox
      ffmpeg
      fzf
      gdu
      gh
      git
      git-lfs
      git-repo
      google-chrome
      htop
      httpie
      jq
      jujutsu
      just
      jj-starship
      lazyjj
      lua
      moor
      pandoc
      proton-cli
      proton-pass
      rclone
      ripgrep
      rsync
      rtk
      slack
      spotify
      inputs.spotify-dl.packages.${stdenv.hostPlatform.system}.default
      tealdeer
      tig
      tree
      zeal
    ];
    home.sessionVariables.CARGO_TARGET_DIR = "/tmp/cargo-target";
  };
}
