{
  flake.modules.homeManager.copilot = { pkgs, ... }: {
    # GitHub Copilot CLI, binary `copilot`; log in once with `copilot` then `/login`
    home.packages = [ pkgs.github-copilot-cli ];

    # Configuration placeholders:
    #
    # user settings, ~/.copilot/settings.json (config.json is app state, user keys there are ignored;
    # read-only once nix-managed, so in-app setting changes fail):
    # home.file.".copilot/settings.json".text = builtins.toJSON {
    #   model = "claude-sonnet-4.5";
    # };
    #
    # MCP servers, ~/.copilot/mcp-config.json:
    # home.file.".copilot/mcp-config.json".text = builtins.toJSON {
    #   mcpServers = { };
    # };
    #
    # global instructions loaded into every session:
    # home.file.".copilot/copilot-instructions.md".source = ./copilot/copilot-instructions.md;
    # (more topic files: ~/.copilot/instructions/*.instructions.md)
    #
    # skills are managed in agent-skills.nix (targets.copilot)
  };
}
