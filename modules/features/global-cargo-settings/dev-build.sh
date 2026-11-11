#!/usr/bin/env bash
set -o errexit -o nounset -o pipefail

if [[ $# -eq 0 ]]; then
  printf 'Usage: dev-build COMMAND [ARGUMENT...]\n' >&2
  exit 2
fi

# Check membership rather than an inherited flag: independent services escape scopes.
if grep --quiet --fixed-strings '/devbuild.slice/' /proc/self/cgroup; then
  exec "$@"
fi

for executable in systemd-run systemctl; do
  # -v checks command availability; Bash command has no long form.
  if ! command -v "$executable" >/dev/null; then
    printf 'dev-build requires %s from the host systemd installation.\n' "$executable" >&2
    exit 1
  fi
done
control_group=$(systemctl --user show --property=ControlGroup --value)
if [[ "$control_group" != /* ]] || ! grep --quiet --word-regexp cpu "/sys/fs/cgroup$control_group/cgroup.controllers"; then
  printf 'dev-build requires the CPU controller delegated to the systemd user manager.\n' >&2
  exit 1
fi

exec systemd-run --user --scope --quiet --slice=devbuild.slice --expand-environment=no -- "$@"
