#!/usr/bin/env sh
nix flake update
nix-collect-garbage --delete-older-than 14d
