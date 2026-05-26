# run with home-manager switch --flake .#$(whoami) --impure
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
      nixglOverlay = final: _:
        let
          nixglPatched = final.applyPatches {
            name = "nixGL-patched";
            src = nixgl.outPath;
            patches = [
              (final.writeText "nixgl-nvidia-libs-only.patch" ''
                diff --git a/nixGL.nix b/nixGL.nix
                --- a/nixGL.nix
                +++ b/nixGL.nix
                @@ -86,8 +86,7 @@ let
                         });

                       nvidiaLibsOnly = nvidiaDrivers.override {
                         libsOnly = true;
                -        kernel = null;
                       };

                       nixGLNvidiaBumblebee = writeExecutable {
              '')
            ];
            postPatch = ''
              substituteInPlace nixGL.nix \
                --replace-fail \
                  'data = builtins.readFile _nvidiaVersionFile;' \
                  'data = builtins.readFile _nvidiaVersionFile;
                  versionLine = builtins.head (lib.splitString "\n" data);' \
                --replace-fail \
                  'versionMatch = builtins.match ".*Module  ([0-9.]+)  .*" data;' \
                  'versionMatch = builtins.match ".*  ([0-9][0-9.]+)  .*" versionLine;'
            '';
          };
          isIntelX86Platform = final.stdenv.hostPlatform.system == "x86_64-linux";
        in {
          nixgl = import "${nixglPatched}/default.nix" {
            pkgs = final;
            enable32bits = isIntelX86Platform;
            enableIntelX86Extensions = isIntelX86Platform;
          };
        };
      overlays = [ (import rust-overlay) nixglOverlay ];
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
