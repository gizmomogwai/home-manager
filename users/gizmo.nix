{ config, pkgs, ... }:

{
  home = {
    username = "gizmo";
    homeDirectory = "/home/gizmo";
    stateVersion = "25.05"; # Please read the comment before changing.

   # Home Manager is pretty good at managing dotfiles. The primary way to manage
   # plain files is through 'home.file'.
   file = {
      # # Building this configuration will create a copy of 'dotfiles/screenrc' in
      # # the Nix store. Activating the configuration will then make '~/.screenrc' a
      # # symlink to the Nix store copy.
      # ".screenrc".source = dotfiles/screenrc;

      # # You can also set the file content immediately.
      # ".gradle/gradle.properties".text = ''
      #   org.gradle.console=verbose
      #   org.gradle.daemon.idletimeout=3600000
      # '';
    };

    # Let Home Manager install and manage itself.
    enableNixpkgsReleaseCheck = false;
  };
  programs = {
    home-manager.enable = true;
  };
}
