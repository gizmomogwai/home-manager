#!/usr/bin/sh -xe
host_name="$(hostname)"
env HOSTNAME="$host_name" home-manager switch --flake ".#$(whoami)" --impure
