#!/usr/bin/env sh
# picks homeConfigurations."$USER@$(hostname)"
nix run ".#home-manager" -- switch --flake . --show-trace --max-jobs 4 --cores 2
#nix-collect-garbage --delete-older-than 2d
