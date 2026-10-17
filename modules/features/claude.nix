{
  flake.modules.homeManager.claude = {pkgs, ...}: {
    home.packages = [pkgs.claude-code];

    programs.agent-skills.targets.claude = {
      enable = true;
      structure = "link";
      dest = ".claude/skills";
    };
  };
}
