#!/usr/bin/env bash
# Suggest Conventional Commit messages for the staged diff via the Anthropic API.
# Prints "1. <message>" lines for lazygit's "pick AI commit" menu (<c-a>).
#
# Env:
#   LAZYGIT_ANTHROPIC_API_KEY  API key (a separate name, so Claude Code ignores it)
#   LAZYGIT_AI_MODEL           model override (default: claude-haiku-5-5)
set -euo pipefail

key=${LAZYGIT_ANTHROPIC_API_KEY:-}
[[ -n $key ]] || { echo "LAZYGIT_ANTHROPIC_API_KEY is not set" >&2; exit 1; }
model=${LAZYGIT_AI_MODEL:-claude-haiku-5-5}

diff=$(git diff --cached --no-ext-diff --no-color)
[[ -n $diff ]] || { echo "Nothing is staged" >&2; exit 1; }
max=60000
(( ${#diff} > max )) && diff="${diff:0:max}
[diff truncated]"
stat=$(git diff --cached --stat --no-color)
recent=$(git log -10 --format=%s 2>/dev/null || true)

system='You write git commit subjects following Conventional Commits.
Reply with exactly 5 alternative subjects, numbered "1. " to "5. ", one per line, and nothing else.
Format: type(scope)!: summary. Scope is optional, "!" only for breaking changes.
Types: feat, fix, docs, style, refactor, perf, test, build, ci, chore, revert.
Imperative mood, lowercase after the colon, no trailing period, at most 72 characters.
If recent subjects are given, match their scope naming and style.'

user="Recent commit subjects:
${recent:-(none)}

Staged files:
$stat

Staged diff:
$diff"

body=$(jq -n --arg model "$model" --arg system "$system" --arg user "$user" \
  '{model: $model, max_tokens: 400, system: $system,
    messages: [{role: "user", content: $user}]}')

# Key goes in via a header file so it never appears in the process list
if ! resp=$(curl -sS --fail-with-body --max-time 60 https://api.anthropic.com/v1/messages \
  -H @<(printf 'x-api-key: %s\n' "$key") \
  -H 'anthropic-version: 2023-06-01' \
  -H 'content-type: application/json' \
  --data-binary "$body"); then
  msg=$(jq -r '.error.message // empty' <<<"$resp" 2>/dev/null || true)
  echo "Anthropic API: ${msg:-request failed}" >&2
  exit 1
fi

jq -r '.content[] | select(.type == "text") | .text' <<<"$resp" |
  sed -E 's/`//g' | grep -E '^[0-9]+\. .+' || {
  echo "No suggestions in the response" >&2
  exit 1
}
