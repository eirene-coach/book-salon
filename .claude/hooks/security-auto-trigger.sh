#!/usr/bin/env bash
# =============================================================================
# Rails Security Auto-Trigger Hook
# =============================================================================
# PostToolUse 훅: Edit/Write 도구로 보안 민감 파일 수정 시 보안 리뷰를 권장합니다.
#
# 트리거: Edit, Write 도구 실행 후
# 동작: 보안 관련 파일 패턴 감지 → stderr로 경고 메시지 출력
# 차단: 없음 (항상 exit 0, 경고만 제공)
#
# 설치: settings.json의 hooks.PostToolUse에 등록
# =============================================================================

set -euo pipefail

# stdin에서 JSON 읽기
INPUT=$(cat)

# 도구 이름 확인 (Edit 또는 Write만 처리)
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

# 파일 경로 추출
FILE_PATH=$(echo "$INPUT" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    inp = data.get('tool_input', {})
    print(inp.get('file_path', ''))
except:
    print('')
" 2>/dev/null || echo "")

if [[ -z "$FILE_PATH" ]]; then
    exit 0
fi

# 중복 방지: 세션당 동일 파일에 1회만 경고
SUGGEST_DIR="/tmp/rails-security-suggest-$$"
mkdir -p "$SUGGEST_DIR" 2>/dev/null || true
MARKER=$(echo "$FILE_PATH" | md5sum 2>/dev/null | cut -d' ' -f1 || echo "$FILE_PATH" | shasum | cut -d' ' -f1)

if [[ -f "$SUGGEST_DIR/$MARKER" ]]; then
    exit 0
fi

# ─── Rails 보안 민감 파일 패턴 ───

# 인증/세션 관련
AUTH_PATTERNS="session|auth|login|signup|registration|password|token|jwt|oauth|credential|devise|omniauth"

# 사용자/권한 모델
USER_PATTERNS="user|account|admin|role|permission|ability"

# 설정 파일
CONFIG_PATTERNS="\.env|credentials|master\.key|secrets|initializers/devise|initializers/omniauth|initializers/session"

# API/라우트
API_PATTERNS="api/|routes\.rb"

# 암호화/보안
CRYPTO_PATTERNS="encrypt|decrypt|hash|crypto|ssl|certificate"

# 파일 업로드
UPLOAD_PATTERNS="upload|attachment|active_storage|blob"

# DB 마이그레이션 (권한/인증 관련)
MIGRATION_PATTERNS="db/migrate"

# 패턴 매칭 (대소문자 무시)
FILE_LOWER=$(echo "$FILE_PATH" | tr '[:upper:]' '[:lower:]')

MATCHED_PATTERN=""

if echo "$FILE_LOWER" | grep -qiE "$AUTH_PATTERNS"; then
    MATCHED_PATTERN="인증/세션"
elif echo "$FILE_LOWER" | grep -qiE "$CONFIG_PATTERNS"; then
    MATCHED_PATTERN="보안 설정"
elif echo "$FILE_LOWER" | grep -qiE "$API_PATTERNS"; then
    MATCHED_PATTERN="API/라우트"
elif echo "$FILE_LOWER" | grep -qiE "$CRYPTO_PATTERNS"; then
    MATCHED_PATTERN="암호화/보안"
elif echo "$FILE_LOWER" | grep -qiE "$UPLOAD_PATTERNS"; then
    MATCHED_PATTERN="파일 업로드"
elif echo "$FILE_LOWER" | grep -qiE "$USER_PATTERNS"; then
    # user 패턴은 모델/컨트롤러에만 적용 (너무 넓은 매칭 방지)
    if echo "$FILE_LOWER" | grep -qiE "app/(models|controllers)/"; then
        MATCHED_PATTERN="사용자/권한"
    fi
elif echo "$FILE_LOWER" | grep -qiE "$MIGRATION_PATTERNS"; then
    MATCHED_PATTERN="DB 마이그레이션"
fi

# 매칭된 경우 경고 출력
if [[ -n "$MATCHED_PATTERN" ]]; then
    # 마커 파일 생성 (중복 방지)
    touch "$SUGGEST_DIR/$MARKER"

    # stderr로 경고 (사용자에게 표시)
    echo "[Security] 보안 관련 파일 수정 감지: $(basename "$FILE_PATH") (패턴: $MATCHED_PATTERN)" >&2
    echo "  커밋 전 /review 실행을 권장합니다. (security-pipeline 스킬 참조)" >&2
fi

exit 0
