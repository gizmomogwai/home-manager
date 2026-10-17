{
  flake.modules.homeManager.copilot = {pkgs, ...}: {
    # GitHub Copilot CLI, binary `copilot`; log in once with `copilot` then `/login`
    home.packages = [pkgs.github-copilot-cli];

    programs.agent-skills.targets.copilot = {
      enable = true;
      structure = "link";
      dest = ".copilot/skills";
    };
  };
}
