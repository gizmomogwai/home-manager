let
  username = builtins.getEnv "USER";
in {
  imports = [ (./. + "/${username}.nix") ];
}
