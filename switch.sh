#!/usr/bin/env sh
# picks homeConfigurations."$USER@$(hostname)"
echo for bootstrapping:
echo   nix run ".#home-manager" -- switch --flake . --show-trace --max-jobs 4 --cores 2
echo for normal day use.
echo   home-manager switch
