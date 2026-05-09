#!/usr/bin/env bash
# =============================================================================
# PreToolUse: 위험 명령 차단
# =============================================================================
# Bash 도구 실행 전 위험한 명령어 패턴을 감지하여 차단합니다.
# exit 2 = 차단 (사용자에게 이유 표시), exit 0 = 허용
# =============================================================================

set -euo pipefail

INPUT=$(cat)

TOOL_NAME=$(echo "$INPUT" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    print(data.get('tool_name', ''))
except:
    print('')
" 2>/dev/null || echo "")

if [[ "$TOOL_NAME" != "Bash" ]]; then
    exit 0
fi

COMMAND=$(echo "$INPUT" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    print(data.get('tool_input', {}).get('command', ''))
except:
    print('')
" 2>/dev/null || echo "")

if [[ -z "$COMMAND" ]]; then
    exit 0
fi

# python3으로 따옴표/인용 안의 텍스트를 제거한 "실행 부분"만 추출하여 검사
RESULT=$(echo "$COMMAND" | python3 -c "
import sys, re

command = sys.stdin.read()

# 1) heredoc 본문 제거 (<<'EOF'...EOF, <<EOF...EOF)
command = re.sub(r\"<<-?\s*'?(\w+)'?.*?\n.*?\n\s*\1\", '', command, flags=re.DOTALL)

# 2) 따옴표 안 문자열 제거 (큰따옴표, 작은따옴표)
#    \$(cat <<'EOF' ... EOF) 같은 서브셸 안의 heredoc도 위에서 이미 제거됨
command = re.sub(r'\"(?:[^\"\\\\]|\\\\.)*\"', '\"\"', command)
command = re.sub(r\"'[^']*'\", \"''\", command)

# 3) echo, grep, cat, printf 뒤의 인자는 실행이 아니므로 해당 줄 제거
command = re.sub(r'^\s*(echo|grep|cat|printf|head|tail|awk|sed)\b.*$', '', command, flags=re.MULTILINE | re.IGNORECASE)

# 4) 주석 제거
command = re.sub(r'#.*$', '', command, flags=re.MULTILINE)

cmd_lower = command.lower()

dangerous = [
    ('rm -rf /', 'rm -rf /'),
    ('rm -rf .', 'rm -rf .'),
    ('drop table', 'DROP TABLE'),
    ('drop database', 'DROP DATABASE'),
    ('truncate ', 'TRUNCATE'),
    ('git push --force', 'git push --force'),
    ('git push -f ', 'git push -f'),
    ('git reset --hard', 'git reset --hard'),
    ('git clean -fd', 'git clean -fd'),
    ('chmod 777', 'chmod 777'),
    (':(){ :|:& };:', 'fork bomb'),
]

for pattern, label in dangerous:
    if pattern in cmd_lower:
        print(f'BLOCKED:{label}')
        sys.exit(0)

print('OK')
" 2>/dev/null || echo "OK")

if [[ "$RESULT" == BLOCKED:* ]]; then
    LABEL="${RESULT#BLOCKED:}"
    echo "[차단] 위험 명령 감지: $LABEL" >&2
    echo "  명령어: $(echo "$COMMAND" | head -1)..." >&2
    exit 2
fi

exit 0
