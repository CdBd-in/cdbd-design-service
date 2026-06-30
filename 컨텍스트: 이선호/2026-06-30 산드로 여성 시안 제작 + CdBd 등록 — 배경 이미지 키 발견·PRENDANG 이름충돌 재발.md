---
created: 2026-06-30
updated: 2026-06-30
purpose: 산드로 여성 시안 8p 제작(Figma) → CdBd editor 4960 등록·게시까지. CdBd 배경 이미지 키 2종 발견 + PRENDANG 이름충돌 재발·해결 기록.
related: "[[2026-06-09 PRENDANG 시안 CdBd 등록·갤러리 레이어 schema·default OFF 룰]]"
---

# 세션 컨텍스트 — 2026-06-30 산드로 여성 시안 제작 + CdBd 등록

> 이 문서는 **새 대화에서 산드로(SANDRO) 작업을 바로 이어갈 수 있도록** 작성된 인계 컨텍스트.
> 이전 세션(CdBd 등록 워크플로우 베이스): [[2026-06-09 PRENDANG 시안 CdBd 등록·갤러리 레이어 schema·default OFF 룰]] · [[2026-06-10 저장 경로 규칙 변경·CdBd 이미지 라이브러리 헬퍼 도입·PRENDANG anti-pattern 진단]]

---

## 작업 파일

- **Figma**: file key `SI36czRu3lBgkPzyrnPYkB` · 섹션 `산드로 여성 시안 (26 SUMMER)` 노드 `16782:330`
- **리소스**: `~/Desktop/CdBd/제작서비스 2026/06/산드로/`
  - `리소스/산드로 여성_메인 이미지/` — 화보 6컷(표지·1~5) + `logo.webp`(SANDRO 워드마크, 투명) + SSF 누끼 7 webp
  - `문서/산드로 리조트룩_PRE CO_EDM_제작의뢰 초안_260622_송부.xlsx` — 시트 `EDM 구성(SD)`이 산드로 여성, `산드로 여성 매장` 시트 = 매장정보
  - `문서/CdBd 견적서_산드로_260625.pdf` — 룩북 24p(14p 템플릿), URL 2개월 무료
  - `작업파일/시안/` — CdBd 등록용 export 이미지 보관(아래 참고)
- **CdBd editor**: `4960` · slug `sandro` · 게시 URL **https://cdbd.in/2account/sandro** · user_id `523daa95-b43d-4a13-9919-e5ce7c097e06`

---

## 오늘 완료한 작업 (2026-06-30)

### 1. 산드로 여성 시안 8페이지 제작 (Figma)
- **A·B 2안** (한눈에 다른 레이아웃):

| | A안 (Frame 계열) | B안 (Clean 풀블리드) |
|---|---|---|
| 시안표지 | TYPE-A + SANDRO 로고 | TYPE-B + SANDRO 로고 |
| 01 표지 | thick frame (흰 여백+하단 로고) | clean 풀블리드 (로고 화이트) |
| 02 소개 | thin frame(외곽선10)+dim40%+로고상단 | clean+dim40%+로고하단 |
| 03 내지 | **scl-frame-grid** (스크롤) | **swp-frame-clean** (스와이프 2p) |

- 리소스 매핑: 01=표지컷 / 02=여성_2 / 03 메인화보=여성_1
- OG: 800×400 로고 타입(흰 배경+SANDRO 중앙)

### 2. 03 유형 결정 변천 (중요 — Step 5 매트릭스)
- **최초 오판**: 리소스 폴더에 화보만 있어 `누끼 없음`으로 보고 `basic`으로 만듦.
- **정정**: 문서(엑셀 SD 시트)에 **상품별 제품컷(image1~60)** 임베드 → `누끼 있음 + URL 없음` → **swp/scl 상품 그리드**가 정답. basic 폐기.
- 최종: **A03=scl-frame-grid**(세로 스크롤 그리드) / **B03=swp-frame-clean**(화보 BG + 투명 카드 스와이프).

### 3. 누끼 처리 (Step 6 블로킹)
- 엑셀 임베드 누끼는 해상도 220px로 낮음 → 사용자가 **SSF샵에서 7컷 고해상(750×1000) 재다운**.
- ⚠️ SSF webp는 투명이 아니라 **연한 웜그레이 스튜디오 배경(231,229,227)**.
  - 내가 플러드필 키잉 시도 → **흰 의류(셔츠·드레스)가 배경색과 유사해 옷이 손상됨** (tol 높이면 갉아먹음).
  - **사용자 지적**: 배경 제거는 임의로 하지 말고 **Figma AI Remove background 요청**할 것 (CLAUDE.md 규칙). → 사용자가 직접 가공.
  - 최종 누끼 취득: 가공된 보드 노드를 **Figma REST API로 export → PIL alpha bbox 크롭 → 재업로드**.
- 상품 10개(SUMMER DRESS 테마). A03 그리드는 12칸(CREPON·COTTON MAXI 중복 2개 포함, 사용자가 유지 지시).

### 4. CdBd editor 4960 등록·게시
- editor는 **사용자가 미리 생성**(slug `sandro`, title `SANDRO`, desc `26 SUMMER COLLECTION`).
- 8 CdBd 페이지: 시안표지A→A01→A02→A03(scl)→시안표지B→B01→B02→B03(swp). OG는 메타.
- Supabase 직접 PATCH + 게시 시퀀스(editor_published UPSERT → metadata is_active → update-url-key → save_editor_version). `is_available=true` 확인.

### 5. PRENDANG 이름충돌 사고 + 해결 (⚠️ 재발 방지)
- **증상**: 일부 페이지에 산드로가 아닌 **PRENDANG 이미지**가 올라감.
- **원인**: `image_library.upload_if_missing(name='A')`가 **같은 계정의 PRENDANG(editor 4739)이 먼저 등록한 동일 이름 엔트리를 재사용**. (A·A01·B·og가 오염)
- **해결**: 전 이미지 **3배 재export + 고유 이름 `sandro_*`로 강제 신규 업로드** → 충돌 차단. 페이지1=SANDRO 확인.

### 6. 사용자 최종 수정 (Figma + 에디터 둘 다) — 배경 키 발견
- 사용자가 내 등록본 위에 직접 수정:
  - **B03**: 내 "화보 합성(baked)" 방식 버리고 **페이지 배경=화보 + 투명 갤러리(swp0 커버·swp1·swp2)**로 정식 재구성.
  - **A03**: 갤러리 카드 배경=서브타이틀 이미지 적용 + 셀 12개 재업로드 + 패딩 조정.
  - **2·3페이지**: A01·A02 재업로드 교체.
- → 내가 못 찾던 **배경 이미지 JSON 키 2종 확인**(아래 「CdBd 기술 메모」).

---

## 현재 Figma 섹션 구조 (`16782:330`)

```
산드로 여성 시안 (26 SUMMER)   섹션 16782:330
├ OG (800×400)              16836:381
├ 시안표지 A                 16836:352   ← TYPE-A + SANDRO 로고(16791:330 류)
├ A01-표지 (thick frame)     16836:362
├ A02-소개 (thin frame)      16836:366
├ A03-scl-frame-grid         16836:383   ← 로고+화보(16836:385)+서브타이틀(16842:330)+그리드(GRID, 12셀)
├ 03-2-BG                     16900:330   ← (사용자 신규) A03 갤러리 카드 배경용(서브타이틀)
├ 시안표지 B                 16836:357   ← TYPE-B
├ B01-표지 (clean)           16836:372   ← 로고 화이트
├ B02-소개 (clean)           16836:375
├ B03-BG                     16893:330   ← 화보 커버(페이지 배경 소스). 화보rect 16893:331/로고16893:332/서브16893:333
├ B03-swp0                   16902:480   ← (사용자 신규) 투명 커버
├ B03-swp1                   16836:449   ← 화보rect 16836:450 / 카드 16885:330 (2-1-2 행)
└ B03-swp2                   16836:453   ← 화보rect 16836:454 / 카드 16886:330
```

---

## 핵심 설계 결정사항

- **03 = scl/swp (basic 아님)**: 문서 임베드 제품컷 = 누끼로 인정. Step 5 매트릭스에서 `[리소스]` 폴더뿐 아니라 **문서 내 누끼도 확인**해야 함.
- **A03 12칸 유지**: 사용자가 A03 그리드를 직접 편집(CREPON·COTTON MAXI 중복 2개 포함). "이 순서·구성 바꾸지 말 것" 지시. B03은 중복 제외 10개·5/5 분할.
- **B03 = 2·1·2 3행** + 각 행 좌우 중앙 정렬(행 단위 가로 AL `primaryAxisAlignItems=CENTER`). 제품 사이즈는 행당 2개라 셀 폭 150으로 키움.
- **누끼 배경 제거 = Figma AI만** (플러드필 등 로컬 처리 금지 — 흰 의류 손상). 사용자 가공 결과를 REST export로 취득.
- **이미지 업로드 = 고유 이름 필수** (브랜드 prefix). `upload_if_missing`는 계정 단위 라이브러리에서 동명 재사용하므로 멀티브랜드에서 오염 위험.

---

## 피그마 파일 정보

| 항목 | 값 |
|---|---|
| File Key | `SI36czRu3lBgkPzyrnPYkB` |
| 섹션 | `16782:330` |
| 시안표지 템플릿(원본) | A=`14015:23` / B=`14015:106` (SECTION `16001:96`) |
| 03 레퍼런스(scl 클린 그리드) | `16100:1633` (서브타이틀+2열 grid gap0 셀166×196) |

> ⚠️ 섹션이 한 번 재생성되며 노드 ID가 `16782:*`→`16836:*`로 대량 변경된 적 있음. **작업 전 항상 `getNodeByIdAsync`로 현재 ID 재확인** (특히 `getNodeById`가 null 반환 시 `getNodeByIdAsync` 사용).

---

## CdBd 기술 메모 (다음 세션 필수)

### 🔑 배경 이미지 JSON 키 2종 (이번 세션 신규 발견)
1-4 문서에 없던 키. 사용자가 UI에서 적용 → editor GET diff로 확인:

| 용도 | JSON 위치 | 형식 |
|---|---|---|
| **페이지 배경** (swp-clean `03-BG`) | `page.background.backgroundImage` | `{"url": "...", "type": "original", "enabled": true}` |
| **카드(갤러리) 배경** (`03-2-BG` 등) | `block.backgroundImage` (block 직속) | `{"url": "..."}` |

- ⚠️ `style.background = "url('...')"` 는 **렌더 안 됨**(라이브 computed backgroundImage 0건 검증). 위 두 키를 사용할 것.
- B03(swp-clean): 페이지에 `background.backgroundImage`(화보) + 갤러리는 **투명 이미지들**(커버·swp1·swp2) + 갤러리 `style.background:"transparent"`.
- A03 갤러리(그리드): `block.backgroundImage`(서브타이틀 이미지) + 셀 12장.
- **→ 1-4 문서 「카드별 디자인 보드 메뉴 → JSON 키 매핑」에 이 2종 추가 반영 필요(미완).**

### ⚠️ PRENDANG 이름충돌 (재발 방지)
- `upload_if_missing(name='A')` = 계정 라이브러리에 동명 엔트리 있으면 **재사용** → 타 브랜드 이미지 오염.
- **반드시 브랜드 prefix 고유 이름**(`sandro_A` 등) 또는 `upload_to_library`(강제 신규) 사용.
- 진단: editor GET → 각 이미지 URL을 `image_modal` path로 역매핑해 `name`·`created_at` 확인.

### 인증·게시 메모
- `~/.config/cdbd/auth.py` refresh_token이 **`refresh_token_already_used`** 자주 발생 = cdbd.in 탭 열려 있어 rotation 충돌. 사용자에게 토큰 재추출(콘솔 1줄) 요청 → credentials.json 갱신.
  - 임시 우회: `~/.config/cdbd/.access_token_cache.json`의 access_token이 1시간 유효 → refresh 막혀도 캐시 토큰 직접 사용 가능(만료 확인).
- Figma PAT: `credentials.json['figma_pat']`에서 직접 읽어 REST export (`/tmp/figpat.txt` 만들지 말 것, auth.py 실패 시 안 만들어짐).
- **사용자 선호**: 에디터 탭 닫았는지 **매번 묻지 말 것**(2026-06-30 지시).
- editor 4960: `paid_pages:2`로 표시되나 `is_available:true` + 8p 전부 렌더 → 정상(2개월 무료 URL).

---

## 미완료 / 향후 확인 필요

- [ ] **1-4 CdBd 문서에 배경 키 2종 반영** (`page.background.backgroundImage`, `block.backgroundImage`) + `style.background=url()` 미작동 경고 추가.
- [ ] 사용자가 교체한 **2·3페이지(A01·A02 재업로드)·A03 셀 12장**의 내용/해상도 검수 미완 (라이브 캡처 비교 안 함).
- [ ] A03 그리드 **중복 셀(CREPON·COTTON MAXI ×2)** 처리 방향 — 사용자가 12칸 유지했으나 "제품 10개"와 불일치. 추후 정리 여부 확인.
- [ ] **남성복(옴므) 라인** 미착수 (이번 세션은 여성 라인만). 리소스 `산드로 옴므_메인 이미지/` 6컷 대기.
- [ ] 매장정보 페이지(`산드로 여성 매장` 시트) 미제작.
- [ ] 슬러그 `sandro` 유지(시안 규칙 `sandro_2606` 아님) — 사용자 확정값.

---

## 다음 세션에서 이어할 수 있는 작업

- **남성복(옴므) 시안 제작** — 여성과 동일 A·B 구조, `산드로 옴므_메인 이미지/` 사용.
- **1-4 CdBd 문서 갱신** — 배경 이미지 키 2종 + PRENDANG 이름충돌 재발 방지 규칙 추가.
- **산드로 초안(전체 24p)** 진행 — 시안 채택안 기반. 11p 이상이면 quota 때문에 사용자 UI 게시 위임 필요.
- **매장 정보 페이지** 제작 + CdBd 등록(요소별 카드 + tel 링크 레이어).
