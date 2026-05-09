# 빠른 티켓 생성/수정

티켓을 빠르게 생성하거나 수정합니다.
인자로 티켓 내용을 받습니다. (예: `/ticket 로그인 화면에 비밀번호 찾기 링크 추가`)

## 보드 찾기
- `.claude/settings.json`의 `mcpServers.vuild.env.VUILD_BOARD_ID`가 있으면 해당 보드를 사용합니다.
- 없으면 CLAUDE.md의 `Board ID`를 확인합니다.
- 둘 다 없으면 `board_list` 결과를 확인합니다 (1개면 자동 선택, 여러 개면 사용자에게 선택 요청).
- 보드가 아예 없으면 "이 프로젝트에 연결된 Dev 보드가 없습니다. `/init-project`로 새 프로젝트/보드를 생성하세요." 안내 후 종료.
- MCP 연결 실패 → `/setup`으로 MCP 설치 안내.

## 실행 순서

### 1. 입력 분석
- 입력이 **티켓 코드 패턴** (예: `FLO-001`, `VLD-003`, `ABC-123` — 영문-숫자 형식)이면 → **기존 티켓 조회** (Step 2a)
- 그 외 자연어 설명이면 → **새 티켓 생성** (Step 2b)
- 인자가 없으면 사용자에게 물어봅니다

### 2a. 기존 티켓 조회 (티켓 코드 입력 시)
- `board_get_ticket`으로 해당 티켓 조회 (ticket_id에 코드 문자열 전달)
- 티켓을 찾으면 상세 정보를 출력하고, 사용자에게 다음 액션을 제안:
  - 상태 변경 (backlog → claimed → in_progress 등)
  - 내용 수정
  - 작업 시작 → `/backlog`
- 티켓을 못 찾으면 "해당 티켓을 찾을 수 없습니다" 안내

### 2b. 새 티켓 생성 (자연어 설명 입력 시)
- 사용자 설명에서 추출:
  - **title**: 핵심을 담은 간결한 제목
  - **description**: 상세 설명 + 완료 기준
  - **priority**: 긴급도 판단 (기본: medium)

### 3. 중복 확인 (새 티켓 생성 시만)
- `board_list_tickets`로 비슷한 제목의 기존 티켓이 있는지 확인합니다
- 중복이 있으면 사용자에게 "기존 티켓을 수정할까요, 새로 만들까요?" 확인

### 4. 티켓 생성
- `board_create_ticket`로 생성:
  - `board_id`: CLAUDE.md의 Board ID
  - `status`: "backlog"
  - `priority`: 추출된 우선순위
- `board_add_activity`로 생성 기록

### 5. 결과 보고
```
티켓 생성 완료:
  제목: [title]
  우선순위: [priority]
  ID: [ticket_id]
```

## 다음 단계
- 추가 티켓 생성 → `/ticket`
- 바로 작업 시작 → `/backlog`
- 현황 확인 → `/dashboard`
