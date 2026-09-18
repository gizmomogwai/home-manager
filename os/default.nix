{ pkgs, ... }: {
  imports = if pkgs.stdenv.isDarwin then [ ./darwin.nix ] else [ ./linux.nix ];
}
