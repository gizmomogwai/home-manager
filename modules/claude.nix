{
  flake.modules.homeManager.claude = {pkgs, ...}: {
    home.packages = [pkgs.claude-code];

    # Configuration placeholders (home-manager also has programs.claude-code, which
    # installs the package and manages these files; switch to it if you want that):
    #
    # user settings, ~/.claude/settings.json (overwrites in-app edits, they become read-only):
    # home.file.".claude/settings.json".text = builtins.toJSON {
    #   model = "opus";
    #   permissions.allow = [ "Bash(git status:*)" ];
    # };
    #
    # global instructions loaded into every session:
    # home.file.".claude/CLAUDE.md".source = ./claude/CLAUDE.md;
    #
    # environment, e.g. to route through a gateway:
    # home.sessionVariables.ANTHROPIC_BASE_URL = "https://…";
    #
    # skills are managed in agent-skills.nix (targets.claude)
  };
}
