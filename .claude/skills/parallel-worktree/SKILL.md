# 병렬 워크트리 운영 가이드

## 언제 병렬을 쓰는가

### 병렬 OK
- 수정 파일이 겹치지 않는 독립 기능 (예: "결제 모듈" + "대시보드 위젯")
- Analyzer가 다음 티켓 분석하는 동안 Rails Dev가 현재 티켓 구현
- Review Agent가 리뷰하는 동안 다음 작업 진행
- main에서 핫픽스 + feature 브랜치 작업 유지

### 병렬 금지
- 같은 모델/컨트롤러를 수정하는 작업
- DB 마이그레이션이 겹치는 작업
- routes.rb 같은 블록을 수정하는 작업
- 한쪽 결과에 의존하는 작업

### 판단 체크리스트
```
[ ] 수정 파일이 겹치지 않는가?
[ ] DB 마이그레이션이 겹치지 않는가?
[ ] 한쪽 완료를 기다릴 필요가 없는가?
→ 모두 Yes면 병렬 가능
```

---

## 사용법

### Agent 도구의 isolation: "worktree" 옵션

팀리드가 에이전트를 spawn할 때 워크트리 격리를 사용합니다:

```
Agent(
  subagent_type: "rails-dev",
  isolation: "worktree",
  prompt: "티켓 #42 작업..."
)
```

이렇게 하면 Claude Code가 자동으로:
1. 임시 git worktree 생성
2. 독립 브랜치에서 작업
3. 변경사항이 있으면 worktree 경로와 브랜치 반환
4. 변경이 없으면 자동 정리

### 사용자가 직접 병렬 실행할 때

터미널을 2-3개 열고 각각 `claude`를 실행:
```
터미널1: claude → /backlog → 티켓A 선택
터미널2: claude → /backlog → 티켓B 선택
```

각 터미널이 다른 git 브랜치에서 작업하도록 사전에 분리:
```bash
# 터미널1
git checkout -b wt/42-payment

# 터미널2 (별도 worktree)
git worktree add ../project-wt-43 -b wt/43-dashboard
cd ../project-wt-43
claude
```

---

## 브랜치 컨벤션

```
wt/<티켓ID>-<설명>

예시:
wt/42-payment-module
wt/43-dashboard-widget
wt/hotfix-login-bug
```

---

## 충돌 방지 매트릭스

| 작업A \ 작업B | 별도 모델 | 같은 모델 | routes.rb | 마이그레이션 |
|--------------|----------|----------|-----------|------------|
| 별도 모델 | 안전 | 금지 | 주의 | 조건부 |
| 같은 모델 | 금지 | 금지 | 금지 | 금지 |
| routes.rb | 주의 | 금지 | 금지 | 금지 |
| 마이그레이션 | 조건부 | 금지 | 금지 | 금지 |

- **안전**: 병렬 가능
- **주의**: routes.rb에 각각 다른 리소스 추가 시 가능
- **조건부**: 마이그레이션이 다른 테이블이면 가능
- **금지**: 직렬 실행 필수

---

## Merge 순서

1. 먼저 완료된 브랜치를 main에 merge
2. 다른 브랜치에서 `git rebase main`
3. 충돌 있으면 해결 후 merge
4. DB 마이그레이션 포함 브랜치를 항상 먼저 merge

---

## 제한

- 동시 최대 **3 워크트리** (main + 2 feature)
- 처음에는 2개(main + 1)로 시작, 안정되면 3개로 확장
- DB 마이그레이션이 포함된 작업은 항상 직렬

---

## 워크트리 정리

```bash
# 워크트리 목록 확인
git worktree list

# 완료된 워크트리 제거
git worktree remove ../project-wt-43

# 브랜치 정리
git branch -d wt/43-dashboard-widget
```

`/handoff` 실행 시 남은 워크트리가 있으면 정리 여부를 확인합니다.
