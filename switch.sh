#!/usr/bin/env sh -xe
host_name="$(hostname)"
/usr/bin/env HOSTNAME="$host_name" nix run home-manager -- switch --flake ".#$(whoami)" --impure --show-trace
