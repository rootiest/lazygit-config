#!/usr/bin/env bash
# Checks the config parses, lints ai-commit.sh, and exercises its offline error paths.
# Optional tools (shellcheck, python3 + PyYAML) are skipped with a note when missing.
set -eu
cd "$(dirname "$0")/.."
root=$PWD
fail=0
pass() { echo "PASS  $1"; }
bad() { echo "FAIL  $1"; fail=1; }
skip() { echo "SKIP  $1"; }

# config.yml is valid YAML
if python3 -c 'import yaml' 2>/dev/null; then
  if python3 -c 'import sys, yaml; yaml.safe_load(open(sys.argv[1]))' config.yml; then
    pass "config.yml parses"
  else
    bad "config.yml parses"
  fi
else
  skip "config.yml parses (python3 PyYAML not installed)"
fi

# ai-commit.sh is syntactically valid and lint-clean
if bash -n ai-commit.sh; then pass "ai-commit.sh syntax"; else bad "ai-commit.sh syntax"; fi
if command -v shellcheck >/dev/null; then
  if shellcheck ai-commit.sh tests/run-tests.sh; then pass "shellcheck"; else bad "shellcheck"; fi
else
  skip "shellcheck (not installed)"
fi

# ai-commit.sh error paths that need no network
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
git -C "$tmp" init -q
expect_err() { # name, expected stderr, env arguments...
  local name=$1 want=$2 out
  shift 2
  if out=$(cd "$tmp" && env "$@" "$root/ai-commit.sh" 2>&1); then
    bad "$name (exited 0)"
  elif [[ $out == *"$want"* ]]; then
    pass "$name"
  else
    bad "$name (got: $out)"
  fi
}
expect_err "ai-commit: missing key" "LAZYGIT_ANTHROPIC_API_KEY is not set" -u LAZYGIT_ANTHROPIC_API_KEY
expect_err "ai-commit: nothing staged" "Nothing is staged" LAZYGIT_ANTHROPIC_API_KEY=test

exit "$fail"
