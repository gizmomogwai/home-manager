{config, ...}: {
  flake.modules.homeManager.common = {
    # features every host gets
    imports = with config.flake.modules.homeManager; [
      agent-skills
      own-apps
      bookmarks
      claude
      cli-tools
      copilot
      desktop-apps
      dlang
      editor
      fish
      fonts
      ghostty
      global-cargo-settings
      herdr
      proton-pass
      secrets
    ];

    home.stateVersion = "25.05"; # Please read the comment before changing.
    home.enableNixpkgsReleaseCheck = false;
    home.sessionPath = ["$HOME/bin"];
    # Let Home Manager install and manage itself.
    programs.home-manager.enable = true;
  };
}
