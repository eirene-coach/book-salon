# 프로젝트 진행 보고서

프로젝트의 진행 상황을 종합 보고서로 생성합니다.

## 보드 찾기
- `board_list`로 내 보드 목록을 가져옵니다.
- CLAUDE.md에 `Board ID`가 있으면 해당 보드를 사용합니다.
- 없으면 `board_list` 결과에서 보드를 선택합니다 (1개면 자동 선택).
- 보드가 없으면 "Dev Board가 없습니다. Vuild 웹에서 프로젝트의 BUILD 단계를 시작하세요." 안내 후 종료.
- MCP 연결 실패 → `/setup`으로 MCP 설치 안내.

## 실행 순서

### 1. 데이터 수집
- `board_get_summary`로 상태별 티켓 수
- `board_list_tickets`로 전체 티켓 상세 목록
- in_progress, 최근 done 티켓의 `board_get_ticket`로 활동 로그
- 부모 티켓이 있으면 `board_get_delegation`로 서브 티켓 진행률

### 2. 보고서 생성
```
[프로젝트명] 진행 보고서 (YYYY-MM-DD)

■ 현황 요약
  backlog: N | claimed: N | in_progress: N | review: N | done: N

■ 완료된 작업 (최근)
  - [티켓 제목] (담당: OOO)

■ 진행 중
  - [티켓 제목] (담당: OOO) - 최근: [마지막 로그]

■ 서브 티켓 진행률
  - [부모 티켓]: N/M 완료 (NN%)
```

### 3. 다음 액션 제안
- 리뷰 대기 → `/review`
- 백로그 미처리 → `/backlog`
- 세션 종료 → `/handoff`
