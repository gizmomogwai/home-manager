{ ... }:
{
  programs.agent-skills = {
    enable = true;

    sources = {
      ponytail = { input = "ponytail"; subdir = "skills"; filter.maxDepth = 1; };
      caveman = { input = "caveman"; subdir = "skills"; filter.maxDepth = 1; };
      # gist: SKILL.md at repo root
      socratic-code-mentor = { input = "socratic-code-mentor"; };
    };

    skills.enableAll = [ "ponytail" "caveman" ];
    skills.explicit.socratic-code-mentor = { from = "socratic-code-mentor"; path = "."; };

    targets.agents = {
      enable = true;
      # home.file symlinks into the read-only /nix/store
      structure = "link";
      # link needs a static path relative to $HOME (the default "$HOME/.agents/skills" is rejected)
      dest = ".agents/skills";
    };

    targets.claude = {
      enable = true;
      structure = "link";
      dest = ".claude/skills";
    };
  };
}
