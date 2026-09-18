# run with env HOSTNAME="$(hostname)" home-manager switch --flake ".#$(whoami)" --impure
# to select one of the homemanager configs
{
  description = "My home-manager flake";
  inputs = {
    rust-overlay.url = "github:oxalica/rust-overlay";
    emacs-overlay.url = "github:nix-community/emacs-overlay";
    nixpkgs.url = "nixpkgs/nixpkgs-unstable";
    # nixgl.url = "github:nix-community/nixGL";
    # https://github.com/nix-community/nixGL/pull/223
    nixgl.url = "github:TheTeXnician/nixGL/bbcc73c8bcc72b195fead993c7056b12683424f0";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { nixpkgs, home-manager, rust-overlay, emacs-overlay, nixgl, ... }:
    let
      lib = nixpkgs.lib;
      system = builtins.currentSystem;
      isLinux = lib.hasSuffix "-linux" system;
      overlays = [ (import rust-overlay) emacs-overlay.overlays.default ]
        ++ lib.optional isLinux nixgl.overlay;
      pkgs = import nixpkgs {
        inherit system overlays;
        config.allowUnfree = true;
      };
      username = builtins.getEnv "USER";
    in {
      homeConfigurations = {
        "${username}" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            ./common-packages.nix
            ./os
            ./users
            ./hosts
          ];
        };
      };
    };
}
