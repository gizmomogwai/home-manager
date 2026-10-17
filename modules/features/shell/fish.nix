{inputs, ...}: {
  flake.modules.homeManager.fish = {pkgs, ...}: {
    home.packages = [pkgs.moor];

    programs.direnv = {
      enable = true;
      enableFishIntegration = true;
    };

    programs.starship = {
      enable = true;
      enableFishIntegration = true;
    };

    xdg.configFile."starship.toml".source = ./starship.toml;

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
        set -x STARDICT_DATA_DIR ~/Sync/configs/stardict
      '';
    };
  };
}
