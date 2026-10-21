# home-manager switch --flake . picks homeConfigurations."$USER@$(hostname)" (see modules/machines)
{
  description = "My home-manager flake";
  inputs = {
    nixpkgs.url = "nixpkgs/nixpkgs-unstable";

    agent-skills = {
      url = "github:Kyure-A/agent-skills-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    caveman = {
      url = "github:JuliusBrussee/caveman";
      flake = false;
    };
    dime = {
      url = "github:gizmomogwai/dime";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ck-skills = {
      url = "github:gizmomogwai/ck-skills";
      flake = false;
    };
    donies = {
      url = "github:gizmomogwai/donies";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    extract-bookmarks-d = {
      url = "git+ssh://git@github.com/gizmomogwai/bookmarks";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    emacs-overlay = {
      url = "github:nix-community/emacs-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs-stable.follows = "nixpkgs";
    };
    fisher-package = {
      url = "github:gizmomogwai/fisher-package";
      flake = false;
    };
    # own input instead of pkgs.herdr: update separately with `nix flake update herdr`
    herdr = {
      url = "github:herdrdev/herdr";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.rust-overlay.follows = "rust-overlay";
    };
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    import-tree.url = "github:vic/import-tree";
    # nixgl.url = "github:nix-community/nixGL";
    # https://github.com/nix-community/nixGL/pull/223
    nixgl = {
      url = "github:TheTeXnician/nixGL/bbcc73c8bcc72b195fead993c7056b12683424f0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    matt-pocock = {
      url = "github:mattpocock/skills";
      flake = false;
    };
    ponytail = {
      url = "github:DietrichGebert/ponytail";
      flake = false;
    };
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sesame = {
      url = "github:gizmomogwai/sesame";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    socratic-code-mentor = {
      url = "git+https://gist.github.com/ogzhanolguncu/274e9974dc02942109ad70200f6d7b25.git";
      flake = false;
    };
    spotify-dl = {
      url = "git+ssh://git@github.com/gizmomogwai/spotify-dl";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    viewed = {
      url = "git+ssh://git@github.com/gizmomogwai/sg4d";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    worker = {
      url = "github:gizmomogwai/repo-worker";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = inputs: inputs.flake-parts.lib.mkFlake {inherit inputs;} (inputs.import-tree ./modules);
}
