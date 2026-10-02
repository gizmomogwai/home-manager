{ config, pkgs, ... }:
{
  programs.fish = {
    enable = true;
    shellAliases = {
      less = "moor";
    };
    interactiveShellInit = ''
      if test -e ~/.nix-profile/etc/profile.d/nix-daemon.fish
        source ~/.nix-profile/etc/profile.d/nix-daemon.fish
      end
      set -x SPOTIFY_CLIENT_ID (${pkgs.age}/bin/age --decrypt --identity=$HOME/.config/age/christian.koestlin@gmail.com $HOME/.config/api-keys/spotify-client-id.encrypted)
      set -x SPOTIFY_CLIENT_SECRET (${pkgs.age}/bin/age --decrypt --identity=$HOME/.config/age/christian.koestlin@gmail.com $HOME/.config/api-keys/spotify-client-secret.encrypted)
      set -x TONIES_EMAIL (${pkgs.age}/bin/age --decrypt --identity=$HOME/.config/age/christian.koestlin@gmail.com $HOME/.config/api-keys/tonies-email.encrypted)
      set -x TONIES_PASSWORD (${pkgs.age}/bin/age --decrypt --identity=$HOME/.config/age/christian.koestlin@gmail.com $HOME/.config/api-keys/tonies-password.encrypted)
      set -x christian_koestlin_gerrit_password (${pkgs.age}/bin/age --decrypt --identity=$HOME/.config/age/christian.koestlin@gmail.com $HOME/.config/api-keys/christian.koestlin@gerrit-password.encrypted)
      set -x christian_koestlin_hcp5_sources_password (${pkgs.age}/bin/age --decrypt --identity=$HOME/.config/age/christian.koestlin@gmail.com $HOME/.config/api-keys/christian.koestlin@hcp5-sources-password.encrypted)
      set -x STARDICT_DATA_DIR ~/Sync/configs/stardict
    '';
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
    (writeShellScriptBin "magit" ''
      ${emacs}/bin/emacs -nw --eval "(progn (if (locate-dominating-file default-directory \".jj\") (jj-log) (magit-status)) (delete-other-windows))"
    '')
    age
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
