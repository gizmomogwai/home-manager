{
  flake.modules.homeManager.secrets = {pkgs, ...}: {
    programs.fish.interactiveShellInit = ''
      set -x SPOTIFY_CLIENT_ID (${pkgs.age}/bin/age --decrypt --identity=$HOME/.config/age/christian.koestlin@gmail.com $HOME/.config/api-keys/spotify-client-id.encrypted)
      set -x SPOTIFY_CLIENT_SECRET (${pkgs.age}/bin/age --decrypt --identity=$HOME/.config/age/christian.koestlin@gmail.com $HOME/.config/api-keys/spotify-client-secret.encrypted)
      set -x TONIES_EMAIL (${pkgs.age}/bin/age --decrypt --identity=$HOME/.config/age/christian.koestlin@gmail.com $HOME/.config/api-keys/tonies-email.encrypted)
      set -x TONIES_PASSWORD (${pkgs.age}/bin/age --decrypt --identity=$HOME/.config/age/christian.koestlin@gmail.com $HOME/.config/api-keys/tonies-password.encrypted)
      set -x christian_koestlin_gerrit_password (${pkgs.age}/bin/age --decrypt --identity=$HOME/.config/age/christian.koestlin@gmail.com $HOME/.config/api-keys/christian.koestlin@gerrit-password.encrypted)
      set -x christian_koestlin_hcp5_sources_password (${pkgs.age}/bin/age --decrypt --identity=$HOME/.config/age/christian.koestlin@gmail.com $HOME/.config/api-keys/christian.koestlin@hcp5-sources-password.encrypted)
    '';
    home.packages = [pkgs.age];
  };
}
