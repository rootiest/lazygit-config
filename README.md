# lazygit-config

My [lazygit](https://github.com/jesseduffield/lazygit) configuration: Catppuccin Mocha theme,
syntax-aware diffs with difftastic that ignore line-ending-only changes, a Conventional
Commit form, and AI-suggested commit messages through the Anthropic API.

## Setup

```sh
git clone https://git.rootiest.dev/rootiest/lazygit-config ~/.config/lazygit
```

Needs lazygit 0.66+, difftastic, a Nerd Font, Neovim, `curl` and `jq`. For AI commit
messages, export `LAZYGIT_ANTHROPIC_API_KEY`. Details are in [docs/](docs/README.md).

## Highlights

- `|` cycles between difftastic and git diffs; both hide CRLF/LF-only changes
- `C` in files: Conventional Commit form
- `Ctrl+A` in files: pick from AI-suggested commit messages
- `b` in local branches: delete branches merged into the default branch

## Test

`./tests/run-tests.sh`. CI runs the same command.

## Conventions

This project follows the Rootiest project conventions: branch before editing, never
push `main`, Conventional Commits, labeled PRs, docs as the single source of truth.
See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

Released under the GPL-3.0-or-later license. See [LICENSE](LICENSE).
