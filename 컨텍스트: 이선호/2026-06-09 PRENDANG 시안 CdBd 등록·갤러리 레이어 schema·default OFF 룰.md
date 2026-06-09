# 세션 컨텍스트 — 2026-06-09 PRENDANG 시안 CdBd 등록·갤러리/레이어 schema·default OFF 룰

> 이 문서는 새 대화에서 작업을 바로 이어갈 수 있도록 작성된 컨텍스트 파일이다.
> 이전 세션: [[2026-06-05 TISSOT CdBd 등록·자동화 인증·디자인보드 매핑 규칙]] · [[2026-06-05 마쥬 swp 셀 구조·행 단위 라인 수·로고 alpha 크롭]]

---

## 작업 파일

- **수정 문서:**
  - `룩북/1. 제작 프로세스/1-4. CdBd 콘텐츠.md` *(갤러리 카드 JSON schema 정착 + `block.layers[]` schema·Figma↔CdBd % 환산 공식 + `/api/update-url-key` 4-call publish 시퀀스 + 「editor_published 동기화 = SSR 활성화 필수」 + 인디케이터 default OFF + `is_menu` default OFF + publish body는 `is_menu: false` 명시 필수)*
  - `룩북/2. 디자인 가이드/2-4. 화보·상품.md` *(`03-look-gallery` 인디케이터 prose 정정 — 이전 default ON 가정 → default OFF + 디자인 모형에 마커 명시된 경우에만 ON)*
  - `CLAUDE.md` *(작업 원칙 2개 신설: ⚠️ 갤러리 인디케이터 default OFF · ⚠️ 문서 설정 「페이지 상단 메뉴」(`is_menu`) default OFF)*
- **신규 문서:**
  - `컨텍스트: 이선호/2026-06-09 PRENDANG 시안 CdBd 등록·갤러리 레이어 schema·default OFF 룰.md` *(본 문서)*
- **병합·삭제 문서:**
  - `0. 세션 컨텍스트/2026-06-04 CdBd 자동화 + 티쏘 매장정보 mg3 등록.md` → `컨텍스트: 이선호/2026-06-04 화보 결정 트리·마쥬 12프레임 + TISSOT mg3 자동화.md` 로 **병합 후 원본 삭제** (별도 트랙이었던 마쥬 / TISSOT 작업을 같은 날짜 문서 하나로 합침)
- **CdBd 작업:**
  - editor `4739` (PRENDANG 시안)
  - editor_published id `fb40c4b9-23e3-4409-aae2-35915c1b2595`
  - editor_published_metadata id `4489`
  - URL slug `prendang_2606` → https://cdbd.in/2account/prendang_2606
  - save_editor_version 최종 `v1024`
- **Figma 작업:** `SI36czRu3lBgkPzyrnPYkB` / `16733:330` (PRENDANG 시안 영역 — 어제까지 16733:330 시안 빌드 종결 상태에서 CdBd 등록 시작)
- **임시 자동화 스크립트** (`/tmp/` — 비영구):
  - `prendang_export.py` *(Figma REST API 3배 PNG export — 15 자산)*
  - `cdbd_storage_upload.py` *(Supabase Storage 업로드 + 30년 signed URL)*
  - `cdbd_pages_build_v2.py` *(8 pages 빌드, gallery_block default navigation=False)*
  - `cdbd_b03_layer.py` *(B03 갤러리 카드에 텍스트 레이어 PATCH)*
  - `prendang_asset_urls.json` *(15 자산 → signed URL 매핑)*

---

## 오늘 완료한 작업 (2026-06-09)

### A. PRENDANG 시안 CdBd 등록 (editor 4739) ✅

Figma 16733:330 (`PRENDANG` 시안) → CdBd 멀티페이지 등록. 최종 8 페이지 구성:

| # | order | 페이지 | 카드 구성 |
|---|---|---|---|
| 1 | 0 | A 표지 | image (A.jpg) |
| 2 | 1 | A01 | image (A01.jpg) |
| 3 | 2 | A02 | image (A02.jpg) |
| 4 | 3 | **A03** (분해) | 로고(38%, top:33/bottom:24) + 갤러리(swipe 89.47%, swp1+swp2) + 텍스트(OUTER bold + PA4FC03-0MS opacity 0.55) |
| 5 | 4 | B 표지 | image (B.jpg) |
| 6 | 5 | B01 | image (B01.jpg) |
| 7 | 6 | B02 | image (B02.jpg) |
| 8 | 7 | **B03** | 갤러리(swipe 100% 풀블리드) + **block.layers[]** 텍스트 레이어 (size 19%, position {5,3}) |

기타 설정:
- title `PRENDANG` / OG description `26 WINTER PRE-ORDER` (대문자 — Figma 시각 결과 그대로)
- theme.scrollAnimation `"none"` (default `fade-up` 변경)
- multipage_metadata.pageSize `{380, 580}`, is_page_turn_guide `true`
- **is_menu `false`** (2026-06-09 신규 룰)

### B. 갤러리 카드 JSON schema 검증·1-4 문서 정착 ✅

editor `4637`/`3467`에서 사용자가 직접 만든 갤러리 카드 reverse-engineering. 핵심 구조:

```jsonc
{
  "type": "gallery",
  "title": "갤러리",
  "style": { "padding": "0px", "margin": "0px", ... },
  "gallery": {
    "type": "swipe",          // "swipe" / "list" / "grid"
    "images": [{ "id": "uuid", "url": "signed_url" }, ...],
    "imageOption": { "style": { "aspectRatio": "auto", "borderRadius": "0px" } },
    "gridTypeOption":  { "column": 3, "rowGap": 16, "columnGap": 16 },
    "listTypeOption":  { "rowGap": 16 },
    "swipeTypeOption": { "autoPlay": false, "navigation": false, "infiniteLoop": false, "verticalSwipe": false }
  }
}
```

특이점:
- 유형 변경(swipe/list/grid) 시 셋 다 항상 저장됨 (UI default 유지)
- `gallery.images[i]` = `{id, url}` 2 필드만 필수
- 갤러리 카드 내부 여백 = `block.style.padding` (UI 「카드 디자인 → 내부여백」)

→ `[[1-4. CdBd 콘텐츠]]` 「갤러리 카드」 섹션에 schema + 유형별 매핑 캡처 정착.

### C. `block.layers[]` JSON schema 검증·Figma↔CdBd % 환산 공식 ✅

사용자가 UI 「디자인 보드 → 레이어 추가」 메뉴로 B03 갤러리 카드에 layer 1개 manual add → row fetch → schema reverse.

```jsonc
{
  "id": "nanoid_21",            // user-generated id, 유지
  "url": "signed_url",
  "size": 19,                   // single number = width %
  "filename": "B03-text-layer",
  "position": { "x": 5, "y": 3 },   // % (page 380×580 기준)
  "linkButton": null            // 또는 page/url/call/email 객체
}
```

**핵심 발견**:
- `block.layers[]` 는 **block 직속 속성** — 갤러리 카드도 `block.gallery.layers`가 아니라 `block.layers`에 보관
- `size`는 **단일 숫자 = width %** (height는 aspect로 auto)
- `position` 단위 = **% 기준** (절대 px 아님)
- `linkButton` = `null` / `{type:"page", page:{...}}` / `{type:"url", link:{href, openNewTab}}` / `{type:"call", phone:{phone}}` 등

**Figma → CdBd 좌표 환산 공식 (380×580 페이지 기준)**:
- `position.x = (Figma_rect.x / 380) × 100`
- `position.y = (Figma_rect.y / 580) × 100`
- `size = (Figma_rect.width / 380) × 100`

검증 예 (B03 텍스트 영역): Figma `x=20, y=20, w=73, h=30` → `position {x:5, y:3}, size:19` ✓

→ `[[1-4. CdBd 콘텐츠]]` 「레이어 (`block.layers[]`) JSON schema」 섹션 신설.

### D. `/api/update-url-key` 발견 — `extend_published_url_v2` RPC 부재 ✅

처음 PRENDANG URL 등록 시 RPC `extend_published_url_v2` 호출 → **PGRST202 not found** 발생.

조사:
- chunk 5784 grep 결과 schema cache RPC list = `get_editor_by_site_and_url_key`, `get_editor_status_v2`, `pay_individual_urls`, `save_editor_version` **4개뿐**
- `extend_published_url_v2`는 **schema에 없음** — 1-4 문서 이전 표기는 outdated
- 실제 URL 등록은 **Next.js API route `POST https://www.cdbd.in/api/update-url-key`** (server-side RLS 우회)

```http
POST https://www.cdbd.in/api/update-url-key
Authorization: Bearer {access_token}
Body: { "editor_id": 4739, "user_id": "523daa95-...", "url_key": "prendang_2606" }
Response: { "success": true, "isFirstTime": true|false }
```

→ `[[1-4. CdBd 콘텐츠]]` 「URL 생성」 + 「publish 시퀀스」 + 「알려진 한계 / 회피」 일괄 정정.

### E. editor_published 동기화 = SSR 활성화 missing step ✅

PRENDANG 첫 게시 후 URL에 **"게시 중지 혹은 삭제된 페이지입니다"** 표시 (152KB default HTML).

디버깅 결과:
- RPC `get_editor_by_site_and_url_key({"2account","prendang_2606"})` → `success:true` + editor 4739 정확 반환 (anon으로도 동일)
- 모든 row (editor / editor_published / editor_published_metadata / editor_url) 정상 + is_active=true
- TISSOT(작동 중) 4681과 column-by-column 동일

**원인**: editor PATCH 후 editor_published row만 UPSERT돼있고 **editor와 동기화된 pages snapshot이 갱신 안 됨**. SSR이 editor_published 기준으로 렌더 → 미동기화 시 default page.

**해결**:
```python
# editor + editor_published 동시 PATCH
PATCH /rest/v1/editor?id=eq.{eid}              body={pages, updated_at}
PATCH /rest/v1/editor_published?editor_id=eq.{eid}  body={pages, updated_at}
PATCH /rest/v1/editor_published_metadata?editor_id=eq.{eid}  body={is_active:true}  # 재set
POST  /rest/v1/rpc/save_editor_version          body={p_editor_id:{eid}}
```

→ SSR 182KB `<title>PRENDANG</title>` 정상화 확인.
→ `[[1-4. CdBd 콘텐츠]]` 「게시 후 수정 시 — editor_published 동기화 필요」 + 「URL 「중지」 상태 복구 5-call 시퀀스」 정착.

### F. 갤러리 카드 인디케이터 default OFF — 영구 규칙 ✅

사용자 명시: **"사용자 요청이 없다면 인디케이터는 디폴트로 꺼줘. 꼭 기억해줘"**

- `[[CLAUDE.md]]` 작업 원칙에 **「⚠️ CdBd 갤러리 카드 인디케이터(navigation) = 기본 OFF」** 신설
- `[[1-4. CdBd 콘텐츠]]` 갤러리 카드 schema + 페이지 유형별 카드 매핑 표 + 시행착오 룰 표 일괄 정정 (모든 매핑 row 「내비게이션=OFF (요청 시에만 ON)」)
- `[[2-4. 화보·상품]]` 「03-look-gallery」 prose 정정 (이전 default ON 가정 → default OFF + 디자인 모형에 마커 명시 시에만 ON)

자동화 적용: `gallery_block(navigation=False)` default (사용자 명시 시에만 True).

### G. 페이지 상단 메뉴 (`is_menu`) default OFF — 영구 규칙 ✅

사용자 명시: **"문서 설정에서 페이지 상단 메뉴도 항상 디폴트로 꺼줘"**

`editor_published.is_menu` = 페이지 구독·저장·공유 아이콘 노출 토글. cdbd.in UI 「URL 정보 편집 → 페이지 상단 메뉴」와 1:1 대응 (chunk 5784).

- `[[CLAUDE.md]]` 작업 원칙에 **「⚠️ CdBd 문서 설정 「페이지 상단 메뉴」 = 기본 OFF」** 신설
- `[[1-4. CdBd 콘텐츠]]` 3곳 정정:
  - URL 정보 편집 표: `ON (기본)` → **`OFF (기본)` — 요청 시에만 ON**
  - 6단계 워크플로우 체크리스트: 동일 정정
  - publish 시퀀스 UPSERT body: `(+ 선택 is_menu)` → **`is_menu: false` 반드시 명시** (신규 row 기본 `true`)
- 현재 PRENDANG에도 적용: `true` → `false` PATCH + save_editor_version v1024

### H. A03/B03 페이지 통합 — 별도 페이지 → 갤러리 카드 1장 ✅

초기 구성 (10 pages): A03·B03 각각 swp1·swp2 별도 페이지로 등록.

사용자 피드백: **"A03, B03의 스와이핑 화보가 갤러리 카드로 들어가지 않고 별도의 페이지로 들어가있어. … '이미지' 카드가 아니라 '갤러리' 카드를 사용해줘"**

→ 8 pages로 통합 (A03/B03 각각 갤러리 카드 1장).

Figma 정확 측정값 반영 (16733:412/421/425):

| 요소 | Figma 측정 | CdBd 적용 |
|---|---|---|
| A03 로고 | 144×17, y=33 | width **38%**, margin **`33px 0px 24px`** (top·bottom·LR auto) |
| A03 inner clip | 340×440, x=20, y=74 | margin **`0px 20px`** (LR 20px, 89.47% 효과) |
| A03 텍스트 | fontSize 13px, lineHeight 1.6, OUTER bold + PA4FC03-0MS opacity 0.55 | lexical AST format=1(bold) + style `font-size:13px;line-height:1.6` + 품번 segment `rgba(20,20,20,0.55)` |
| B03 갤러리 | 380×580 풀블리드 | margin **`0px`** (full-bleed) |
| B03 텍스트 레이어 | 73×30 at (20,20), 페이지 380×580 | block.layers[]: **size 19, position {x:5, y:3}** |

### I. B03 swp1 교체 (정보 합본 → 정보 없는 첫 컷) ✅

사용자 피드백: **"내가 B03의 상품 텍스트는 갤러리 카드의 레이어로 얹어달라고 했는데, 지금은 갤러리 이미지 첫장에 텍스트가 포함돼서 내보내기 됐어"** → "디자인보드의 레이어추가 메뉴를 사용해달라는 말이었어"

- gallery.images[0] url: `B03.jpg`(텍스트 포함 합본) → `B03-swp1.jpg`(텍스트 없는 풀화보)
- 텍스트는 block.layers[]로 분리 (위 H 마지막 행 참고)

### J. OG description 대문자 ✅

editor_published_metadata.description: `"26 Winter Pre-Order"` → **`"26 WINTER PRE-ORDER"`** (Figma 시각 결과 그대로 — CLAUDE.md 「Figma 시각 결과 → 카드 데이터 변환」 룰 적용).

### K. 2026-06-04 문서 병합 (마쥬 + TISSOT 트랙 통합) ✅

별도 트랙으로 진행되던 같은 날짜의 두 작업을 하나의 컨텍스트로 합침.

- 원본: `0. 세션 컨텍스트/2026-06-04 CdBd 자동화 + 티쏘 매장정보 mg3 등록.md` (TISSOT mg3 트랙)
- 대상: `컨텍스트: 이선호/2026-06-04 화보 결정 트리·마쥬 12프레임 배치.md` (화보·마쥬 트랙)
- 결과: `컨텍스트: 이선호/2026-06-04 화보 결정 트리·마쥬 12프레임 + TISSOT mg3 자동화.md` (병합본)
- 원본 삭제 + 이를 참조하던 wikilink 3개 (`2026-06-05 TISSOT…` × 2, `2026-06-05 마쥬 swp…` × 1) 새 파일명으로 일괄 갱신

병합 시 이전 표기 `extend_published_url_v2` RPC는 「2026-06-09 정정 — `/api/update-url-key`」 주석 추가.

---

## 현재 PRENDANG CdBd 상태

| 항목 | 값 |
|---|---|
| editor.id | `4739` |
| editor_published.id | `fb40c4b9-23e3-4409-aae2-35915c1b2595` |
| editor_published_metadata.id | `4489` |
| editor_url.url_key | `prendang_2606` |
| title | `PRENDANG` |
| description | `26 WINTER PRE-ORDER` |
| pages | 8 (A 표지·A01·A02·A03·B 표지·B01·B02·B03) |
| theme.scrollAnimation | `none` |
| **is_menu** | **`false`** ← 2026-06-09 적용 |
| **is_active** | `true` |
| save_editor_version | `v1024` |
| live URL | https://cdbd.in/2account/prendang_2606 |
| editor URL (작업용) | https://www.cdbd.in/editor/4739 |

---

## 핵심 설계 결정사항

- **갤러리 카드 인디케이터 default OFF**: 룩북 화보 스와이핑은 인디케이터 없는 깔끔한 노출이 기본. 사용자 명시 요청 시에만 ON. PPT 의뢰서의 디자인 모형에 점/숫자 인디케이터가 없으면 거의 모든 케이스에서 off.
- **페이지 상단 메뉴 (`is_menu`) default OFF**: 룩북 시안·초안 공유 시 상단 UI는 콘텐츠 몰입을 방해 — 기본 비노출이 자연. **자동화는 `editor_published` UPSERT body에 `is_menu: false` 명시 필수** (신규 row 기본값이 `true`라 명시 없으면 켜진 채 생성).
- **`block.layers[]` 좌표는 % 기준** (page 380×580): `position {x,y} = (Figma_rect.{x,y} / page_dim) × 100`, `size = (Figma_rect.width / 380) × 100` (single number = width %). 절대 px 단위 아님.
- **`block.layers[]` 는 block 직속 속성** — 갤러리 카드여도 `gallery.layers`가 아니라 `block.layers`에 보관. 이미지 카드와 동일한 schema.
- **editor_published 동기화 = SSR 활성화 필수 단계** — editor PATCH만으로 게시 URL 반영 안 됨. editor_published.pages도 같이 PATCH (또는 UPSERT) + metadata.is_active=true 재set. 첫 게시 후 URL "중지" 상태 = 거의 항상 동기화 누락.
- **`/api/update-url-key`가 정답** (NOT `extend_published_url_v2` RPC): Next.js API route가 service-side RLS 우회. 슬러그 INSERT/UPDATE 전용. 1-4 문서 이전 표기는 outdated.
- **PRENDANG B03 패턴 = 갤러리 + 텍스트 레이어 분해**: 정보 합본 이미지(JPG에 텍스트 포함)는 안티패턴 — 갤러리 첫 컷은 정보 없는 풀화보, 텍스트는 `block.layers[]`로 별도 분리.
- **A03 패턴 = 3 카드 분해**: 로고(이미지) + 갤러리(swipe) + 텍스트(품번 lexical) — Figma 시안의 시각 구조를 카드 단위로 매핑. B03 패턴(레이어 추가)과 비교해 시안 디자인이 더 정형적일 때 적합.

---

## 갤러리 카드 + 레이어 schema 빠른 참조

```python
# 갤러리 (swipe) 카드 — 룩북 default
gallery_block(image_urls, *, margin='0px', padding='0px', navigation=False, infinite=False)
# →
{
  "type": "gallery",
  "style": {"padding": padding, "margin": margin, ...},
  "gallery": {
    "type": "swipe",
    "images": [{"id": uuid, "url": u} for u in image_urls],
    "swipeTypeOption": {"autoPlay": False, "navigation": navigation, "infiniteLoop": infinite, "verticalSwipe": False},
  },
}

# block.layers[] 한 항목
{
  "id": "nanoid_21",
  "url": signed_url,
  "size": int((figma_w / 380) * 100),                 # width %
  "filename": "label",
  "position": {
    "x": int((figma_x / 380) * 100),                  # %
    "y": int((figma_y / 580) * 100),                  # %
  },
  "linkButton": None | {"type": "...", ...}
}
```

---

## CdBd publish 시퀀스 (4-call 정착)

```python
# 1. editor row 이미 갱신 후
PATCH /rest/v1/editor?id=eq.{eid}                body={pages, theme, ...}

# 2. editor_published 동기화 UPSERT (snapshot)
POST  /rest/v1/editor_published?on_conflict=editor_id&select=*
      headers={"Prefer": "resolution=merge-duplicates,return=representation"}
      body={editor_id, pages, theme, multipage_metadata, title, type:"multi",
            user_id, updated_at, is_menu: False}  # ⚠️ is_menu 반드시 명시

# 3. is_active=true 재set (안전장치)
PATCH /rest/v1/editor_published_metadata?editor_id=eq.{eid}
      body={"is_active": True}

# 4. URL 등록 (Next.js API route — RLS 우회)
POST  https://www.cdbd.in/api/update-url-key
      headers={"Authorization": f"Bearer {access_token}"}
      body={editor_id, user_id, url_key}  # url_key = `{brand}_{YYMM}` 시안 / `[문서]` 초안

# 5. version 저장
POST  /rest/v1/rpc/save_editor_version           body={"p_editor_id": eid}
```

---

## 미완료 / 향후 확인 필요

- [ ] 사용자가 https://cdbd.in/2account/prendang_2606 최종 시각 확인 후 미세 조정 (현재까지 시각 검증 부족)
- [ ] A03 페이지에도 같은 layer 패턴 적용 검토 (현재는 3카드 분해, B03만 갤러리+layer) — 디자인 통일성 측면에서 사용자 결정 필요
- [ ] block.layers[]의 `linkButton.type` 4종 (page / url / call / email) 모두 schema 실측 검증 (현재는 `null` + 이전 TISSOT 셀별 `tel:` 패턴만 확인)
- [ ] 다른 브랜드 시안 등록 시 4-call publish 시퀀스 + default OFF 룰 자동 적용 회귀 검증

---

## 다음 세션에서 이어할 수 있는 작업

- **새 브랜드 시안·초안 CdBd 등록**: 본 세션의 4-call publish 시퀀스 그대로 재사용 + `is_menu: False` / `navigation: False` default 자동 적용. 슬러그는 시안=`{brand}_{YYMM}` / 초안=`[문서]` 확인.
- **갤러리 카드 + block.layers[] 자동 배치**: Figma 측정 → % 변환 공식 (`position` + `size`)으로 layer 자동 추가. 마커·버튼·로고·텍스트 레이어 통합 처리.
- **A03 페이지 일관성**: 사용자 결정에 따라 A03도 B03 패턴(갤러리 + layer)으로 통일하거나, 현재 3 카드 분해 유지.
- **블록 schema 보강**: `linkButton` 4종 타입 실측 검증 + `block.layers[]` 다중 레이어 z-order(`renderOrder`?) 확인.

---

## Supabase 인프라 (변동 없음 — 2026-06-05와 동일)

| 항목 | 값 |
|---|---|
| URL | `https://jzwrixxevnfogfjzgaqz.supabase.co` |
| User ID (account@emka.group) | `523daa95-b43d-4a13-9919-e5ce7c097e06` |
| 인증 헬퍼 | `~/.config/cdbd/auth.py` `get_credentials()` (figma_pat + access_token + supabase_url + anon) |
| credentials.json | `~/.config/cdbd/credentials.json` (chmod 600, refresh_token 자동 rotation) |

---

## Figma 노드 ID (PRENDANG 16733:330)

| 노드 | ID | 비고 |
|---|---|---|
| PRENDANG 시안 root | `16733:330` | 8 LOOK 시안 (A·B 2안 × 4페이지) |
| A03 분해 영역 | `16733:412` (로고) · `16733:421` (inner clip) · `16733:425` (텍스트) | Figma 측정값 = % 환산 기준 |
| B03 | `16733:428` | 갤러리 카드 + block.layers[] 텍스트 레이어 |
| 정보 영역 (B03) | Frame `48097371` | x=20, y=20, w=73, h=30 (layer 좌표 source) |

---

## Figma MCP 기술 메모 (오늘 추가)

16. **`block.layers[]`는 schema가 사용자 manual add로만 안정 확인**: shotgun 금지 — 가능 후보 키들(`layer.scale`/`layer.width`/`layer.x`/`layer.y` 등) 시도 대신 cdbd.in UI 「레이어 추가」로 1개 만들어 row fetch → 정확한 key·type 확인 후 자동화.
17. **`size` 단일 숫자가 width %**: ratio·height는 source 이미지 aspect로 auto. position·size 모두 % (page 380×580 기준), 절대 px 단위 없음.
18. **Figma → CdBd 좌표 환산 = 페이지 차원 분모**: page width 380, page height 580. 환산 후 `int()` 반올림 충분 (사용자 입력 단위도 정수 % 슬라이더).
19. **`linkButton: null` 명시**: omit 시 일부 viewer 클릭 처리 어긋남 → 외부 링크 없으면 명시적 `null` 권장.

---

## 변경 이력 (2026-06-09)

| 시점 | 내용 |
|---|---|
| 2026-06-09 오전 | PRENDANG 시안 16733:330 → CdBd editor 4739 등록 (10 pages 초기). |
| 2026-06-09 오후 | A03·B03 갤러리 카드로 통합 (8 pages) + Figma 정확 측정값(logo 38%, inner 89.47%, text 13px / opacity 0.55) 반영 + scrollAnimation `none`. |
| 2026-06-09 오후 | `/api/update-url-key` 발견 → 1-4 문서 「extend_published_url_v2」 표기 정정. editor_published 동기화 단계 = SSR 활성화 missing step 발견 → URL 「중지」 → 정상화. |
| 2026-06-09 저녁 | OG description 대문자 변경. 갤러리 인디케이터 default OFF 영구 규칙 신설. B03 swp1 교체(정보 합본 → 정보 없는 풀화보) + 텍스트는 block.layers[]로 분리. block.layers[] schema 정착 + Figma↔CdBd % 환산 공식 1-4 문서 정착. |
| 2026-06-09 저녁 | 페이지 상단 메뉴(`is_menu`) default OFF 영구 규칙 신설. PRENDANG은 true→false 적용 (v1024). 2-4 「03-look-gallery」 prose 정정 (인디케이터 default 변경 후속). |
| 2026-06-09 마감 | 2026-06-04 문서 병합 (마쥬 + TISSOT 트랙 통합). 본 세션 컨텍스트 신규 작성. |
