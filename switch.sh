#!/usr/bin/env sh -xe
host_name="$(hostname)"
/usr/bin/env HOSTNAME="$host_name" nix run --impure ".#home-manager" -- switch --flake ".#$(whoami)" --impure --show-trace
#nix-collect-garbage --delete-older-than 2d
