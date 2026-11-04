{
  flake.modules.homeManager.desktop-apps = {
    config,
    pkgs,
    ...
  }: let
    openGLApps = with pkgs; [
      firefox
      google-chrome
      slack
    ];
  in {
    home.packages =
      map config.lib.nixGL.wrap openGLApps
      ++ (with pkgs; [
        openscad
        meld
        spotify
        vscode
        zeal
      ])
      ++ [
        (pkgs.writeShellScriptBin "herdr-app" ''
          # nixGL env leaks from the terminal; the prebuilt binary must use the system EGL/Vulkan
          exec env -u LD_LIBRARY_PATH -u __EGL_VENDOR_LIBRARY_FILENAMES -u GBM_BACKENDS_PATH \
          ~/.local/share/herdr-app/herdr-app "$@"
        '')
      ];
  };
}
