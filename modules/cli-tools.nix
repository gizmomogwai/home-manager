{inputs, ...}: {
  flake.modules.homeManager.cli-tools = {pkgs, ...}: {
    home.packages = with pkgs; [
      alejandra
      babelfish
      byobu
      devenv
      inputs.donies.packages.${stdenv.hostPlatform.system}.default
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
      nix-tree
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
  };
}
