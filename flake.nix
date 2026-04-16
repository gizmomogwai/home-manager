# run with home-manager switch --flake .#$(whoami)
# to select one of the homemanager configs
{
  description = "My home-manager flake";
  inputs = {
    rust-overlay.url = "github:oxalica/rust-overlay";
    nixpkgs.url = "nixpkgs/nixpkgs-unstable";
    nixgl.url = "github:nix-community/nixGL";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { nixpkgs, home-manager, rust-overlay, nixgl, ... }:
    let
      lib = nixpkgs.lib;
      system = "x86_64-linux";
      overlays = [ (import rust-overlay) nixgl.overlay ];
      pkgs = import nixpkgs { inherit overlays system; config.allowUnfree = true; };
    in {
      homeConfigurations = {
        christian-koestlin = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [ ./common-packages.nix ./christian-koestlin.nix ];
        };
        gizmo = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [ ./common-packages.nix ./gizmo.nix ];
        };
      };
    };
}
