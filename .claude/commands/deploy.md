# 배포 및 티켓 완료 처리

코드를 배포하고, 관련 티켓들을 완료 처리합니다.

## 보드 찾기
- `board_list`로 내 보드 목록을 가져옵니다.
- CLAUDE.md에 `Board ID`가 있으면 해당 보드를 사용합니다.
- 없으면 `board_list` 결과에서 보드를 선택합니다 (1개면 자동 선택).
- 보드가 없으면 "Dev Board가 없습니다. Vuild 웹에서 프로젝트의 BUILD 단계를 시작하세요." 안내 후 종료.
- MCP 연결 실패 → `/setup`으로 MCP 설치 안내.

## 실행 순서

### 1. 배포 전 확인
- 테스트 실행하여 전체 통과 확인
- `git status`로 미커밋 변경사항 확인
- `board_get_summary`로 보드 현황 파악
- `board_list_tickets`로 review, in_progress 상태 티켓 확인

### 2. 사용자 확인
- 배포 예정 커밋과 관련 티켓을 보여주고 확인

### 3. 배포 실행
- 배포 후 결과 확인

### 4. 티켓 완료 처리 (배포 성공 시)
- `board_get_delegation`로 서브 티켓 완료 확인
- 완료된 부모 티켓 → `board_update_ticket`로 "done"으로 변경
- `board_add_activity`로 배포 기록

### 5. 배포 실패 시
- 에러 로그 표시
- 관련 티켓에 `board_add_activity`로 실패 기록

## 다음 단계
- 보고서 생성 → `/report`
- 세션 종료 → `/handoff`
