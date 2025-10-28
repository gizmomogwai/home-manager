{
  description = "My home-manager flake";
  inputs = {
    nixpkgs = {
      url = "nixpkgs/nixos-25.05";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { nixpkgs, home-manager, ... }:
    let
      lib = nixpkgs.lib;
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system;  config.allowUnfree = true; };
    in {
      homeConfigurations = {
        christian-koestlin = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [ ./home.nix ];
        };
        gizmo = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [ ./gizmo.nix ];
        };
      };
    };
}
