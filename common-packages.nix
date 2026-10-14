{ config, pkgs, inputs, ... }:
{
  programs.fish = {
    enable = true;
    plugins = [
      {
        name = "fisher-package";
        src = inputs.fisher-package;
      }
    ];
    shellAliases = {
      less = "moor";
    };
    interactiveShellInit = ''
      # inherited (exported) guard from a parent shell would make nix-daemon.fish skip PATH setup
      set -e __ETC_PROFILE_NIX_SOURCED
      if test -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish
        source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish
      else if test -e ~/.nix-profile/etc/profile.d/nix-daemon.fish
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

  home.sessionPath = ["$HOME/bin"];
  home.packages = with pkgs; [
    (writeShellScriptBin "magit" ''
      ${emacs}/bin/emacs -nw --eval "(progn (if (locate-dominating-file default-directory \".jj\") (jj-log) (magit-status)) (delete-other-windows))"
    '')
    (writeShellScriptBin "start-bookmark" ''
      # rofi is linux-only and choose-gui darwin-only in nixpkgs, so only the host's picker is interpolated
      # optional args override the picker, e.g. `start-bookmark fzf --exact`
      [ $# -eq 0 ] && set -- ${if stdenv.hostPlatform.isDarwin then lib.getExe choose-gui else "${lib.getExe rofi} -dmenu"}
      line=$(extract-bookmarks-d | "$@") || exit 0
      # url is the last field (strip longest prefix ending in '|'); bookmarks without folder have only "title|url"
      url=''${line##*|}
      echo "$url"
      ${if stdenv.hostPlatform.isDarwin then "open" else "xdg-open"} "$url"
    '')
    age
    babelfish
    byobu
    claude-code
    devenv
    inputs.dime.packages.${pkgs.stdenv.hostPlatform.system}.default
    # dropbox
    eask-cli # like cask for emacs
    emacs
    enchant
    inputs.extract-bookmarks-d.packages.${pkgs.stdenv.hostPlatform.system}.default
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
    hunspell
    joe
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
    inputs.sesame.packages.${pkgs.stdenv.hostPlatform.system}.default
    slack
    tealdeer
    tig
    tree
    inputs.worker.packages.${pkgs.stdenv.hostPlatform.system}.default
    zeal

    # fonts
    iosevka-bin
    nerd-fonts.iosevka-term

    # dlang
    dub
    ldc
  ];

  home.sessionVariables = {
    EDITOR = "joe";
    CARGO_TARGET_DIR = "/tmp/cargo-target";
  };

  fonts.fontconfig.enable = true;
}
