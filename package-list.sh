#!/usr/bin/env sh
# usage: ./package-list.sh [user@host]  (default: homeConfigurations."$USER@$(hostname)", like switch.sh)
# lists home.packages with versions, evaluated only, nothing is built
set -e
machine="${1:-$USER@$(hostname)}"
rows=$(nix eval --raw ".#homeConfigurations.\"$machine\".config.home.packages" --apply '
  ps: let
    row = p: "${p.pname or p.name}\t${p.version or "-"}";
  in builtins.concatStringsSep "\n" (builtins.sort (a: b: a < b) (map row ps))
')
printf 'PACKAGE\tVERSION\n%s\n' "$rows" | column -t -s "$(printf '\t')"
