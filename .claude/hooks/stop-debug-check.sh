#!/usr/bin/env bash
# =============================================================================
# Stop: 디버깅 잔여물 검출
# =============================================================================
# 세션 종료(또는 작업 완료) 시 staged/unstaged 변경에
# 디버깅 코드가 남아있으면 경고합니다.
# =============================================================================

set -euo pipefail

# git diff에서 디버깅 패턴 검색 (추가된 줄만)
DEBUG_PATTERNS="binding\.pry|binding\.irb|byebug|debugger|console\.log|puts ['\"]DEBUG|pp ['\"]DEBUG|Rails\.logger\.debug.*TODO|sleep [0-9].*#.*debug"

# staged + unstaged 변경에서 검색
FOUND=$(git diff HEAD --unified=0 2>/dev/null | grep -E "^\+" | grep -vE "^\+\+\+" | grep -iE "$DEBUG_PATTERNS" || true)

if [[ -n "$FOUND" ]]; then
    echo "" >&2
    echo "[경고] 디버깅 코드가 남아있습니다:" >&2
    echo "$FOUND" | head -10 | while read -r line; do
        echo "  $line" >&2
    done
    echo "" >&2
    echo "  커밋 전에 제거하세요." >&2
fi

exit 0
