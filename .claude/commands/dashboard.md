# 대시보드 현황 확인

Dev Board 진행 상황을 확인하고 다음 액션을 제안합니다.

## 보드 찾기
- `board_list`로 내 보드 목록을 가져옵니다.
- CLAUDE.md에 `Board ID`가 있으면 해당 보드를 사용합니다.
- 없으면 `board_list` 결과에서 보드를 선택합니다 (1개면 자동 선택).
- 보드가 없으면 "Dev Board가 없습니다. Vuild 웹에서 프로젝트의 BUILD 단계를 시작하세요." 안내 후 종료.
- MCP 연결 실패 → `/setup`으로 MCP 설치 안내.

## 실행 순서

### 1. 보드 요약 조회
- `board_get_summary`로 전체 현황을 가져옵니다
- 상태별 티켓 수를 표로 정리합니다

### 2. 상세 내역 파악
- `board_list_tickets`로 각 상태의 상세 티켓을 가져옵니다
- in_progress 티켓의 `board_get_ticket`으로 최근 활동을 확인합니다
- 부모 티켓이 있으면 `board_get_delegation`으로 서브 티켓 진행률 확인

### 3. 다음 액션 제안
- review 티켓이 있으면 → `/review`로 리뷰 후 완료 처리
- 모든 서브 티켓이 완료된 부모 티켓 → 부모 티켓 done 처리 확인
- backlog에 미처리 티켓 → `/backlog`로 작업 시작
- 모두 완료 → "모든 작업이 완료되었습니다"
