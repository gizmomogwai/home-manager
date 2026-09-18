let
  hostName = builtins.getEnv "HOSTNAME";
  hostModule = ./. + "/${hostName}.nix";
in {
  imports = if builtins.pathExists hostModule then [ hostModule ] else [];
}
