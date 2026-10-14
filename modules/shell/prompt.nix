{
  flake.modules.homeManager.prompt = {
    programs.direnv = {
      enable = true;
      enableFishIntegration = true;
    };

    programs.starship = {
      enable = true;
      enableFishIntegration = true;
    };
  };
}
