{
  flake.modules.homeManager.global-cargo-settings = {
    home.sessionVariables.CARGO_TARGET_DIR = "/tmp/cargo-target";
  };
}
