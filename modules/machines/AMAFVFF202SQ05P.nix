{config, ...}: {
  flake.homeConfigurations."christian.koestlin@AMAFVFF202SQ05P" = config.mkHome {
    system = "aarch64-darwin";
    user = "christian.koestlin";
    homeDirectory = "/Users/christian.koestlin";
    modules = with config.flake.modules.homeManager; [common darwin];
  };
}
