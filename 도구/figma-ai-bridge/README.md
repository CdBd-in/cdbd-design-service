# figma-ai-bridge

Hammerspoon 데몬으로 Figma AI 메뉴 액션(Remove background / Extend image)을 HTTP로 트리거한다. CdBd 시안 Step 6 「누끼 가공」의 블록 단계를 자동화하기 위한 도구.

**스펙**: [[docs/superpowers/specs/2026-06-04-figma-ai-bridge-design.md]]

## 작동 원리

```
Claude(use_figma) → 노드 선택
        ↓ curl POST localhost:39632/v1/remove-bg
Hammerspoon 데몬
        ↓ Figma 활성화
        ↓ Cmd+/ → "remove background" → Enter
        ↓ timeout 대기
        ↓ 200 OK
Claude → exportAsync로 alpha 검증 → 재시도 or 다음 단계
```

## 설치

### 1. Hammerspoon 설치

| 방법 | 명령 |
|---|---|
| Homebrew | `brew install --cask hammerspoon` |
| 직접 다운로드 | https://github.com/Hammerspoon/hammerspoon/releases 의 최신 `.zip` |

### 2. 심볼릭 링크

```
cd <레포 루트>
bash 도구/figma-ai-bridge/install.sh
```

### 3. Hammerspoon 실행 + 권한 부여

```
open -a Hammerspoon
```

- 메뉴바 아이콘 → **Reload Config**
- 첫 실행 시 macOS 시스템 다이얼로그가 뜸:
  - System Settings → Privacy & Security → **Accessibility** → Hammerspoon ✓
  - System Settings → Privacy & Security → **Input Monitoring** → Hammerspoon ✓ (키 시뮬레이션용)

### 4. 헬스 체크

```
curl -sS http://127.0.0.1:39632/v1/health
# {"ok":true,"figma_running":true,"version":"0.1"}
```

## API

### `GET /v1/health`

```json
{ "ok": true, "figma_running": true, "version": "0.1" }
```

### `POST /v1/remove-bg`

**선결 조건**: `use_figma`로 대상 노드를 `figma.currentPage.selection`에 설정해 둘 것.

```bash
curl -sS -X POST http://127.0.0.1:39632/v1/remove-bg \
  -H 'Content-Type: application/json' \
  -d '{"timeout_ms": 5000}'
# {"ok":true,"elapsed_ms":5012}
```

| 필드 | 기본값 | 설명 |
|---|---|---|
| `timeout_ms` | 5000 | Quick Action 실행 후 결과 대기 시간(ms) |

### `POST /v1/extend-bg`

```bash
curl -sS -X POST http://127.0.0.1:39632/v1/extend-bg \
  -H 'Content-Type: application/json' \
  -d '{"prompt": "studio gray backdrop", "timeout_ms": 10000}'
```

| 필드 | 기본값 | 설명 |
|---|---|---|
| `prompt` | (필수) | Figma AI 배경 늘림 프롬프트 |
| `timeout_ms` | 10000 | 결과 대기 시간 |

### 에러

| HTTP | error 코드 | 의미 |
|---|---|---|
| 400 | `invalid_body_prompt_required` | extend-bg에 prompt 누락 |
| 404 | `not_found` | 정의 안 된 경로 |
| 409 | `figma_not_running` | Figma 프로세스 미발견 |

## 운영

- **로그**: Hammerspoon 메뉴바 → Console
- **포트 변경**: `init.lua` 상단 `PORT` 상수
- **검색어 변경** (Figma 한국어 설정 등): `REMOVE_BG_QUERY`, `EXTEND_BG_QUERY`
- **재로드**: 코드 수정 후 메뉴바 → Reload Config

## 트러블슈팅

| 증상 | 원인 후보 | 처치 |
|---|---|---|
| `curl: (7) Failed to connect` | Hammerspoon 미실행 / 포트 다름 | `open -a Hammerspoon`; 콘솔에서 로드 로그 확인 |
| Quick Action이 뜨지만 검색어가 안 들어감 | Accessibility/Input Monitoring 권한 미부여 | System Settings에서 두 권한 모두 ✓ |
| Quick Action이 안 뜸 | Figma가 백그라운드 / 단축키 충돌 | `:activate()` 후 200ms 대기 추가 필요할 수 있음. 다른 앱이 Cmd+/ 가로채는지 확인 |
| 검색 결과에 "Remove background"가 안 보임 | Figma AI 플랜 미가입 / Figma 언어가 한국어 | 플랜 확인. 한국어 UI면 상수 검색어를 그에 맞게 변경 |
| timeout 안에 결과가 안 옴 | 네트워크 느림 / 이미지 큼 | timeout_ms 더 길게. Claude 측 export 검증에서 실패 시 자동 재시도. |

## 한계

- macOS 전용 (Hammerspoon 의존)
- Figma 데스크톱 앱 전용 (브라우저 X)
- 키 시뮬레이션 기반이라 Figma UI 변경에 깨질 수 있음
- 동시 호출 안전성 보장 안 함 — Claude는 직렬 호출 가정
