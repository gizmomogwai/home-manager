#!/usr/bin/env bash
# Show installed package versions next to what a fresh `nix flake update` + switch would install.
# Does not touch flake.lock or the active profile.
set -euo pipefail
cd "$(dirname "$0")"

temporary_directory=$(mktemp --directory)
trap 'rm --recursive --force "$temporary_directory"' EXIT

nix flake update --output-lock-file "$temporary_directory/flake.lock"

# Evaluate only: read package names from the config without building anything.
list_updated_packages() {
  nix eval --raw \
    --reference-lock-file "$temporary_directory/flake.lock" \
    ".#homeConfigurations.\"$USER@$(hostname)\".config.home.packages" \
    --apply 'packages: builtins.concatStringsSep "\n" (map (package: package.name) packages) + "\n"'
}

list_installed_packages() {
  nix-store --query --references "$(readlink --canonicalize ~/.local/state/nix/profiles/home-manager)/home-path" \
    | sed --regexp-extended 's|^/nix/store/[a-z0-9]*-||; s/-fish-completions$//; s/-(bin|out|man|dev|lib)$//'
}

{
printf 'PACKAGE\tINSTALLED\tAFTER UPDATE\n'
awk '
  function split_name(entry) {
    if (match(entry, /-[0-9]/)) { name = substr(entry, 1, RSTART - 1); version = substr(entry, RSTART + 1) }
    else { name = entry; version = "" }
  }
  FNR == 1 { file_index++ }
  { split_name($0); names[name] = 1; if (file_index == 1) installed[name] = version; else updated[name] = version }
  END {
    for (name in names) {
      old = (name in installed) ? installed[name] : "-"
      new = (name in updated) ? updated[name] : "-"
      if ((old == "" || old == "-") && (new == "" || new == "-")) continue
      # shortcut: home-manager internals (gnused, systemd, ...) are in home-path but not home.packages, so removals are hidden too
      if (new == "-") continue
      printf "%s\t%s\t%s\t%s\n", name, old, new, (old == new ? "" : "*")
    }
  }
' <(list_installed_packages) <(list_updated_packages) | sort --ignore-case
} | column --table --separator $'\t'
