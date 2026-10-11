# run with env HOSTNAME="$(hostname)" home-manager switch --flake ".#$(whoami)" --impure
# to select one of the homemanager configs
{
  description = "My home-manager flake";
  inputs = {
    nixpkgs.url = "nixpkgs/nixpkgs-unstable";

    agent-skills = {
      url = "github:Kyure-A/agent-skills-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    caveman = { url = "github:JuliusBrussee/caveman"; flake = false; };
    emacs-overlay = {
      url = "github:nix-community/emacs-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs-stable.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # nixgl.url = "github:nix-community/nixGL";
    # https://github.com/nix-community/nixGL/pull/223
    nixgl = {
      url = "github:TheTeXnician/nixGL/bbcc73c8bcc72b195fead993c7056b12683424f0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ponytail = { url = "github:DietrichGebert/ponytail"; flake = false; };
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sesame = {
      url = "github:gizmomogwai/sesame";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    socratic-code-mentor = { url = "git+https://gist.github.com/ogzhanolguncu/274e9974dc02942109ad70200f6d7b25.git"; flake = false; };
  };
  outputs = inputs@{ nixpkgs, home-manager, rust-overlay, emacs-overlay, nixgl, agent-skills, ... }:
    let
      lib = nixpkgs.lib;
      system = builtins.currentSystem;
      isLinux = lib.hasSuffix "-linux" system;
      nvidiaVersion = "595.99.02";
      nixglOverlay = final: prev: {
        nixgl = import (prev.applyPatches {
          name = "nixGL-patched";
          src = nixgl;
          # upstream sets GBM_BACKENDS_PATH only for mesa; webkitgtk then loads mesa's dri_gbm.so
          patches = [ ./nixgl-nvidia-gbm.patch ];
        }) {
          pkgs = final;
          inherit nvidiaVersion;
        };
      };
      overlays = [ (import rust-overlay) emacs-overlay.overlays.default ]
        ++ lib.optional isLinux nixglOverlay;
      pkgs = import nixpkgs {
        inherit system overlays;
        config.allowUnfree = true;
      };
      username = builtins.getEnv "USER";
    in {
      packages.${system}.home-manager = home-manager.packages.${system}.home-manager;
      homeConfigurations = {
        "${username}" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = { inherit inputs; };
          modules = [
            agent-skills.homeManagerModules.default
            ./agent-skills.nix
            ./common-packages.nix
            ./os
            ./users
            ./hosts
          ];
        };
      };
    };
}
