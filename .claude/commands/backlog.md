# 백로그 처리

백로그를 확인하고, Claude Code 에이전트 팀으로 작업을 진행합니다.
인자로 특정 티켓 제목/ID를 받을 수 있습니다. (예: `/backlog 로그인 기능`)

## 보드 찾기
- `board_list`로 내 보드 목록을 가져옵니다.
- CLAUDE.md에 `Board ID`가 있으면 해당 보드를 사용합니다.
- 없으면 `board_list` 결과에서 보드를 선택합니다 (1개면 자동 선택).
- 보드가 없으면 "Dev Board가 없습니다. Vuild 웹에서 프로젝트의 BUILD 단계를 시작하세요." 안내 후 종료.
- MCP 연결 실패 → `/setup`으로 MCP 설치 안내.

## 에이전트 목록
- 하드코딩하지 않음. Step 3의 `board_sync_agents` + `board_list_agents`로 동적 조회
- 로컬 `.claude/agents/*.md` 파일과 DB 에이전트가 자동 동기화됨
- 에이전트 spawn 시 slug 기반으로 `.claude/agents/{slug}.md` 파일을 찾아 사용:
  - 기본 에이전트: slug에 해당하는 subagent_type 사용 — "02-rails-dev" → `subagent_type: "rails-dev"`, "03-review-agent" → `subagent_type: "review-agent"`, "01-analyzer" → `subagent_type: "analyzer"`, "04-security-agent" → `subagent_type: "security-agent"`, "00-team-lead" → `subagent_type: "team-lead"`
  - 커스텀 에이전트 (웹에서 생성): `.claude/agents/{slug}.md` 파일을 Read로 읽은 뒤, 그 내용 전체를 Agent 도구의 prompt 앞에 "## 에이전트 페르소나\n{파일 내용}\n\n## 작업 지시\n{실제 지시}" 형식으로 포함. `subagent_type`은 생략 (기본 general-purpose)

## 실행 순서

### 1. 백로그 확인
- 인자가 **티켓 코드 패턴** (예: `FLO-001`, `VLD-003` — 영문-숫자 형식)이면 → `board_get_ticket`으로 해당 티켓을 바로 조회하여 Step 2로 진행
- 인자가 없거나 자연어이면 → `board_list_tickets` (status: "backlog")로 백로그 티켓 목록을 가져옵니다
- 각 티켓의 제목, 설명, 우선순위를 사용자에게 보여줍니다
- 사용자에게 어떤 티켓을 처리할지 물어봅니다

### 2. 부모 티켓 claim
- 선택된 티켓을 `board_claim_ticket`로 claim합니다 (agent_name: "team_lead")
- `board_add_activity`로 작업 시작 기록 (agent_name: "team_lead"):
  - message: "작업 시작 - [티켓 제목]"
- 이미 claim된 티켓이면 `board_get_ticket`로 상태를 확인하고 계속 진행합니다

### 3. 서브 티켓 생성 및 에이전트 위임
- `board_list_agents`로 보드에 등록된 에이전트 목록을 조회합니다
- 부모 티켓을 분석하여 구체적인 작업 단위로 분해합니다
- `board_delegate_task`로 각 서브 티켓을 생성합니다:
  - `ticket_id`: 부모 티켓 ID
  - `title`, `instruction`: 구체적인 작업 내용과 완료 기준
  - `agent_name`: 보드 에이전트의 **slug** 사용 (예: "02-rails-dev", "03-review-agent", "ux-designer"). `board_list_agents` 결과의 slug 필드 값과 일치해야 함
  - `priority`: 중요도에 따라 설정
- 서브 티켓 목록을 사용자에게 확인받습니다

### 4. 에이전트 팀 실행

**병렬 실행 판단**: 처리할 티켓이 여러 개이고, 티켓 description에 `[parallel: yes]`가 있으면:
- 사용자에게 "병렬 실행 가능한 티켓이 N개 있습니다. 병렬로 진행할까요?" 확인
- 승인 시 각 Rails Dev 에이전트를 `isolation: "worktree"`로 spawn
- 비승인 시 순차 실행

팀리드(메인 Claude)가 에이전트를 spawn하여 작업을 위임합니다:

#### 구현 에이전트 (subagent_type: "rails-dev")
- 작업 규모에 따라 1~3명 spawn
- 서브 티켓의 `agent_name`은 보드 에이전트의 slug("02-rails-dev")로 설정됨
- 각 에이전트가 `board_claim_ticket`으로 서브 티켓 claim
- TDD로 구현: 테스트 먼저 → 구현 → bin/ci 통과
- 완료 시 `board_update_ticket`로 상태를 `review`로 변경
- `board_add_activity`로 구현 결과 기록
- `SendMessage`로 팀리드에게 결과 보고

#### UX/UI 리뷰어 (subagent_type: "review-agent")
- 구현 완료 후 디자인 시스템 준수, 접근성, 반응형 검토
- `board_add_activity`로 리뷰 결과 기록

#### 테스트/품질 검증 (subagent_type: "review-agent")
- bin/ci 실행, 테스트 커버리지, N+1 쿼리 확인
- `board_add_activity`로 검증 결과 기록

### 5. 결과 수집 및 완료
- 모든 서브 티켓이 완료되면:
  - 부모 티켓을 `review`로 변경
  - `board_add_activity`로 세션 종합 기록
  - 팀 정리

## 에러 처리
- `board_claim_ticket` 실패 → 이미 다른 에이전트가 claim한 경우, 사용자에게 확인
- 팀원 에이전트 실패 → 실패한 서브 티켓만 새 팀원으로 재시도

## 다음 단계
- 작업 완료 시 → `/review`로 최종 리뷰 진행
- 전체 현황 → `/dashboard`
- 세션 종료 → `/handoff`
