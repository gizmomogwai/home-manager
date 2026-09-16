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
      overlays = [ (import rust-overlay) emacs-overlay.overlays.default nixgl.overlay ];
      pkgs = import nixpkgs {
        inherit overlays;
        localSystem = "x86_64-linux";
        config.allowUnfree = true;
      };
      username = builtins.getEnv "USER";
      hostName = builtins.getEnv "HOSTNAME";
      hostModule = ./. + "/hosts/${hostName}.nix";
    in {
      homeConfigurations = {
        "${username}" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            ./common-packages.nix
            (./. + "/users/${username}.nix")
          ] ++ lib.optional (builtins.pathExists hostModule) hostModule;
        };
      };
    };
}
