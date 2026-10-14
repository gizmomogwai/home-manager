#!/usr/bin/env sh
# picks homeConfigurations."$USER@$(hostname)"
nix run ".#home-manager" -- switch --flake . --show-trace
#nix-collect-garbage --delete-older-than 2d
