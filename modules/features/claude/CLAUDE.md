# Global Claude Preferences

## Session defaults

At session start, activate these skills:
- `Skill(caveman)` — full intensity
- `Skill(ponytail)` — full intensity

## Shell commands

Prefix every shell command with `rtk` on the `PATH`.

Run: `rtk <cmd>` not `<cmd>`.

## Missing tools

Not on PATH? Run from nixpkgs: `nix run nixpkgs#<pkg> -- ...` or `nix shell nixpkgs#<pkg> --command ...`. Never install.
Check nixpkgs for an existing tool before writing a custom script.
