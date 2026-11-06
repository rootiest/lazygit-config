# lazygit-config documentation

Everything about this configuration is documented here. A change is not done until these
docs describe it.

## Files

| File | Purpose |
| --- | --- |
| `config.yml` | The lazygit configuration |
| `ai-commit.sh` | Suggests commit messages for the AI commit menu |
| `tests/run-tests.sh` | Checks run locally and in CI |

## Install

Clone into lazygit's config directory (`lazygit -cd` prints it; on Linux it is
`~/.config/lazygit`):

```sh
git clone https://git.rootiest.dev/rootiest/lazygit-config ~/.config/lazygit
```

Requirements:

- [lazygit](https://github.com/jesseduffield/lazygit) 0.66 or newer (uses `git.diffRenderers`)
- [difftastic](https://github.com/Wilfred/difftastic) (`difft`) for the default diff view
- A [Nerd Font](https://github.com/ryanoasis/nerd-fonts) v3 for icons
- Neovim, for the `nvim-remote` edit preset
- `curl` and `jq`, for the AI commit menu
- `xdg-open`, for opening files and links

## Appearance

- Catppuccin Mocha theme with green accents.
- Author colors: `rootiest` in pink, everyone else in lavender.
- Branch colors by name pattern: `docs`, `dev…`, and `main`/`master`.
- Fuzzy filtering with `/`, divergence-from-base arrows, a braille spinner.

## Diff view

Two renderers, cycled with `|`:

1. **difftastic** (default): a syntax-aware inline diff. It follows lazygit's context size
   (`{`/`}`), view width and light/dark background.
2. **git**: git's own diff with `--ignore-cr-at-eol`.

Both ignore line-ending-only changes: a file converted between CRLF and LF shows
"No changes." in difftastic and an empty diff in git. The file still appears as modified in
the files list, because its bytes did change.

## Editing and clipboard

- `nvim-remote` preset: inside a Neovim terminal, files open in the parent Neovim; elsewhere,
  a new Neovim opens in the terminal.
- Copying uses OSC 52, so it works over SSH in terminals that support it.

## Custom commands

| Key | Panel | Action |
| --- | --- | --- |
| `C` | Files | Conventional commit: prompts for type, optional scope, breaking change, summary, then confirms |
| `Ctrl+A` | Files | AI commit: pick from 5 suggested Conventional Commit messages for the staged changes |
| `b` | Local branches | Delete local branches already merged into the default branch |
| `Ctrl+P` | Remotes | `git remote prune` the selected remote |

`C` replaces lazygit's built-in "commit using git editor" in the files panel.

The merged-branch prune reads the default branch from `origin/HEAD` and falls back to
`main`. It never deletes the default branch or the checked-out branch, and uses
`git branch -d`, so unmerged branches are never removed.

Commit messages from `C` and `Ctrl+A` are shell-quoted before use, so quotes, `$` and
backticks in a message are committed literally.

## AI commit messages

`ai-commit.sh` sends the staged diff (capped at 60,000 characters), the staged file list and
the 10 most recent commit subjects to the Anthropic Messages API and prints 5 numbered
suggestions for the menu.

| Variable | Required | Meaning |
| --- | --- | --- |
| `LAZYGIT_ANTHROPIC_API_KEY` | yes | Anthropic API key |
| `LAZYGIT_AI_MODEL` | no | Model to use (default `claude-haiku-5-5`) |

The key uses its own variable name on purpose: Claude Code reads `ANTHROPIC_API_KEY`, and
setting that in your shell would switch Claude Code to API billing.

The key is passed to `curl` through a header file, so it does not appear in the process
list. Errors (no key, nothing staged, API errors) are printed and shown by lazygit.

## Updates

`update.method` is `never`: lazygit is installed and updated by the system package manager.

## Tests

```sh
./tests/run-tests.sh
```

Checks that `config.yml` parses, that `ai-commit.sh` passes `bash -n` and `shellcheck`, and
that it reports a missing key and an empty index. Checks whose tools are missing are
skipped. CI runs the same script on pull requests and pushes to `main`.
