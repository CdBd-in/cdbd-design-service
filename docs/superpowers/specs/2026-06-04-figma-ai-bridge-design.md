# figma-ai-bridge — 설계 스펙

**작성일**: 2026-06-04
**상태**: 🔴 **중단됨** (2026-06-04, MVP 통합 테스트 실패 후 의사결정). 자세한 사유는 본 문서 마지막 「Post-Mortem」 참조.
**저자**: Claudian (CdBd 디자인 서비스)
**관련 문서**: [[CLAUDE.md]], [[1-2. 시안]] Step 6, [[2-1. 공통]] 「로고·누끼 이미지 처리」

---

## 1. 배경과 문제

CdBd 디자인 서비스의 시안·초안 제작은 `use_figma` MCP 자동화로 대부분 무인 진행된다. 그러나 **누끼 가공(Remove background)** 과 **화보 배경 늘림(Generative fill)** 두 단계만은 자동화에서 빠져 있다. 이유는 Figma AI 기능이 **에디터 전용 메뉴 액션**이고 Plugin API에 노출돼 있지 않기 때문이다 (CLAUDE.md 「⚠️ Figma AI는 에디터 전용」 참조).

결과적으로 현재 워크플로우는:

1. Claude가 누끼 원본을 별도 위치에 업로드
2. **사용자에게 "에디터에서 Remove background 적용" 요청** ← 블록
3. **사용자의 「가공 완료」 신호 대기** ← 블록
4. swp/scl product 셀 빌드 재개

이 블록 단계가 브랜드당 수십 장의 누끼를 가공해야 할 때 워크플로우 전체의 종단 지연을 결정한다.

## 2. 목표 / 비목표

**목표**
- 시안 Step 6의 사용자 개입 없는 자동화
- Figma AI 두 기능 모두 지원: Remove background, Extend image (배경 늘림)
- CLAUDE.md "Figma AI만 사용" 정책 유지 (외부 ML/AI 서비스 추가 안 함)
- 데몬 미실행/실패 시 기존 수동 fallback 보존

**비목표 (YAGNI)**
- Linux/Windows 포팅 (CdBd 작업은 macOS에서 진행)
- Figma AI 그 외 기능 (Make designs, AI text 등)
- GUI 설정 패널
- 다중 노드 배치 자동화 (Claude가 직렬 루프로 처리)
- 로그 영속화 (Hammerspoon 콘솔로 충분)
- 코드 사이닝/배포 파이프라인

## 3. 사전 조사 결과 (Why Hammerspoon, Why not Plugin)

조사 시점: 2026-06-04, Figma Community + 공식 Plugin API 문서 + Figma Forum 기능 요청.

| 시도 | 결과 |
|---|---|
| Figma Plugin API에서 "Remove background" 호출 | ❌ 노출 안 됨. Community의 모든 BG 제거 플러그인(remove.bg, Removal.AI, ImgGen AI, Photoroom)이 외부 API 사용 |
| Figma Plugin iframe에서 단축키 시뮬레이션 | ❌ 샌드박스 iframe, 부모 Figma 창 이벤트 접근 불가 (Figma Forum에 기능 요청 미해결 상태) |
| macOS 시스템 레벨 자동화 | ✅ Hammerspoon/macOS Shortcuts/AppleScript로 Figma 메뉴 트리거 가능 |

→ **"Figma 플러그인"이 아니라 "macOS 자동화 데몬"이 유일한 실현 경로**.

## 4. 아키텍처

```
┌──────────────────┐                                 ┌─────────────────────┐
│ Claude           │  ① figma.currentPage.selection  │ Figma 데스크톱       │
│ (use_figma MCP)  │ ────────────────────────────▶  │ (활성 화면)          │
└──────────────────┘                                 └─────────────────────┘
        │                                                       ▲
        │ ② POST /v1/remove-bg                                 │
        │    body: { timeout_ms?: 5000 }                       │ ④ 키 시뮬레이션
        ▼                                                       │   Esc → Cmd+/
┌─────────────────────────────────────────┐                    │   → "remove
│ Hammerspoon 데몬                          │ ③ activate Figma │      background"
│ (~/.hammerspoon/init.lua)                │ ─────────────────▶│   → Enter
│ HTTP 서버 127.0.0.1:39632                │                    │
│ hs.httpserver + hs.eventtap              │                    │
└─────────────────────────────────────────┘                    │
        │                                                       │
        │ ⑤ hs.timer.usleep(timeout_ms × 1000)                 │
        │ ⑥ 200 { "ok": true, "elapsed_ms": 5012 }             │
        ▼                                                       │
┌──────────────────┐                                            │
│ Claude           │  ⑦ exportAsync(PNG) → alpha 검증 ─────────┘
│ (검증 단계)       │  ⑧ 실패 시 1회 재시도 (timeout 1.5×)
│                  │  ⑨ 그래도 실패 시 사용자에게 fallback
└──────────────────┘
```

## 5. 컴포넌트

### 5.1 Hammerspoon 데몬

**위치**: 이 레포의 `도구/figma-ai-bridge/init.lua` → 설치 시 `~/.hammerspoon/init.lua`로 심볼릭 링크.

**구성** (~60줄 예상):
- HTTP 서버: `hs.httpserver.new(false, false)` on `127.0.0.1:39632`
- 키 시뮬레이션: `hs.eventtap.keyStroke({}, "escape")`, `hs.eventtap.keyStroke({"cmd"}, "/")`, `hs.eventtap.keyStrokes("remove background")`
- Figma 활성화: `hs.application.find("Figma"):activate()` + 200ms 대기
- 라우팅: 단일 콜백에서 path로 분기 (외부 라이브러리 의존성 0)

**엔드포인트**:

| 메서드 | 경로 | 요청 바디 | 정상 응답 |
|---|---|---|---|
| GET | `/v1/health` | - | `{"ok": true, "figma_running": true, "version": "0.1"}` |
| POST | `/v1/remove-bg` | `{"timeout_ms"?: 5000}` | `{"ok": true, "elapsed_ms": 4823}` |
| POST | `/v1/extend-bg` | `{"prompt": "studio backdrop", "timeout_ms"?: 10000}` | `{"ok": true, "elapsed_ms": 8911}` |

**기본 timeout**:
- remove-bg: 5000ms
- extend-bg: 10000ms

**에러 응답** (HTTP 4xx):
- `409 {"ok": false, "error": "figma_not_running"}` — Figma 프로세스 미발견
- `400 {"ok": false, "error": "invalid_body"}` — JSON 파싱 실패 / 필수 필드 누락 (extend-bg의 `prompt`)
- `503 {"ok": false, "error": "accessibility_denied"}` — Accessibility 권한 미부여

### 5.2 저장소 구조

```
도구/figma-ai-bridge/
├── init.lua          # 실제 데몬 코드
├── install.sh        # ~/.hammerspoon/init.lua 심볼릭 링크 + 권한 안내
├── test.sh           # curl 스모크 테스트
└── README.md         # 설치·운영·트러블슈팅
```

### 5.3 Claude 측 통합

**호출 방식**: Claude는 새 MCP 도구를 추가하지 않고, 기존 **Bash 도구로 `curl`을 직접 호출**한다. use_figma 안의 plugin JS는 fetch를 쓰지 않는다 (책임 분리 + use_figma의 권한 모델 변경 없음).

**오케스트레이션 흐름** (Claude가 순차 실행):
1. `use_figma` — 대상 노드를 `figma.currentPage.selection`에 설정 + 페이지를 frontmost로 이동
2. `Bash` — `curl -sS -X POST http://127.0.0.1:39632/v1/remove-bg -d '{"timeout_ms":5000}' -H 'Content-Type: application/json'`
3. `use_figma` — `exportAsync(PNG)` → 응답 PNG의 alpha 채널 확인
4. alpha 없음 → 2를 timeout 1.5배로 재시도 1회
5. 그래도 실패 → 사용자에게 수동 요청 (현 워크플로우 회귀)

**CLAUDE.md 업데이트** (같은 PR로 묶음):
- 「로고·누끼 이미지 처리」: "에디터 전용이라 자동화 불가" → "기본은 자동화(데몬 사용), 데몬 미설치/실패 시 수동"
- 「⚠️ 누끼 가공은 블록(blocking) 단계」: "자동화 데몬 동작 시 unblock, fallback 경로 명시"
- 「Figma 작업 규칙」 끝에 새 섹션 추가: `figma-ai-bridge` 사전 점검 (워크플로우 시작 시 `curl /v1/health` 1회, 결과에 따라 자동 분기)

**시안 Step 6 자동화 분기** (위 흐름이 기본, fallback은 현 워크플로우 그대로):
1. 누끼 업로드 + alpha 채널 확인
2. alpha 없음 → `curl /v1/health` 200 + `figma_running: true`?
3. 예 → 위 오케스트레이션 흐름 실행
4. 아니오 또는 실패 → 사용자에게 수동 요청 ([[1-2. 시안]] 기존 워크플로우 그대로)
5. 완료 후 swp/scl 셀 빌드 계속

## 6. 워크플로우 비교

**현재 (수동 신호)**:
```
업로드 → alpha 확인 → 사용자 요청 → 사용자 작업(분 단위) → 「완료」 신호 대기 → 빌드 재개
```

**자동화 적용 후**:
```
업로드 → alpha 확인 → 데몬 POST → AI 처리(초 단위) → 검증 → 빌드 재개
                                  ↓ 실패
                                  → 수동 fallback (현 워크플로우)
```

브랜드당 절감 추정: 누끼 N장이면 사용자 컨텍스트 스위치 N회 → 0회.

## 7. 엣지 케이스 및 안전장치

| 위험 | 대응 |
|---|---|
| Quick Actions에 이전 검색어 잔재 | Cmd+/ 직전 Escape 송신 |
| Figma 백그라운드 | `:activate()` + 200ms 대기 |
| AI가 timeout 안에 미완료 | Claude export 검증에서 alpha 부재 감지 → 1회 재시도 (timeout 1.5배) |
| Quick Action 검색어가 Figma 언어 따라 다름 | `init.lua` 상단 상수로 분리 (`REMOVE_BG_QUERY`, `EXTEND_BG_QUERY`) |
| 멀티 디스플레이/멀티 윈도우 | frontmost window 대상 — README에 명시 |
| 누끼가 아닌 노드에 실수로 호출 | Claude 측에서만 분기. 데몬은 "받으면 실행" 단순 정책 유지 |
| Accessibility 권한 미부여 | health 체크에서 `accessibility_denied` 반환, install.sh가 시스템 환경설정 패널 열기 |
| 데몬 미실행 (Hammerspoon 안 띄움) | health 체크 ECONNREFUSED → 자동으로 수동 fallback |

## 8. 검증 계획

**단위 (개발자)**:
- `test.sh` 스크립트로 curl 스모크: `/v1/health`, `/v1/remove-bg`, `/v1/extend-bg` 각 200 응답
- Figma 빈 화면에 누끼 한 장 띄워두고 한 번씩 트리거 → 시각적으로 결과 확인

**통합 (실 워크플로우)**:
- 테스트 브랜드 한 곳 선정, 시안 Step 6를 자동화 모드로 끝까지 수행
- 결과를 현 수동 워크플로우 결과와 비교 (배경 제거 품질, 비율 보존, 셀 정렬)

**회귀 (fallback 보존)**:
- 데몬 중지 상태에서 use_figma 흐름 → ECONNREFUSED → 현 수동 워크플로우로 자연 회귀
- 데몬 정상 + AI timeout 의도적 발생 (네트워크 차단) → 1회 재시도 후 fallback

## 9. 설치·운영

**설치** (one-time):
```
brew install hammerspoon
cd 도구/figma-ai-bridge && ./install.sh
# install.sh 작업:
#   - ~/.hammerspoon/init.lua 심볼릭 링크 생성
#   - Hammerspoon 콘솔 열기 + 권한 부여 안내
#   - System Settings > Privacy > Accessibility에서 Hammerspoon 체크 안내
```

**운영**:
- Hammerspoon 메뉴바 아이콘으로 상태 확인
- `~/.hammerspoon/console.app`에서 로그 확인
- 갱신: `git pull` + Hammerspoon에서 `Reload Config`

## 10. 보안 고려

- 바인드는 `127.0.0.1`만 (외부 노출 안 됨)
- 인증 없음 (로컬에서만 호출되므로 OK; 만약 v0.2에 토큰 추가 가능)
- 키 시뮬레이션은 Accessibility 권한 필요 → 사용자 명시적 허용 후에만 동작

## 11. 향후 확장 (참고용, 이번 스코프 아님)

- v0.2: 토큰 인증 (`Authorization: Bearer ...`)
- v0.3: Figma Quick Action 명령어 다국어 자동 감지
- v0.4: 다중 노드 큐 (POST `/v1/batch` → 데몬 내 직렬 처리)
- v0.5: Figma AI 외 다른 메뉴 액션 일반화 (Quick Action 임의 실행 엔드포인트)

## 12. 결정 로그

| 결정 | 대안 | 채택 이유 |
|---|---|---|
| macOS 자동화 데몬 (Figma 플러그인 아님) | Plugin + 외부 BG API | CLAUDE.md "Figma AI만 사용" 정책 유지 |
| Hammerspoon (Lua) | macOS Shortcuts / Swift+launchd | HTTP 서버 + Accessibility 내장, 50줄로 끝, 디버깅 용이 |
| HTTP 트리거 (localhost 39632) | 파일 시그널 / URL scheme | 비동기 완료 통보가 깔끔, 언어 무관 |
| 노드 선택은 use_figma 담당, 데몬은 AI 트리거만 | 데몬이 노드 ID 받아 선택까지 | 책임 분리, 데몬 단순화, Plugin API와 중복 안 함 |
| 두 기능 (Remove BG + Extend) 동시 지원 | Remove BG MVP 우선 | 사용자 요청. 명령 구조 거의 동일해 비용 적음 |
| 이 레포에 보관 | 별도 레포 / `~/.hammerspoon/` 직접 | 브랜드 워크플로우와 한 곳에서 버전 관리, 설치는 심볼릭 링크로 분리 |

---

## 13. Post-Mortem — 왜 중단했나 (2026-06-04 추가)

### 진행 경과

1. 스펙 승인 → Hammerspoon 데몬 MVP 구현 (`도구/figma-ai-bridge/init.lua`, ~190줄)
2. Hammerspoon 1.1.1 설치, Accessibility + Input Monitoring 권한 부여
3. `localhost:39632/v1/health` 정상 응답 (`figma_running: true, accessibility_granted: true`)
4. 마쥬 SS26 05번 누끼 1장(`Maje_MFPRO04658-10_F_P.jpg`)으로 통합 테스트 시도 6회

### 실패 패턴 (재현)

매 시도마다 동일한 증상:
- 데몬 HTTP는 200 응답, `elapsed_ms` 정상
- `selectMenuItem({"Figma", "Actions…"})`는 성공 — Quick Actions 패널이 실제로 열림 (사용자 시각 확인)
- 그러나 패널 열린 직후 `keyStrokes("remove background")`가 검색창에 도달하지 못함
- 사용자 선택은 매번 해제됨 (R 키로 Rectangle Tool 활성화 → 캔버스에 도형 생성)
- Figma의 노드 `fills`에 변화 없음 (Remove BG 미적용 확정)

### 진단 경로 (시도 → 결과)

| 시도 | 결과 |
|---|---|
| `hs.eventtap.keyStroke({"cmd"}, "/")` | Cmd+/ 가 Figma에 도달은 했으나 Quick Actions 안 뜸 |
| Escape 키 제거 | 선택 해제 1회 줄었지만 여전히 실패 |
| 한국어 IME → ABC 강제 전환 (`hs.keycodes.setLayout("ABC")`) | 로그 확인됨, 그러나 결과 변화 없음 |
| AppleScript `tell process "Figma" / keystroke "/" using command down` | 오류 없음, 결과 변화 없음 |
| `selectMenuItem({"Figma", "Actions…"})` + `keyStrokes(...)` | 메뉴는 열림, 타이핑은 캔버스로 |
| 대기 시간 500ms → 1200ms로 증가 | 결과 변화 없음 |

### 진짜 원인

**macOS 키스트로크 자동화는 타겟 앱이 frontmost일 때만 동작.** Hammerspoon `hs.eventtap`도, AppleScript System Events `keystroke`도 동일. 이건 macOS 보안 모델 자체의 설계.

본 스펙의 핵심 가정 — "Claude가 백그라운드에서 데몬 호출 → 데몬이 Figma에 키스트로크 → AI 실행" — 이 macOS 차원에서 성립 불가. 데몬이 Figma를 `activate()`해도 키스트로크가 발사되는 그 순간 다른 앱(Cursor/Hammerspoon Console/Terminal 등)이 frontmost이면 키는 거기로 감.

### 사용자 결정 (그리고 그 정당성)

사용자 인용:

> "피그마 창을 항상 최상단에 두고 다른 곳에 포커스도 하면 안되면 내가 너한테 자동화를 맡기는 이유가 없어. 너가 업무를 처리하는 동안 난 다른 동작을 해야해."

자동화의 본질은 사용자 컨텍스트 스위치를 없애는 것. 키스트로크 방식은 작업 시간 동안 사용자가 Figma 외 모든 입력을 멈춰야 하므로 본질 위반.

### 검토한 우회 경로 (모두 기각)

| 경로 | 기각 사유 |
|---|---|
| 외부 AI API (remove.bg / Replicate BiRefNet) | CLAUDE.md "Figma AI만 사용" 정책 위반. 사용자가 정책 완화 거부. |
| Hammerspoon `hs.axuielement`로 Figma 검색창 AX 경로 직접 set | R&D 1~2시간 + Figma의 AX 노출도 미지수. ROI 낮음. |
| 현 수동 워크플로우 유지 | ✅ 채택. 누끼 가공만 수동, 그 외는 use_figma로 이미 자동화됨. |

### 부수 산출물

- **Figma Remove BG의 출력 형식 발견** (스펙 외 가치): Remove BG는 `imageHash`를 바꾸지 않고 **두 번째 `IMAGE` fill 레이어를 추가**한다 (원본은 `visible: false`로 숨김, 새 fill은 새 imageHash + `visible: true`). 향후 fills 기반 검증 코드를 쓸 때 참고.
- **Figma Quick Actions 메뉴 경로**: `Main Menu → Figma → "Actions…"` (U+2026 ellipsis 포함). `selectMenuItem`으로 백그라운드 호출 가능.

### 향후 재개 조건 (참고)

본 스펙을 다시 살려 구현할 가치가 생기는 시나리오:
1. Figma가 Plugin API에 AI 기능 노출 (현재 미노출)
2. CLAUDE.md "Figma AI만 사용" 정책 완화 결정 → 외부 API 채택
3. macOS UI 자동화 권한 모델이 백그라운드 키스트로크 허용으로 변경 (가능성 낮음)
4. `hs.axuielement` R&D 결과 Figma Quick Actions 검색창이 AX로 set value 가능함 확인

### 산출물 처리 (2026-06-04 확정)

- `도구/figma-ai-bridge/` (init.lua, install.sh, test.sh, README.md): **삭제됨**. `도구/` 폴더가 비어 함께 제거.
- 본 스펙 문서: **유지** (의사결정 기록, 향후 재개 시 진단 자료).
- `/Applications/Hammerspoon.app`: **유지** (사용자 결정 — 추후 macOS 자동화 용도).
- `~/.hammerspoon/init.lua` 심볼릭 링크: **제거됨**.
- `~/.hammerspoon/Spoons/`: 유지 (Hammerspoon 기본 구조).
- Figma 파일 `SI36czRu3lBgkPzyrnPYkB`의 테스트 노드(`16471:330`, `16472:330`, `16500:330`): 모두 정리 확인.
