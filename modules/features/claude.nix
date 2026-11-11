{
  flake.modules.homeManager.claude = {pkgs, ...}: {
    home.packages = [pkgs.claude-code];

    home.file.".claude/CLAUDE.md".source = ./claude/CLAUDE.md;

    programs.agent-skills.targets.claude = {
      enable = true;
      structure = "link";
      dest = ".claude/skills";
    };
  };
}
