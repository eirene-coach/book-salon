# 리뷰 대기 티켓 검증 및 완료 처리

review 상태인 티켓들을 검증하고, 승인/반려 처리합니다.

## 보드 찾기
- `board_list`로 내 보드 목록을 가져옵니다.
- CLAUDE.md에 `Board ID`가 있으면 해당 보드를 사용합니다.
- 없으면 `board_list` 결과에서 보드를 선택합니다 (1개면 자동 선택).
- 보드가 없으면 "Dev Board가 없습니다. Vuild 웹에서 프로젝트의 BUILD 단계를 시작하세요." 안내 후 종료.
- MCP 연결 실패 → `/setup`으로 MCP 설치 안내.

## 사용 가능한 에이전트 (.claude/agents/)

| 에이전트 | 역할 | spawn 시점 |
|---------|------|-----------|
| Review Agent (`03-review-agent.md`) | 코드 품질 리뷰 (SOLID, N+1, DRY) | 코드 리뷰 |
| Security Agent (`04-security-agent.md`) | 보안 감사 (OWASP, Brakeman) | 보안 검증 |

## 실행 순서

### 1. 리뷰 대기 티켓 조회
- `board_list_tickets`로 status "review"인 티켓들을 가져옵니다
- 리뷰할 티켓이 없으면 안내 후 종료

### 2. 사전 검증
- `bin/ci` 실행하여 기본 품질 확인
- 실패 시 티켓을 in_progress로 되돌리고 수정 안내

### 3. 티켓 검증 명령어 실행
- `board_get_ticket`으로 티켓 description을 읽습니다
- description에 `## 검증 명령어` 섹션이 있으면 해당 명령어를 실행합니다
  - 예: `bin/rails test test/models/user_test.rb`
  - 예: `docker compose exec -T web bin/rails test test/controllers/api/`
- 검증 명령어가 실패하면 티켓을 in_progress로 되돌리고 실패 사유를 기록합니다
- 검증 명령어가 없으면 이 단계를 건너뛰고 다음 단계로 진행합니다

### 4. 코드 리뷰
- 코드 품질 (SOLID, N+1, DRY, 테스트 커버리지)
- 보안 (XSS, SQL injection, CSRF, 인증/인가)
- UX/UI (디자인 시스템 준수, 접근성, 반응형)

### 5. 상태 업데이트
- 승인: `board_update_ticket`로 "done"으로 변경
- 반려: `board_update_ticket`로 "in_progress"로 되돌림 + 사유 기록
- `board_add_activity`로 리뷰 결과 기록

### 6. 부모 티켓 처리
- `board_get_delegation`로 서브 티켓이 모두 done인지 확인
- 모두 완료 시 부모 티켓도 "done"으로 변경

## 다음 단계
- 모든 리뷰 완료 → `/deploy`로 배포
- 반려 티켓 있음 → `/backlog`로 재작업
- 보고서 생성 → `/report`
