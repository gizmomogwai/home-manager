#!/usr/bin/env sh -xe
nix flake update
nix-collect-garbage --delete-older-than 14d
