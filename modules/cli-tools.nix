{inputs, ...}: {
  flake.modules.homeManager.cli-tools = {pkgs, ...}: {
    home.packages = with pkgs; [
      alejandra
      babelfish
      byobu
      devenv
      inputs.donies.packages.${stdenv.hostPlatform.system}.default
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
      pandoc
      rclone
      ripgrep
      rsync
      rtk
      inputs.spotify-dl.packages.${stdenv.hostPlatform.system}.default
      tealdeer
      tig
      tree
    ];
  };
}
