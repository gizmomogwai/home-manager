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

      # Configuration placeholders:
      #
      # new skill source: add a flake input (flake = false is fine), then
      # sources.my-skills = { path = inputs.my-skills; subdir = "skills"; filter.maxDepth = 1; };
      # skills.enableAll = [ "ponytail" "caveman" "my-skills" ];
      #
      # only some skills of a source (instead of enableAll):
      # skills.explicit.pdf = { from = "my-skills"; path = "pdf"; };
      #
      # local, uncommitted-to-upstream skill living in this repo:
      # sources.local = { path = ./skills; };
      #
      # in another agent's module, with agent-skills selected alongside it:
      # programs.agent-skills.targets.other-agent = { enable = true; structure = "link"; dest = ".other-agent/skills"; };
    };
  };
}
