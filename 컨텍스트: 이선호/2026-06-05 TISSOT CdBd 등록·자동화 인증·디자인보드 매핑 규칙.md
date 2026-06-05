# 세션 컨텍스트 — 2026-06-05 TISSOT CdBd 등록·자동화 인증·디자인보드 매핑 규칙

> 이 문서는 새 대화에서 작업을 바로 이어갈 수 있도록 작성된 컨텍스트 파일이다.
> 이전 세션: [[2026-06-04 화보 결정 트리·마쥬 12프레임 배치]]

---

## 작업 파일

- **수정 문서:**
  - `CLAUDE.md` *(CdBd 자동화 관련 규칙 4개 신규 + 1개 정정)*
  - `룩북/1. 제작 프로세스/1-2. 시안.md` *(불필요한 「변경 이력」 섹션 삭제)*
  - `룩북/1. 제작 프로세스/1-3. 초안.md` *(불필요한 「변경 이력」 섹션 삭제)*
  - `룩북/1. 제작 프로세스/1-4. CdBd 콘텐츠.md` *(1-5 자동화 내용 병합, 「6.5 최종 검증 체크리스트」 신설, 「최상위 원칙: 디자인 보드 메뉴 1:1 매핑 키만 사용」 등 다수 갱신)*
- **삭제 문서:** `룩북/1. 제작 프로세스/1-5. CdBd 자동화.md` *(1-4에 병합)*
- **신규 파일 (vault 외):**
  - `~/.config/cdbd/credentials.json` *(figma_pat + supabase_refresh_token + cached_access_token, chmod 600)*
  - `~/.config/cdbd/auth.py` *(`get_credentials()` 헬퍼 — 캐싱 + pbpaste fallback, chmod 700)*
  - `~/.config/cdbd/bookmarklet.js` *(브라우저 책갈피용 token 클립보드 복사 스니펫)*
- **CdBd 작업:** editor `4681` (TISSOT 매장 정보, slug `tissot_2606`, URL https://cdbd.in/2account/tissot_2606)
- **Figma 작업:** `SI36czRu3lBgkPzyrnPYkB` / `16575:330` (TISSOT store-* 페이지)

---

## 오늘 완료한 작업 (2026-06-05)

### A. 문서 정리 ✅

- `1-2. 시안.md` · `1-3. 초안.md` 끝에 있던 「변경 이력」 섹션 삭제 (의미 없는 메타데이터)
- `1-5. CdBd 자동화.md`의 내용을 `1-4. CdBd 콘텐츠.md`로 통합 후 `1-5` 파일 삭제 → CdBd 문서가 「콘텐츠 매핑 + 자동화」 하나로 단일화

### B. TISSOT 매장 정보 CdBd 등록 (editor 4681) ✅

Figma `16575:330` (`store-scl-grid` + `store-multi-grid-1·2·3`) → CdBd 멀티페이지 등록.

**최종 구성 (4 pages)**:

| # | 페이지 | 블록 | 비고 |
|---|---|---|---|
| 1 | scl-grid (38셀 스크롤) | 40b | text(제목) + 19 multiCard + 18 divider + button + logo |
| 2 | mg-1 (헤더 + 8행) | 16b | image header + 8 multiCard + 7 divider |
| 3 | mg-2 (8행) | 15b | 8 multiCard + 7 divider · 상단 여백 48 |
| 4 | mg-3 (3행) | 7b | 3 multiCard + 2 divider + 공식몰 버튼 + 로고 · 상단 48 / 버튼 간격 20 |

**핵심 파이프라인** (1-4 문서 갱신 반영):
- Figma REST API (PAT) → 3배 PNG export (use_figma exportAsync는 base64 truncation 한계)
- Supabase Storage POST → signed URL → `editor.pages` PATCH → `editor_published.pages` PATCH (둘 다 필요)
- 슬러그 `tissot_2606` (시안 패턴 `{brand}_{YYMM}` — 언더바만)
- 공식몰 버튼 URL = `https://www.tissotwatches.com/ko-kr` (구글 1순위 한국 공식몰)

### C. 자동화 인증 헬퍼 ✅

매번 사용자에게 token 요청하는 마찰을 제거.

**아키텍처** (`~/.config/cdbd/`):
1. **`credentials.json`** — `figma_pat` + `supabase_refresh_token` + `cached_access_token` (chmod 600)
2. **`auth.py`** — `get_credentials()` 함수 (chmod 700)
   - 5분 미만 fresh한 `cached_access_token`이면 재사용 (Supabase refresh_token rotation 충돌 회피)
   - 만료 시 refresh_token으로 새 access_token 발급 + cache 갱신
   - refresh 실패 시 macOS `pbpaste`로 클립보드에서 refresh_token 자동 fetch
3. **`bookmarklet.js`** — 브라우저 책갈피로 cdbd.in 쿠키에서 refresh_token 추출 + 클립보드 복사

**Chrome 148 App-Bound Encryption (ABE)** 가 직접 cookie DB 읽기를 차단하므로 책갈피 + pbpaste 우회.

CLAUDE.md 작업 원칙에 「CdBd 자동화 진입 시 인증 헬퍼 자동 사용」 명시.

### D. 「디자인 보드 메뉴 1:1 매핑 키만 사용」 최상위 원칙 도입 ✅

사용자 요청: 자동화 후에도 디자인 보드 메뉴로 수동 수정 가능해야 함.

**금지 패턴**:
- shotgun (예: `fixed`/`pinned`/`sticky`/`isFixed`/`position`/`fixedPosition` 동시 true)
- 임의 키 추측 (`alignment`/`horizontalAlign`/`alignSelf`/`justifySelf` 등)
- UI 메뉴 우회 데이터 직접 변형 (예: `link.href` 대신 `linkButton`)

**허용**: 1-4 문서 「카드별 디자인 보드 메뉴 → JSON 키 매핑」 표에서 검증된 1:1 키만.
**검증 안 된 키 필요 시**: UI에서 직접 임의 값 입력 → editor GET diff로 키 식별 → 매핑 표 갱신.
**모를 때**: 사용자에게 「UI 어느 메뉴로 변경하나요?」 묻기.

이 원칙을 CLAUDE.md (최상위) + 1-4 「Supabase 직접 자동화」 섹션 최상단에 신설.

### E. shotgun 키 정리 ✅

editor 4681 page[0]·page[3] 로고 카드에 있던 `position: "bottom"` + `fixedPosition: "bottom"` 동시 set 발견 → editor 4348 (ELVE Lab, 사용자가 UI로 직접 작성) 스캔 → 표준 키 = **`fixedPosition` 단일** 확인 → `position` 키 제거 PATCH.

1-4 doc 매핑 표와 「시행착오 → 하단 고정」 섹션도 단일 키로 정정 (shotgun 잔재 박지 말 것).

### F. 페이지별 로고 면적 검증 + 6.5 최종 검증 체크리스트 신설 ✅

**검증 결과 (Figma 측정값 vs CdBd 적용값)**:

| 페이지 | Figma 로고 | 환산 | CdBd 적용 (전) | 후 |
|---|---|---|---|---|
| 01번 scl-grid | footer 68×32 | width 18% | 20% (오류) | **18%** ✓ |
| 02번 mg-1 | 헤더 380×52 | width 100% | 100% ✓ | 100% |
| 03번 mg-2 | 로고 없음 | (없음) | 없음 ✓ | 없음 |
| 04번 mg-3 | footer 68×32 | width 18% | 20% (오류) | **18%** ✓ |

**환산 공식**: `CdBd style.width % = (Figma_frame_width / 380) × 100`

**1-4 문서에 「6.5. 최종 검증 체크리스트」 단계 신설** (게시 전 필수):
- 페이지 수·순서 일치
- 카드 시퀀스 (매핑 표 기준)
- **⚠️ 페이지별 로고/헤더 면적 = Figma 측정값 정확 일치** (환산 공식 + 검증 절차 4단계)
- 누락/잘못 추가된 로고 없음
- 구분선·여백·버튼 height·링크·텍스트 시각 결과 일치
- 에디터 close 상태

작업 흐름 도식에 `S65` 노드 추가, 「자동화 작업 시 체크리스트」에도 항목 반영. CLAUDE.md 작업 원칙에 「CdBd 등록 게시 전 6.5 최종 검증 단계 필수」 명시.

### G. mg-2 스크롤 해결 ✅

**증상**: mg-2 콘텐츠 9 multiCard × 60 + 8 divider × 1 + 16+16 margin = 580 정확 fit인데도 스크롤 발생. cell PNG 측정 438×180 (146:60 비율 정확), divider style·multiCard padding 모두 일관. mg-1·mg-3은 fit. 정확한 원인은 측정으로 잡히지 않음 (subpixel rounding 또는 우리가 모르는 default).

**해결 (사용자 결정)**: mg-2 마지막 multiCard(row 9) + 직전 divider를 mg-3 첫 순서로 이동.
- mg-2: 9행 → 8행 (15 blocks, 콘텐츠 합 535px / 45px 여유)
- mg-3: 2행 → 3행 (7 blocks)

이후 사용자 요청으로:
- mg-2 첫 multiCard 상단 여백 16 → **48**
- mg-3 첫 multiCard 상단 여백 20 → **48**
- mg-3 마지막 multiCard 하단 여백 24 → **20** (공식몰 버튼-리스트 간격)

### H. 페이지 구성 후속 ✅

- **page[1] mg3-A 중복 페이지 삭제** — 사용자가 처음부터 만들어둔 mg-3 모양 페이지가 잔여물로 남아있어 제거 (5 → 4 pages)
- **scl-grid 38셀 페이지 page[0] 1번 위치 복원** — 이전에 만들었다 잠시 삭제했던 페이지를 재추가 (block id는 uuid 새로 발급)
- **scl-grid 제목 대문자 변경** — `"store information"` → `"STORE INFORMATION"` (lexical AST `root.children[0].children[0].text` .upper() — Figma textCase=UPPER 룰 적용)

### I. 기타 룰 추가 (CLAUDE.md) ✅

- **CdBd 자동화 PATCH 전 에디터 close 필수** (race condition 회피 — `save_editor_version` 자동저장이 PATCH 덮어씀)
- **「링크 연결」 = `linkButton` 키 (NOT `link`)** — UI 디자인 보드 표준 schema. 전화 = `{type:"call", phone:{phone:"숫자만"}}`, URL = `{type:"url", link:{href, openNewTab}}`
- **CdBd 텍스트 카드 = Figma 「시각 결과」 입력 (characters 그대로 X)** — textCase=UPPER/LOWER/TITLE 시각 변환 결과를 text에 직접 입력
- **CdBd 버튼 height 조정 = 디자인 보드 「크기 → 세로」 (= `innerStyle.padding` 세로값)** — 공식 `세로 padding = (Figma_height − text_line_height) / 2` (예: Figma 45 / text 13×1.6=20.8 → 12px)

---

## 다음 세션 시작 시

### 진행 상황
- editor 4681 (TISSOT 매장 정보) — 사용자 마지막 검증 대기 (https://cdbd.in/2account/tissot_2606)
- 모든 변경 PATCH 완료 + editor·editor_published 동기 ✓

### 남은 가능성
- mg-2 스크롤 boundary case 정확한 원인 발견 시 1-4 문서에 「알려진 한계」로 추가 (현재는 의존)
- 다른 브랜드 매장 정보 작업 시 새 룰 (디자인보드 1:1 매핑, 6.5 검증, 로고 면적 환산 공식, 버튼 height 공식) 적용 검증
- `multipage_metadata.is_page_turn_guide` 키가 실제로 viewer에서 어떤 영역 차지하는지 확인 필요 (오늘은 추측이었고 사용자가 본 적 없다고 함 — 결국 다른 해결책으로 우회)

### 참고 사항
- TISSOT editor 4681 published ID: `197fc5c6-5404-477b-99ab-52be0d2f3f9e`
- 작업 캐시 파일 `/tmp/cdbd-work/` 보존 (PNG 38셀 × 2 세트 + signed-urls.json + patch-body 등)
- 인증 헬퍼 진입 패턴: `import sys; sys.path.insert(0, '/Users/leesunho/.config/cdbd'); from auth import get_credentials; creds = get_credentials()`

---

## 참조 문서

- [[룩북/1. 제작 프로세스/1-4. CdBd 콘텐츠]] — 매핑 표 + Supabase 직접 자동화 + 6.5 최종 검증
- [[CLAUDE.md]] — 작업 원칙 (CdBd 자동화 관련 규칙들)
- 이전 세션: [[2026-06-04 화보 결정 트리·마쥬 12프레임 배치]]
