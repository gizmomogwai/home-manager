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
        matt-pocock-productivity = {
          path = inputs.matt-pocock;
          subdir = "skills/productivity";
          filter.maxDepth = 1;
        };
        matt-pocock-engineering = {
          path = inputs.matt-pocock;
          subdir = "skills/engineering";
          filter.maxDepth = 1;
        };
        # gist: SKILL.md at repo root
        socratic-code-mentor = {path = inputs.socratic-code-mentor;};
        ck-skills = {
          path = inputs.ck-skills;
          subdir = "skills";
          filter.maxDepth = 1;
        };
      };

      skills.enableAll = ["ponytail" "caveman" "ck-skills" "matt-pocock-productivity" "matt-pocock-engineering"];
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
