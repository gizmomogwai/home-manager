{config, ...}: {
  # features every host gets
  flake.modules.homeManager.common.imports = with config.flake.modules.homeManager; [
    base
    agent-skills
    apps-own
    bookmarks
    claude
    cli-tools
    copilot
    dlang
    editor
    fish
    fonts
    ghostty
    global-cargo-settings
    herdr
    prompt
    secrets
  ];
}
