#!/usr/bin/env sh
set -eu
nix flake update
nix-collect-garbage --delete-older-than 14d
