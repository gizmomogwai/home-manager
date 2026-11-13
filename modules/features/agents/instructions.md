# Global agent preferences

One file for every agent: linked as `~/.claude/CLAUDE.md` and `~/.copilot/copilot-instructions.md`.

## Session defaults

At session start, before the first reply, load these skills with the skill tool and keep them active for the whole session:
- `caveman` — full intensity
- `ponytail` — full intensity
- `dry`

## Shell commands

Prefix every shell command with `rtk` on the `PATH`.

Run: `rtk <cmd>` not `<cmd>`.

## Missing tools

Not on PATH? Run from nixpkgs: `nix run nixpkgs#<pkg> -- ...` or `nix shell nixpkgs#<pkg> --command ...`. Never install.
Check nixpkgs for an existing tool before writing a custom script.

## Code and cargo

- Spell out every name in code you write, also in snippets inside a chat answer: `destination`, not `dst`. Brevity modes (ponytail, caveman) cut code and prose, never names. Details: skill `ck-coding-style`.
- Run cargo as `env CARGO_TERM_QUIET=true rtk cargo <subcommand>`. Details: skill `rusty`.
