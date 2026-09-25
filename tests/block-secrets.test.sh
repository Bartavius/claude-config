#!/usr/bin/env bash
# Pipes synthetic PreToolUse JSON into hooks/block-secrets.sh and checks exit codes.
# Every payload is a single-quoted literal, so no real variable is ever expanded.
set -u

hook="$(cd "$(dirname "$0")/.." && pwd)/hooks/block-secrets.sh"
pass=0
fail=0

check() {
  local want="$1" json="$2" rc=0
  printf '%s' "$json" | "$hook" 2>/dev/null || rc=$?
  if [ "$rc" = "$want" ]; then
    pass=$((pass + 1)); echo "PASS ($rc) $json"
  else
    fail=$((fail + 1)); echo "FAIL (want $want, got $rc) $json"
  fi
}

# Compact form: {"tool_name":"Bash","tool_input":{"command":"..."}}
block() { check 2 "{\"tool_name\":\"Bash\",\"tool_input\":{\"command\":\"$1\"}}"; }
allow() { check 0 "{\"tool_name\":\"Bash\",\"tool_input\":{\"command\":\"$1\"}}"; }

# --- must block --------------------------------------------------------------
block 'env'
block 'env | sort'
block 'printenv'
block 'printenv HOME'
block 'export'
block 'export -p'
block 'set'
block 'set | grep X'
block 'declare -x'
block 'declare -p'
block 'echo $SECRET'
block 'echo \"${API_KEY}\"'
block "printf '%s\\\\n' \\\"\$TOKEN\\\""
block 'ls && echo $AWS_SECRET'
block 'cat .env'
block 'cat ./app/.env.local'
block 'head -n 3 .env'
block 'grep KEY .env.production'
block 'rg KEY .env'
block 'source .env'
block '. .env'
block 'less config/.env'
block "python3 -c 'import os; print(os.environ)'"
block 'node -e \"console.log(process.env.X)\"'
block "ruby -e 'puts ENV[\\\"X\\\"]'"
block 'cd /tmp\nenv'
# Gaps found in review: path/backslash prefixes, wrappers, quoting, dumps, readers.
block '\\env'
block '/usr/bin/env'
block '/bin/cat .env'
block 'sudo printenv'
block 'bash -c \"env\"'
block 'x=$(env)'
block 'env -u PATH'
block 'declare'
block 'typeset'
block 'declare -p SECRET'
block 'cat<.env'
block 'while read l; do :; done < .env'
block "sed -n p .env"
block "awk 1 .env"
block "python3 -Ic 'import os; print(os.environ)'"
block "python3.12 -c 'from os import environ; print(environ)'"
block "perl -le 'print %ENV'"
block "ruby -rjson -e 'p ENV.to_h'"
block "awk 'BEGIN{print ENVIRON[\\\"X\\\"]}'"
block 'python3 - <<EOF\nimport os\nprint(os.environ)\nEOF'
# Second review: command starts after assignments, keywords, launchers, and options.
block "/usr/bin/env python3 -c 'import os; print(os.environ)'"
block 'X=1 printenv'
block 'for i in 1; do printenv; done'
block 'bash -c printenv'
block 'sudo -u root cat .env'
block 'timeout 5 cat .env'
block 'find . -name x -exec cat .env \\;'
block "ruby -e 'p ENV'"
block "ruby -e 'p ENV.fetch(\\\"X\\\")'"
block "php -r 'print_r(\$_ENV);'"
block 'nl .env'
block "python3 -c 'print(open(\\\".env\\\").read())'"

# Spaced form with description, cwd, and session_id keys.
check 2 '{ "session_id": "abc", "cwd": "/tmp", "tool_name": "Bash", "tool_input": { "command": "printenv", "description": "Show vars" } }'
check 2 '{ "session_id": "abc", "cwd": "/tmp", "tool_name": "Bash", "tool_input": { "description": "Read config", "command": "cat .env" } }'

# --- must allow --------------------------------------------------------------
allow 'export PATH=\"$HOME/bin:$PATH\"'
allow 'cd ~/x && git status'
allow 'git log --oneline -5'
allow 'git diff HEAD'
allow 'set -euo pipefail'
allow 'env FOO=1 make'
allow 'echo hello'
allow 'echo $?'
allow 'for f in *.md; do echo $f; done'
allow 'ls -la .envrc'
allow 'cat README.md'
allow 'rg \"process.env\" src/'
allow "python -c 'print(1)'"
allow "node -e 'console.log(1)'"
allow 'python -m venv env'
allow 'ls env'
allow 'cd src/env && ls'
allow 'which env'
allow 'python3 app.py --env prod'
allow 'git commit -m \"Add block-secrets hook\"'
allow 'cat .env.example.md.txt/README'
allow 'env -i PATH=/usr/bin make'
allow "rg 'export' src/"
allow 'grep -n \"set\" file'
allow 'git commit -m \"printenv support\"'
allow 'git commit -m \"docs: echo $HOME example\"'
allow 'declare -x FOO=1'
allow 'cp .env.example .env'
# Heredoc bodies are data unless they feed a shell.
allow "gh pr create --body-file - <<'EOF'\nIt also blocks echo \$HOME and printenv.\nEOF"
allow 'git commit -F - <<EOF\nDocs: cat .env and env examples\nEOF'
allow 'cat > notes.md <<-EOF\n\techo $SECRET\n\tEOF'
block 'bash <<EOF\nenv\nEOF'
block 'cat <<EOF | sh\nprintenv\nEOF'
block 'cat <<EOF\nhello\nEOF\nprintenv'
block 'cat <<< x; printenv'
check 0 '{ "session_id": "abc", "cwd": "/tmp", "tool_name": "Bash", "tool_input": { "command": "ls", "description": "List env files" } }'
check 0 ''

echo "---"
echo "$pass passed, $fail failed"
[ "$fail" -eq 0 ]
