#!/usr/bin/env bash
# =============================================================================
# PostToolUse: Ruby 파일 수정 시 rubocop 자동 교정
# =============================================================================
# Edit/Write 도구로 .rb 파일 수정 후 rubocop -A를 자동 실행합니다.
# CI 실패의 단순 포맷 이슈를 사전 제거합니다.
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

if [[ "$TOOL_NAME" != "Edit" && "$TOOL_NAME" != "Write" ]]; then
    exit 0
fi

FILE_PATH=$(echo "$INPUT" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    print(data.get('tool_input', {}).get('file_path', ''))
except:
    print('')
" 2>/dev/null || echo "")

if [[ -z "$FILE_PATH" ]]; then
    exit 0
fi

# .rb 파일만 처리
if [[ "$FILE_PATH" != *.rb ]]; then
    exit 0
fi

# 파일 존재 확인
if [[ ! -f "$FILE_PATH" ]]; then
    exit 0
fi

# rubocop 자동 교정 (safe autocorrect만)
if command -v docker &> /dev/null && docker compose ps web --status running &> /dev/null 2>&1; then
    # Docker 환경
    docker compose exec -T web bundle exec rubocop -A --fail-level=error "$FILE_PATH" > /dev/null 2>&1 || true
elif command -v rubocop &> /dev/null; then
    # 로컬 환경
    rubocop -A --fail-level=error "$FILE_PATH" > /dev/null 2>&1 || true
fi

exit 0
