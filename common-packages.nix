{ config, pkgs, ... }:
{
  programs.fish = {
    enable = true;
  };

  programs.direnv = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.starship = {
    enable = true;
    enableFishIntegration = true;
  };

  home.packages = with pkgs; [
    babelfish
    byobu
    claude-code
    devenv
    eask-cli # like cask for emacs
    emacs
    enchant
    fd
    firefox
    fzf
    gdu
    gh
    git
    git-lfs
    google-chrome
    htop
    httpie
    hunspell
    joe
    jq
    jujutsu
    just
    lazyjj
    lua
    moor
    pandoc
    rclone
    ripgrep
    tig
    tree
    typst
    zeal
  ];
}
