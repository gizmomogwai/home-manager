{inputs, ...}: {
  flake.modules.homeManager.bookmarks = {pkgs, ...}: {
    home.packages = with pkgs; [
      inputs.extract-bookmarks-d.packages.${stdenv.hostPlatform.system}.default
      (writeShellScriptBin "start-bookmark" ''
        # no arguments defaults to fuzzed-gui otherwise the program and parameters from the commandline are used
        [ $# -eq 0 ] && set -- fuzzed-gui
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
