{inputs, ...}: {
  flake.modules.homeManager.bookmarks = {
    pkgs,
    lib,
    ...
  }: {
    home.packages = with pkgs; [
      inputs.extract-bookmarks-d.packages.${stdenv.hostPlatform.system}.default
      (writeShellScriptBin "start-bookmark" ''
        # rofi is linux-only and choose-gui darwin-only in nixpkgs, so only the host's picker is interpolated
        # optional args override the picker, e.g. `start-bookmark fzf --exact`
        [ $# -eq 0 ] && set -- ${
          if stdenv.hostPlatform.isDarwin
          then lib.getExe choose-gui
          else "${lib.getExe rofi} -dmenu"
        }
        line=$(extract-bookmarks-d | "$@") || exit 0
        # url is the last field (strip longest prefix ending in '|'); bookmarks without folder have only "title|url"
        url=''${line##*|}
        echo "$url"
        ${
          if stdenv.hostPlatform.isDarwin
          then "open"
          else "xdg-open"
        } "$url"
      '')
    ];
  };
}
