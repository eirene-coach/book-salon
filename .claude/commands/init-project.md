# 새 Vuild 프로젝트/보드 생성 및 연결

현재 작업 디렉토리를 새 Vuild 프로젝트(또는 기존 프로젝트)에 연결하고, Dev 보드를 생성합니다.
`board_id`/`project_id`를 settings.json과 CLAUDE.md에 자동으로 기록합니다.

## 실행 조건

- vuild MCP가 이미 연결되어 있어야 합니다.
- 연결되어 있지 않으면 `/setup`을 먼저 실행하라고 안내하고 종료합니다.

## 실행 순서

### 1. 프로젝트 이름 추출 및 확인
- 다음 순서로 후보 이름을 결정합니다:
  1. `git remote get-url origin`이 있으면 → 마지막 path 세그먼트 (`.git` 제거)
  2. 그 외 → 현재 디렉토리 basename
- 사용자에게 한 번만 확인합니다:
  ```
  새 Vuild 프로젝트를 "[추출한 이름]"으로 만들겠습니다. 이 이름으로 진행할까요?
  (다른 이름을 쓰려면 입력해주세요)
  ```
- 사용자가 다른 이름을 입력하면 그 이름을 사용합니다. 이 값을 `title`로 확정합니다.

### 1.5. 영문 식별자(`title_en`) 결정
- 다운로드 파일명(`*-build-kit.zip` 등)에 사용할 ASCII-safe 슬러그를 함께 생성합니다.
- 결정 규칙:
  1. 확정된 `title`이 영문/숫자/하이픈으로만 구성되면 → 소문자화한 값을 그대로 `title_en`으로 사용 (예: `valueit` → `valueit`, `MyProject` → `my-project`)
  2. `title`에 한글 등 비-ASCII 문자가 포함되면 → 의미를 살린 짧은 영문 슬러그를 생성 (예: `"발류잇"` → `valueit`, `"롱품 자동화 크롬 확장 도구"` → `lompum-auto-chrome-ext`). 추정이 어려우면 사용자에게 한 번만 확인:
     ```
     영문 식별자(파일명용)는 "[추정한 슬러그]"로 하겠습니다. 다른 값을 쓰려면 입력해주세요.
     ```
- 형식 규칙: 소문자 + 숫자 + 하이픈만. 공백/특수문자/한글 금지. 예: `youtube-manager`, `dev-connect`.

### 2. 기존 프로젝트 확인
- `list_projects`를 호출하여 같은 이름(대소문자 무시)의 프로젝트가 이미 있는지 확인합니다.
- **있으면**: 사용자에게 묻습니다:
  ```
  같은 이름의 프로젝트가 이미 있습니다: [#ID] [title]
  - 1) 기존 프로젝트에 연결
  - 2) 새 프로젝트 생성 (이름 자동 변경)
  ```
- **없으면**: 곧바로 3단계로 진행합니다.

### 3. 프로젝트 생성 (또는 기존 프로젝트 사용)
- 새로 생성: `create_project({ title: "[이름]", title_en: "[영문 슬러그]", starting_phase: "build" })`
  - `title_en`은 1.5단계에서 확정한 값입니다. 반드시 함께 전달하세요.
- 기존 사용: 1단계에서 선택한 `project_id`를 그대로 사용합니다.
- 응답에서 `project_id`를 확보합니다.

### 4. Dev 보드 생성
- `board_create({ project_id: [확보한 project_id] })`를 호출합니다.
  - 프로젝트에 이미 보드가 있으면 기존 보드가 반환됩니다 (server-side 멱등).
- 응답에서 `board_id`와 `board.name`을 확보합니다.

### 5. settings.json 업데이트
- `.claude/settings.json`의 `mcpServers.vuild.env`에 다음 두 키를 추가/갱신합니다:
  ```json
  {
    "mcpServers": {
      "vuild": {
        "command": "node",
        "args": ["mcp-server/src/index.js"],
        "env": {
          "VUILD_API_TOKEN": "[기존 토큰 유지]",
          "VUILD_PROJECT_ID": "[project_id]",
          "VUILD_BOARD_ID": "[board_id]"
        }
      }
    }
  }
  ```
- ⚠️ 기존 키(`VUILD_API_TOKEN` 등)는 절대 덮어쓰지 마세요. 두 키만 추가/갱신합니다.
- ⚠️ JSON 형식이 깨지지 않도록 주의하세요.

### 6. CLAUDE.md 업데이트
- 프로젝트 루트의 `CLAUDE.md`에 다음 섹션이 없으면 추가하고, 있으면 값만 갱신합니다:
  ```markdown
  ## Vuild 프로젝트 연결
  - Project ID: [project_id]
  - Board ID: [board_id]
  - 보드 URL: https://vuild.kr/dev/[board_id]
  ```
- CLAUDE.md가 없으면 새로 생성하고 위 섹션을 작성합니다.

### 7. 결과 보고
사용자에게 아래 형식으로 안내합니다:
```
프로젝트 연결 완료
  프로젝트: [#project_id] [title]
  Dev 보드: [#board_id] [board name]
  보드 URL: https://vuild.kr/dev/[board_id]

settings.json과 CLAUDE.md가 업데이트되었습니다.
환경변수가 적용되도록 Claude Code를 재시작해주세요.

재시작 후:
  - /dashboard → 보드 현황 확인
  - /plan [기능 설명] → 기능 계획 → 백로그 티켓 생성
  - /ticket [티켓 내용] → 빠른 티켓 생성
```

## 에러 처리
- vuild MCP 미연결 → "먼저 /setup으로 MCP를 설치해주세요" 안내 후 종료
- `create_project` 실패 (4xx) → 토큰 권한 또는 입력값 문제일 수 있음. 에러 메시지 표시
- `board_create` 실패 → 프로젝트는 생성되었으므로 사용자에게 project_id를 알려주고 수동 재시도 안내

## 다음 단계
- `/dashboard` → 보드 현황 확인
- `/plan` → 기능 계획 → 백로그 티켓 생성
- `/ticket` → 빠른 티켓 생성
