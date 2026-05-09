# Vuild MCP 설치 및 프로젝트 연결

Vuild Dev Board MCP 서버를 설치하고, 현재 디렉토리를 Vuild 프로젝트/보드에 연결합니다.

## 실행 순서

### 1. MCP 연결 확인
- `board_list`를 호출하여 vuild MCP가 이미 연결되어 있는지 확인합니다.
- **연결 실패** → 2단계 (MCP 설치)로 진행
- **연결 성공** → 4단계 (프로젝트 연결 확인)로 진행

### 2. API 토큰 확보
- `.claude/settings.json`을 읽어서 `mcpServers.vuild.env.VUILD_API_TOKEN` 값을 가져옵니다.
- settings.json에 없으면 `CLAUDE.md`에서 `API Token` 값을 읽습니다.
- 둘 다 없으면 사용자에게 물어봅니다: "Vuild API 토큰을 입력해주세요. (https://vuild.kr/my/api_token 에서 발급)"

### 3. MCP 서버 설치 실행
- 토큰을 확보했으면 아래 명령어를 **Bash로 직접 실행**합니다:

```bash
echo "{토큰}" | npx -y vuild-cli@latest
```

⚠️ `{토큰}` 부분을 실제 API 토큰 값으로 치환한 뒤 실행하세요.
⚠️ `claude mcp add -e` 명령어는 버그로 동작하지 않으므로 **절대 사용하지 마세요.**

설치 성공 시 사용자에게 안내합니다:
```
Vuild MCP 설치 완료!
Claude Code를 재시작한 후 /setup을 다시 실행하면 프로젝트/보드 연결이 자동으로 진행됩니다.
```
→ 여기서 종료. 재시작 후 사용자가 `/setup`을 다시 실행하면 1단계부터 다시 시작되어 4단계로 진행됩니다.

### 4. 프로젝트 연결 확인 (MCP 연결된 상태)
- `.claude/settings.json`의 `mcpServers.vuild.env`에 `VUILD_BOARD_ID`가 설정되어 있는지 확인합니다.
- **이미 설정됨** → 4.5단계 (setup_mode 조회)로 진행
- **설정 안 됨** → **자동으로 `/init-project` 흐름을 실행**합니다.
  - `init-project.md`의 1~7단계를 그대로 수행합니다 (프로젝트 이름만 사용자에게 한 번 확인).
  - 완료 후 종료 (재시작 안내까지 포함됨).

### 4.5. setup_mode 조회 (신규)

- `get_project_context` MCP 도구를 호출하여 `project.setup_mode` 값을 가져옵니다.
- `basic` 또는 `pro` 둘 중 하나. 기본값은 `basic`.
- 이후 환경 검사가 mode 기반으로 분기됩니다.

### 5. 환경 검사 + 설치 (신규)

> 원칙: **사용자에게 묻지 말고 자동으로 default 진행.** 설치 가능한 건 그냥 설치. 실패 시에만 사용자에게 안내.

#### 5-1. Ruby/Node/Bundler (모드 무관 공통)

자동 검사 + 부족 시 OS별 명령으로 설치:
- `ruby --version` (3.2 이상). 없으면:
  - macOS: `brew install ruby@3.3` 또는 `mise install ruby@3.3`
  - Linux/WSL: `sudo apt install ruby-full` (또는 mise/rbenv 권장)
  - Windows native: RubyInstaller 안내 후 PATH 추가 안내까지 (`Ruby40-x64\bin` 같은 경로)
- `node --version` (20 이상). 없으면:
  - macOS: `brew install node`
  - Linux/WSL: `sudo apt install nodejs npm`
  - Windows native: Node.js MSI 설치 안내
- `bundle --version`. 없으면 `gem install bundler` 자동 실행

#### 5-2. Rails 자체 (모드 무관 공통, **반드시 자동 설치**)

- `gem list rails -i -v "~> 8.1"` 검사
- 없으면 → `gem install rails -v 8.1.2` **자동 실행 (사용자에게 묻지 말 것)**
- 설치 후 `rails --version`으로 확인 (`Rails 8.1.x` 출력)

> ⚠️ 이 단계가 빠지면 다음 build_step에서 `rails new`가 실패. 반드시 `/setup` 안에서 끝낼 것.

#### 5-3. PATH 검증 (Windows native만)

Ruby/Rails는 설치됐지만 새 셸 세션이 PATH 갱신 못 받았을 가능성:
- `where ruby` 또는 `where rails` 결과 비어 있으면 → 사용자에게:
  - "VSCode/터미널을 한 번 재시작해주세요" (가장 깔끔)
  - 또는 직접 풀 경로로 호출하는 방법 제시 (`& "C:\Ruby40-x64\bin\ruby.exe"`)

#### 5-4. setup_mode == "pro" 추가 검사

- Windows에서 WSL 검사: `wsl --status` (PowerShell) → 없으면 "PowerShell 관리자로 `wsl --install` 실행 후 재부팅하고 WSL Ubuntu에서 다시 시도하세요" 안내
- `psql --version` → 없으면 OS별 설치 명령:
  - macOS: `brew install postgresql@16 && brew services start postgresql@16`
  - WSL/Linux: `sudo apt install postgresql-16 postgresql-contrib && sudo service postgresql start`
- `redis-cli --version` → 없으면:
  - macOS: `brew install redis && brew services start redis`
  - WSL/Linux: `sudo apt install redis-server && sudo service redis-server start`

#### 5-5. 보고 형식

각 단계 결과를 한 줄로 사용자에게:
```
✓ Ruby 3.3.5 / ✓ Node 22.18 / ✓ Bundler 2.5 / ✓ Rails 8.1.2 (방금 설치)
✓ PostgreSQL 16 / ✓ Redis 7  (pro 모드)
```
실패한 항목만 빨간색 + 해결 방법 1줄. 자동 진행 가능한 건 자동 진행.

### 6. Rails 앱 의존성 설치 (신규)

현재 디렉토리에 `Gemfile`이 있고 사용자가 Rails 앱 폴더 안이라면:
- `bundle install` 실행 (실패 시 에러를 분석하여 도움)
- `bin/rails db:create db:migrate` 실행
- 성공 메시지: "환경 준비 완료! `bin/dev`로 서버를 시작할 수 있습니다."

`Gemfile`이 없으면 (아직 `rails new` 실행 전이면) 이 단계는 건너뛰고 안내: "다음 빌드 단계에서 Rails 앱을 생성합니다. `/dashboard`로 진행하세요."

### 7. 현재 보드 현황 표시
- `VUILD_BOARD_ID`가 이미 설정된 경우: 보드 이름과 티켓 수 정도를 간단히 보여주고 종료합니다.
- 안내 문구:
  ```
  Vuild MCP 연결됨 — 보드 [#ID] [name]
  다음 단계:
    /dashboard → 보드 현황 확인
    /plan [기능 설명] → 기능 계획
    /ticket [티켓 내용] → 빠른 티켓 생성
  ```

## 에러 처리
- MCP 설치 실패 → 에러 메시지를 보여주고 수동 설치 방법 안내
- Node.js/npx 미설치 → "Node.js 18 이상을 먼저 설치해주세요" 안내
- `/init-project` 단계에서 실패 → 해당 커맨드의 에러 처리 절차를 따름

## 다음 단계

setup_mode에 따라:
- **기본 (basic)**: SQLite + Solid Queue/Cache로 즉시 작업 가능. `/dashboard`에서 빌드 단계 확인.
- **심화 (pro)**: PostgreSQL + Redis 연결됨. 같은 흐름이지만 정통 환경에서 작업.

공통 다음 명령:
- `/dashboard` → 보드 현황 확인
- `/plan` → 기능 계획 → 백로그 티켓 생성
- `/ticket` → 빠른 티켓 생성
- `/backlog` → 백로그 작업 처리
