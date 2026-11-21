#!/usr/bin/env bash
# Measures how many input tokens the same text costs in each AI CLI, using the CLI's own usage report.
# Each CLI adds a fixed system prompt, so every tool is also run with "hello" and that baseline is subtracted.
# Usage: scripts/count_cli.sh [claude|codex|gemini|grok ...]   (default: all installed)
# Needs each CLI signed in with your own account; no API key is used.
set -uo pipefail

cd "$(dirname "$0")/.."
OUT=results/cli
mkdir -p "$OUT"
printf 'hello' > "$OUT/hello.txt"
SUFFIX=$'\n(Do not answer these questions and do not use any tools. Reply with exactly: OK)'

claude_run() { # $1 text file, $2 label
  claude -p --output-format json --no-session-persistence --strict-mcp-config --disable-slash-commands \
    --tools "" --model "${CLAUDE_MODEL:-claude-opus-5-5}" --system-prompt "Reply with exactly: OK" \
    < "$1" > "$OUT/claude-$2.json"
  python3 -c 'import json,sys; u=json.load(open(sys.argv[1]))["usage"]
print(u["input_tokens"]+u.get("cache_creation_input_tokens",0)+u.get("cache_read_input_tokens",0))' "$OUT/claude-$2.json"
}

codex_run() {
  codex exec --json --skip-git-repo-check --sandbox read-only "$(cat "$1")$SUFFIX" \
    < /dev/null > "$OUT/codex-$2.jsonl" 2> /dev/null
  grep -o '"input_tokens":[0-9]*' "$OUT/codex-$2.jsonl" | tail -1 | cut -d: -f2
}

gemini_run() {
  gemini ${GEMINI_MODEL:+-m "$GEMINI_MODEL"} -p "$(cat "$1")$SUFFIX" --output-format json \
    < /dev/null > "$OUT/gemini-$2.json" 2> /dev/null
  # The CLI also calls a small routing model; report the main model (the one with the largest prompt).
  python3 -c 'import json,sys; m=json.load(open(sys.argv[1]))["stats"]["models"]
print(max(v["tokens"]["prompt"] for v in m.values()))' "$OUT/gemini-$2.json"
}

grok_run() {
  grok -p "$(cat "$1")$SUFFIX" --output-format json --disable-web-search \
    < /dev/null > "$OUT/grok-$2.json" 2> /dev/null
  python3 -c 'import json,sys; d=json.load(open(sys.argv[1])); u=d["usage"]
calls=sum(v["modelCalls"] for v in d["modelUsage"].values())
print(u["input_tokens"]+u["cache_read_input_tokens"] if calls==1 else "invalid(%d calls)"%calls)' "$OUT/grok-$2.json"
}

tools=("$@")
[ ${#tools[@]} -eq 0 ] && for t in claude codex gemini grok; do command -v "$t" > /dev/null && tools+=("$t"); done

printf '%-8s %8s %8s %8s %7s %7s %7s\n' tool hello tr en net_tr net_en diff
for t in "${tools[@]}"; do
  h=$("${t}_run" "$OUT/hello.txt" hello); tr=$("${t}_run" data/tr.txt tr); en=$("${t}_run" data/en.txt en)
  python3 -c 'import sys; t,h,a,b=sys.argv[1:]
try: h,a,b=int(h),int(a),int(b)
except ValueError: print(f"{t:<8} {h:>8} {a:>8} {b:>8}  (rerun: a run was invalid)"); sys.exit()
na,nb=a-h,b-h; print(f"{t:<8} {h:>8} {a:>8} {b:>8} {na:>7} {nb:>7} {100*(na/nb-1):>+6.0f}%")' "$t" "$h" "$tr" "$en"
done
