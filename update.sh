#!/usr/bin/env sh
set -eu
nix flake update
zellij_tag=$(gh api repos/zellij-org/zellij/releases/latest --jq .tag_name)
nix flake lock --override-input zellij "github:zellij-org/zellij/$zellij_tag"
nix-collect-garbage --delete-older-than 14d
