{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    babelfish
    claude-code
    devbox
    devenv
    direnv
    dive
#    emacs-unstable
    eask-cli # like cask for emacs
    emacs
#      emacsPackages.cask
    enchant
    evince
    fd
    firefox
    fish
    gdu
    gh
    ghostty
    gimp
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
#    opencode
#    openvpn
    pandoc
    quodlibet
    rclone
    ripgrep
    rmpc
    rofi
    rofi-calc
    spotify
    taglib
    tig
    tree
    typst
    vlc
    zeal
  ];
}
  #      rust-bin.stable."1.93.1".default
