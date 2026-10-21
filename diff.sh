#!/usr/bin/env sh
nix run nixpkgs#nvd -- diff ~/.local/state/nix/profiles/home-manager ./result
