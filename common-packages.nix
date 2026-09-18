{ config, pkgs, ... }:
{
  programs.fish = {
    enable = true;
  };

  home.packages = with pkgs; [
    babelfish
    claude-code
    devenv
    direnv
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
    helix
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
