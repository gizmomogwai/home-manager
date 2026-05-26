#!/usr/bin/sh -xe
home-manager switch --flake .#$(whoami) --impure
