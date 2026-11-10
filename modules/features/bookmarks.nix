{inputs, ...}: {
  flake.modules.homeManager.bookmarks = {
    config,
    pkgs,
    ...
  }: let
    system = pkgs.stdenv.hostPlatform.system;
    extract-bookmarks = inputs.extract-bookmarks-d.packages.${system}.default;
    fuzzed-clay = config.lib.nixGL.wrap inputs.fuzzed-clay.packages.${system}.default;
  in {
    home.packages = with pkgs; [
      extract-bookmarks
      (writeShellScriptBin "start-bookmark" ''
        # no arguments defaults to fuzzed-clay otherwise the program and parameters from the commandline are used
        [ $# -eq 0 ] && set -- ${fuzzed-clay}/bin/fuzzed-clay
        line=$(${extract-bookmarks}/bin/extract-bookmarks-d | "$@") || exit 0
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
