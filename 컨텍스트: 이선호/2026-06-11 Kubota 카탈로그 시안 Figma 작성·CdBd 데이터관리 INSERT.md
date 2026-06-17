# 세션 컨텍스트 — 2026-06-11 Kubota 카탈로그 시안 Figma 작성·CdBd 데이터관리 INSERT

> 이 문서는 새 대화에서 작업을 바로 이어갈 수 있도록 작성된 컨텍스트 파일이다.
> 이전 세션: [[2026-06-10 저장 경로 규칙 변경·CdBd 이미지 라이브러리 헬퍼 도입·PRENDANG anti-pattern 진단]]

---

## 작업 파일

- **신규 시안**: Kubota 카탈로그 (kubota.makevu.me) → CdBd 멀티페이지 시안 4P
- **Figma 작업**: `ngFTXXFvX6HI6gLjONSOev` (구보다_2606) — `Pages` 페이지
- **CdBd editor**: id=`4778` `KUBOTA` (계정 `account@emka.group`)
- **참조 룩북 문서**: [[룩북/1. 제작 프로세스/1-4. CdBd 콘텐츠]] (카드 매핑·image_library·linkButton 규칙)
- **자산 원본**: `~/Downloads/B2320.jpg`, `~/Downloads/B2320_top.jpg` (1200×800)

---

## 오늘 완료한 작업 (2026-06-11)

### A. 메이크뷰 → CdBd 카드 매핑 분석 (4페이지 분량)

사용자 요청: `https://kubota.makevu.me/home`, `/home#page=2`, `/tractor/v29f/kkr`, `/tractor/v29f/kkr#page=2` 4페이지를 CdBd로 이식. 룩북 아닌 카탈로그라 카드 종류는 자유.

**페이지 구조 결론**:

| # | 원본 URL | 성격 | 사이즈 | 카드 수 |
|---|---|---|---|---|
| P1 | `/home` | 카테고리 그리드 (랜딩) | 380×580 | 4 |
| P2 | `/home#page=2` | 본사 연락처 | 380×580 | 4 |
| P3 | `/tractor/v29f/kkr` | 트랙터 모델 라인업 | 380×580 | 7 |
| P4 | `/tractor/v29f/kkr#page=2` | B2320 상세 (스크롤) | 380×자유 (≈1700) | 15 |

총 **4P / 30 카드** → base quota 10P 이내라 자동화 publish 가능 ([[룩북/1. 제작 프로세스/1-4. CdBd 콘텐츠]] 「base quota 초과」 규칙 통과).

**핵심 매핑 결정 (사용자 확정)**:
- nav 아이콘: 이미지 카드 + `block.layers[]` 패턴 (basic-link 「+」 gif와 동일 메커니즘)
- P3 10개 모델: B2320만 페이지 이동 링크, 나머지 9개는 `linkButton: null`
- P4 사양 테이블: Figma에서 벡터 재작성 (저해상도 캡처 사용 X)
- P4 카탈로그 다운로드: PDF URL 사용자가 별도 제공

### B. og.jpg Figma 작성 (16002:29)

| 항목 | 값 |
|---|---|
| Figma 노드 | `16002:29` (`OG` — 사용자 리네임) |
| 사이즈 | 800×400 흰 BG |
| 콘텐츠 | Kubota 워드마크(18006:2, 3배 클론) 중앙 단독 (서브텍스트는 사용자 요청으로 제거) |

### C. 헤더 프레임 3종 (사용자 후속 수정 다수)

메이크뷰 헤더 비율 측정: 원본 358×570 / cyan·orange 헤더 358×68 (19%) → **380 환산 380×72**.

**02-header (P2 연락처)** — `18009:2`:
- BG `#009FA8` (cyan) `header-bg` 자식
- 「구보다 대리점」 서브텍스트 + Kubota 워드마크 흰색 (좌 20)
- 「목록」 버튼 (사용자 수정: 40×40 원형, 라운드 99, SemiBold 13)
- 사용자가 `Frame 3` (auto-layout VERTICAL) 그룹화

**03-header (P3 라인업)** — `18011:2`:
- BG `#FFAA00` (orange)
- 02 복제 후 서브텍스트 제거 · 워드마크 수직 중앙
- 우측 **4개 원형 버튼** (38×38, Frame 4 HORIZONTAL itemSpacing 8) — 사용자가 Email·Chat·Talk·Home 아이콘 채움

**04-header (P4 B2320 상세)** — `18013:2`:
- 03 복제 (4 아이콘 그대로 유지)
- 좌측 Frame 3 안에 텍스트 2단:
  - 서브 「구보다 콤팩트 트랙터」 Medium 13
  - 메인 「B2320」 SemiBold 17

### D. CdBd 데이터 관리 INSERT (editor_id=4778, 명함 데이터)

요청: "썸네일 호버 → 케밥 → 데이터 관리" — REST로 처리.

스키마 발견: **`editor_data`** 테이블 (editor_id, columns, rows, paid_rows, url_type, selected_column_id, alternative_url).

| order | name | column_id | alternativeName |
|---|---|---|---|
| 1 | 회사명 | `5437876c-ba5c-4c5e-b12d-b1033111c9fe` | 회사명 |
| 2 | 지점 | `c67db1dd-fca2-4028-86db-68afad2a8586` | 지점 |
| 3 | 주소 | `a91c186c-a683-4ef3-bb6d-7590dfd368cc` | 주소 |
| 4 | 전화번호 | `c46f821e-aba4-4010-bc2c-b7f54d381d8a` | 전화번호 |

**1행** (row_id `8dc84005-c4dc-40c3-b7f9-b0a518cbe6c5`):

| 회사명 | 지점 | 주소 | 전화번호 |
|---|---|---|---|
| 한국구보다주식회사 | 본사 | 전라북도 김제시 백산면 자유무역길 41-27 | 063-544-5822 |

대체어(`alternativeName`)는 사용자 후속 요청으로 데이터그룹명(`name`)과 동일하게 채움.

### E. 03-카테고리 그리드 (10개 모델 버튼)

원본 측정: 버튼 145×32 (native), 좌우 마진 22, 컬럼 갭 23, 행 갭 ~2.

**380 환산** (×1.0615) → `18015:2` `03-카테고리`:
```
03-카테고리 (VERTICAL auto-layout, 380×168)
  paddingLR 24 · itemSpacing 2
  ├ row × 5 (HORIZONTAL, FILL w, HUG h, itemSpacing 24)
  │  ├ btn (HORIZONTAL FILL × FIXED 32, 흰 외곽선 1, 라운드 5, padLR 14)
  │  │  └ Pretendard Medium 15 흰색 텍스트
  │  └ btn
```

사용자가 후속 수정: 행 그룹 해제 + `03-BG 1` RECTANGLE 추가 + 각 버튼에 `Polygon 1` 화살표.

**버튼 리네이밍** (좌→우, 위→아래):

| 새 이름 | 라벨 |
|---|---|
| 03-menu-1 | B2320 |
| 03-menu-2 | MR Series |
| 03-menu-3 | L4520V |
| 03-menu-4 | NEW MR Series |
| 03-menu-5 | L Series |
| 03-menu-6 | M5 Series |
| 03-menu-7 | M7460 |
| 03-menu-8 | M6 Series |
| 03-menu-9 | M7 Series |
| 03-menu-10 | NR23 |

### F. P4 이미지 자산 4종 + 화보 패턴 변환

B2320_top.jpg (1200×800, 3:2) 업로드 → `imageHash=ee0f1356f347d83a559ddfc1ed5d482b303ae1f8` 재사용:

| 프레임 | 노드 | 사이즈 | 위치 | RECT 사이즈 | RECT 위치 |
|---|---|---|---|---|---|
| 04-2 | `18022:2` | 340×226.67 (1:1 fit) | (229, -18692) | 340×226.67 | (0, 0) — 전체 |
| 04-3 | `18026:2` | 158×105.33 | (229, -18445) | 237×158 (1.5x zoom) | (-40, 0) — 상단 |
| 04-4 | `18026:3` | 158×105.33 | (395, -18445) | 237×158 | (-40, -27) — 중앙 |
| 04-5 | `18026:4` | 158×105.33 | (561, -18445) | 237×158 | (-79, -27) — 우측 |

**규칙 적용**: 사용자가 [[룩북/2. 디자인 가이드/2-1. 공통]] 「화보 = 별도 자식 RECTANGLE 레이어」 강제 → 모든 프레임에서 `frame.fills = []`, 자식 RECT로 이미지 이전. `clipsContent = true`. 각 RECT를 Figma에서 자유롭게 위치·사이즈 조정 가능.

### G. 04-6 사양 테이블 (벡터 재작성)

원본 캡처 대신 Figma 셀+텍스트로 직접 그림 → `18028:2` `04-6`:

| 항목 | 값 |
|---|---|
| 사이즈 | 340 × 95 (테이블 78 + 주석 17) |
| 컬럼 폭 (합 340) | 모델명 46 / 전장·전폭·전고 각 33 / 최저지상고 52 / 출력(PS) 28 / 전륜 52 / 후륜 63 |
| 행 높이 | 그룹헤더 24 / 서브헤더 24 / 데이터 30 |
| 스타일 | 흰 BG · 외곽선 `#C8C8C8` 1px (INSIDE) · Pretendard SemiBold/Medium 11pt |
| 2줄 처리 | 「최저/지상고」 「출력/(PS)」 |
| 단위 표기 | 「기체부」 우측 회색 8pt `(단위:mm)` |
| 주석 | 회색 9pt "* 상기 사양은 품질개선을 위해 예고없이 변경될 수 있습니다." |
| 타이어 데이터 | 셀이 좁아 10pt 사용 |

**데이터**: B2320 / 2650 / 1155 / 2075 / 300 / 20 / 6-12, 4PR / 9.5-16, 4PR

### H. 04-7 하단 고정 버튼 (3개)

`18030:2` `04-7` (HORIZONTAL auto-layout, 340×40, itemSpacing 10):

| 자식 | 사이즈 | 스타일 |
|---|---|---|
| `04-btn-download` (18030:3) | 240×40 (FILL) | 흰 BG · 오렌지 `#FFAA00` 외곽선 1.5 · 라운드 99 · 「카탈로그 다운받기」 오렌지 텍스트 SemiBold 14 |
| `04-btn-nav-1` (18030:5) | 40×40 원형 | 오렌지 fill · 흰 **K 아이콘** (워드마크 18009:6+7 클론, 22×23.5, 1.39배 스케일) |
| `04-btn-nav-2` (18030:6) | 40×40 원형 | 오렌지 fill · 흰 **영상-재생 아이콘** (createNodeFromSvg, 라운드 사각형 + 재생 삼각형 컷아웃 evenodd, 22×15.58) |

**유튜브 로고는 상표라 직접 재현 X** → 일반 video-play monochrome 아이콘으로 대체 (벡터로 작성).

---

## 현재 Figma 파일 구조 (Pages 페이지 직속)

```
Pages
├ Cover (4252:117, 1920×1080)              ← 내부 CdBd 작업 표지
├ Page (14005:23, 2584×180)
├ OG (16002:29, 800×400)                    ← Kubota 워드마크 단독
├ 02-header × 2 (18009:2, 18001:21)         ← 사용자가 복제 작업 중
├ 03-header × 2 (18011:2, 18001:100)        ← 4 nav 아이콘 채워짐
├ 04-header × 2 (18013:2, 18001:131)        ← 「구보다 콤팩트 트랙터 / B2320」
├ 03-카테고리 (18015:2, 380×168)             ← 10 모델 버튼 (03-menu-1..10)
├ 04-1 (18001:193, 340×260)                 ← 사용자 작성 (B2320 히어로)
├ 04-2 (18022:2, 340×226.67)                ← B2320_top, RECT layered
├ 04-3/4/5 (18026:2/3/4, 158×105.33)        ← 1.5x zoom 다른 영역
├ 04-6 (18028:2, 340×95)                    ← 사양 테이블 벡터
└ 04-7 (18030:2, 340×40)                    ← 하단 버튼 + K/재생 아이콘
```

> ⚠️ 사용자가 page 직속으로 작업 영역 변경 (이전엔 `16002:2` 「쁘렝땅 시안」 SECTION 안에 있었음). SECTION 없는 상태.

---

## 미완료 / 향후 확인 필요

- [x] og.jpg Figma 작성
- [x] P2/P3/P4 헤더 3종 작성
- [x] 03 카테고리 그리드 + 리네이밍
- [x] 04-1~7 자산 작성
- [x] CdBd editor_data INSERT (4열 1행)
- [ ] **CdBd 페이지 카드 등록**: editor 4778에 4페이지 + 30 카드 PATCH 안 됨 (자산 export → image_library 업로드 → editor.pages PATCH 워크플로우 미실행)
- [ ] **P1 카테고리 페이지** Figma 자산 미작성 (트랙터/콤바인/이앙기/관련상품 카테고리 카드)
- [ ] **P2 본사 페이지** 카드 등록 (헤더 외 본문·전화 버튼)
- [ ] **콤바인·이앙기·관련상품 상세 페이지** 미작성 (시안 단계 외)
- [ ] **B2320 외 9개 모델** 상세 페이지 미작성 (사용자 답변: dead link로 유지)
- [ ] **P4 카탈로그 다운로드 PDF URL** 사용자 제공 필요 (현재 placeholder)
- [ ] **사양 테이블 PNG export** 후 image_library 업로드 (현재 Figma 벡터만 존재)
- [ ] **하단 고정 토글**: CdBd 「하단 고정」 UI ↔ JSON 키 매핑 미검증 (CLAUDE.md 「디자인 보드 메뉴 1:1 매핑 키」 규칙대로 사용자 UI 토글 후 diff 추출 필요)

---

## 핵심 설계 결정사항

- **Kubota 브랜드 색**: header cyan `#009FA8`, orange `#FFAA00` (메이크뷰 픽셀 샘플링 정확 일치)
- **380 환산 비율**: 메이크뷰 native 358 → 380 = ×1.0615. 헤더 68→72px, 카테고리 버튼 145→154px
- **헤더 패턴**: `header-bg` 자식 (BG + 텍스트) + 별도 버튼/아이콘 자식 → CdBd 이미지 카드의 「카드 배경 이미지」 + `block.layers[]` 오버레이로 1:1 매핑
- **화보는 자식 RECT 필수**: CLAUDE.md 「화보 비크롭」 원칙 — frame fill로 imageTransform/CROP에 의존하는 anti-pattern 금지. 자식 RECT로 위치·사이즈 자유 조정.
- **YouTube 등 상표 직접 재현 금지**: 일반 monochrome UI 아이콘 (재생 삼각형 등)으로 대체
- **`editor_data` REST INSERT**: cdbd.in UI 안 거치고 직접 INSERT 가능. columns/rows JSON 구조 확인됨.

---

## 다음 세션에서 이어할 수 있는 작업

- [ ] **자산 export → image_library 등록**: `04-1`~`04-7` + 03 카테고리 + P2/P3/P4 헤더 → Figma REST API (scale=3 PNG) → `~/.config/cdbd/image_library.py` `upload_to_library()`
- [ ] **CdBd editor 4778 페이지 PATCH**: 4페이지 × 30 카드 spec JSON 작성 → `editor.pages` UPSERT → editor close 확인 후 publish 4-call (`editor_published` UPSERT → `editor_published_metadata` PATCH → `/api/update-url-key` → `save_editor_version` RPC)
- [ ] **사용자에게 PDF URL 받기**: 04-btn-download `linkButton` 연결
- [ ] **콤바인·이앙기·관련상품 페이지** 확장 (별도 시안 단계)

---

## 피그마 파일 정보

| 항목 | 값 |
|---|---|
| 파일 키 | `ngFTXXFvX6HI6gLjONSOev` |
| 파일 이름 | 구보다_2606 |
| 페이지 | `Pages` (0:1) |
| 주요 노드 ID | OG 16002:29 / 02-header 18009:2 / 03-header 18011:2 / 04-header 18013:2 / 03-카테고리 18015:2 / 04-2 18022:2 / 04-6 18028:2 / 04-7 18030:2 |
| 워드마크 클론 소스 | `kubota-wordmark (white)` 18009:5 (77×17, 8 vectors) |
| K 아이콘 소스 | 18009:6 (세로 바 3.32×12) + 18009:7 (각진 부분 11.79×16.88) |
| B2320_top imageHash | `ee0f1356f347d83a559ddfc1ed5d482b303ae1f8` |

---

## CdBd 데이터 정보

| 항목 | 값 |
|---|---|
| editor id | `4778` |
| title | `KUBOTA` |
| user_id | `523daa95-b43d-4a13-9919-e5ce7c097e06` |
| editor_data INSERT 시각 | 2026-06-11 07:26:00 UTC |
| row_id | `8dc84005-c4dc-40c3-b7f9-b0a518cbe6c5` |
| paid_rows | `[]` (URL 생성 안 됨) |

---

## Figma MCP / CdBd 자동화 기술 메모

1. **이미지 inline 업로드 한계**: `use_figma` 코드 50000자 제한 → 869KB 이미지(B2320_top) base64는 못 넣음 → `upload_assets` count=1 + nodeId로 단발 업로드. multipart/form-data `file` 필드 사용 시 파일명이 layer 이름이 됨.
2. **imageHash 재사용**: 한 번 업로드된 imageHash는 같은 파일 내 다른 노드에 직접 IMAGE Paint로 적용 가능 (재업로드 불필요). 04-3/4/5는 04-2 hash 재사용.
3. **scaleMode FILL + scalingFactor**: 업로드 직후 scalingFactor=0.5로 들어와 이미지가 zoom됨. 수동으로 `scalingFactor=1`로 보정 필요.
4. **`layoutSizingHorizontal = "FILL"` 순서 규칙**: append-to-parent **이후**에만 가능. 그렇지 않으면 "FILL can only be set on children of auto-layout frames" atomic rollback.
5. **createNodeFromSvg + evenodd fill-rule**: 컷아웃 모양 (음각) 만들 때 사용. play 삼각형이 오렌지 버튼 BG를 비치게 하는 패턴.
6. **CdBd browser 세션 만료**: `$B state load cdbd`만으론 로그인 유지 안 됨 (Next.js httpOnly chunked 쿠키 검증). REST 자동화는 `~/.config/cdbd/auth.py` `get_credentials()`로 access_token 자동 발급 가능 — 브라우저 UI 작업과 별개.
7. **editor_data 테이블 발견 절차**: 시도한 후보군 16개 중 단 1개(`editor_data`)만 200 응답. 다른 모든 후보 (editor_table, editor_dataset, editor_records, page_data 등)는 404. 공식 cdbd Next.js bundle에선 schema cache 자체에 노출됨 (chunk 5784 참고).
8. **paid_rows 의미**: 각 row마다 `{url, row_id, url_type, selected_column_id}` — row별 개별 공유 URL 발급 시 채워짐. INSERT 시점엔 `[]` 가능.
