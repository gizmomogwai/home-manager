{inputs, ...}: {
  flake.modules.homeManager.herdr = {
    pkgs,
    lib,
    ...
  }: let
    # upstream's flake uses the default rustup profile (rust-docs, clippy, rustfmt);
    # same pinned channel, minimal profile is enough to build
    toolchain = pkgs.rust-bin.fromRustupToolchain {
      inherit ((lib.importTOML "${inputs.herdr}/rust-toolchain.toml").toolchain) channel;
      profile = "minimal";
    };
  in {
    # from the herdr flake input (not pkgs.herdr), so it can be bumped on its own:
    #   nix flake update herdr
    home.packages = [
      ((pkgs.callPackage "${inputs.herdr}/nix/package.nix" {
          rustPlatform = pkgs.makeRustPlatform {
            cargo = toolchain;
            rustc = toolchain;
          };
        }).overrideAttrs (previous: {
          patches = (previous.patches or []) ++ [../patches/herdr-copilot-detection.patch];
        }))
    ];

    # Configuration placeholders (check `herdr --help` / https://herdr.dev for the real keys):
    #
    # config file:
    # xdg.configFile."herdr/config.toml".text = ''
    #   # ...
    # '';
    #
    # environment:
    # home.sessionVariables.HERDR_SOMETHING = "...";
    #
    # shell shortcut:
    # programs.fish.shellAliases.h = "herdr";
  };
}
