# 에이전트 동기화

웹 Dev Board의 에이전트와 로컬 `.claude/agents/` 파일을 동기화합니다.
**DB(보드)가 마스터입니다. 보드에 있는 에이전트만 로컬에 남깁니다.**

## 실행 순서

### 1. 보드 찾기
- `board_list`로 내 보드 목록을 가져옵니다.
- CLAUDE.md에 `Board ID`가 있으면 해당 보드를 사용합니다.
- 없으면 `board_list` 결과에서 보드를 선택합니다 (1개면 자동 선택).

### 2. 로컬 파일 읽기
- `.claude/agents/` 디렉토리의 모든 `.md` 파일을 Read로 읽습니다.

### 3. board_sync_agents 호출
- agents 배열 구성:
  ```
  각 .md 파일마다:
  {
    slug: "파일명에서 .md 제거한 값",
    name: "frontmatter의 name 값 또는 slug",
    system_prompt: "파일 전체 내용 (frontmatter + 본문 전체, 그대로)",
    expertise: "frontmatter의 description 첫 줄 또는 빈 문자열"
  }
  ```
  **system_prompt에는 파일 전체 내용을 그대로 넣어야 합니다. 요약하거나 생략하지 마세요.**

### 4. 응답 처리 — 반드시 모두 실행

#### 4-1. db_only (웹에서 추가된 에이전트)
- 각 항목의 `file_content`를 `.claude/agents/{filename}`에 **그대로** Write합니다
- 내용을 수정하거나 재생성하지 마세요

#### 4-2. local_only (보드에서 해고된 에이전트) — 필수!
- **반드시 실행**: 각 slug에 해당하는 `.claude/agents/{slug}.md` 파일을 Bash `rm` 명령으로 삭제합니다
- 예: `rm .claude/agents/01-analyzer.md .claude/agents/04-security-agent.md`
- 이 단계를 건너뛰면 해고된 에이전트가 다음 동기화에서 계속 업로드됩니다
- local_only가 비어있으면 삭제할 파일 없음

### 5. 결과 보고
동기화 결과를 사용자에게 보여줍니다:
- 업데이트된 에이전트 수 (보드에 소속된 것만)
- 새로 생성된 로컬 파일 (db_only)
- **삭제된 로컬 파일 (local_only) — 삭제 실행 여부 반드시 명시**
