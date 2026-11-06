# Shipping this project

Instructions for `/ship-it` and its steps. Each `##` section is read by the step of the same
name; anything left out uses that step's defaults.

## doc-it
- Documentation lives in `docs/README.md`; the root `README.md` is a short overview.
- Keep the custom command table and the environment variable table in `docs/README.md` in
  sync with `config.yml` and `ai-commit.sh`.

## push-it
- Branch naming: `feat/<topic>`, `fix/<topic>`, `docs/<topic>`, `chore/<topic>`.
- Commit scopes in use: `config`, `ai-commit`, `tests`, `docs`.
- Run `./tests/run-tests.sh` before pushing.

## verify-it
- CI runs `./tests/run-tests.sh`; it takes under a minute.

## deploy-it
- Nothing to deploy. The repository is the live config directory (`~/.config/lazygit`);
  lazygit reads it on next start.
