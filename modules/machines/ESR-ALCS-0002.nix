{config, ...}: {
  flake.homeConfigurations."christian-koestlin@ESR-ALCS-0002" = config.mkHome {
    system = "x86_64-linux";
    user = "christian-koestlin";
    homeDirectory = "/home/christian-koestlin";
    modules = with config.flake.modules.homeManager; [common linux nixgl-nvidia];
  };
}
