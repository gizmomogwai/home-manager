{inputs, ...}: {
  flake.modules.homeManager.agent-skills = {
    imports = [inputs.agent-skills.homeManagerModules.default];

    programs.agent-skills = {
      enable = true;

      # `path` instead of `input = "<name>"`, so no extraSpecialArgs.inputs is needed
      sources = {
        ponytail = {
          path = inputs.ponytail;
          subdir = "skills";
          filter.maxDepth = 1;
        };
        caveman = {
          path = inputs.caveman;
          subdir = "skills";
          filter.maxDepth = 1;
        };
        # gist: SKILL.md at repo root
        socratic-code-mentor = {path = inputs.socratic-code-mentor;};
      };

      skills.enableAll = ["ponytail" "caveman"];
      skills.explicit.socratic-code-mentor = {
        from = "socratic-code-mentor";
        path = ".";
      };

      targets.agents = {
        enable = true;
        # home.file symlinks into the read-only /nix/store
        structure = "link";
        # link needs a static path relative to $HOME (the default "$HOME/.agents/skills" is rejected)
        dest = ".agents/skills";
      };
    };
  };
}
