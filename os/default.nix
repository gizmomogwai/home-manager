let
  isDarwin = builtins.match ".*-darwin" builtins.currentSystem != null;
in {
  imports = if isDarwin then [ ./darwin.nix ] else [ ./linux.nix ];
}
