# 산드로 CdBd 등록 — 세션 컨텍스트 (인수인계)

> 작성: 이선호 세션 / 최종 작업 2026-07-01 18:25
> 대상: 산드로(SANDRO) **초안** 룩북 → CdBd 멀티페이지 에디터 **4984**
> 상태: **14페이지 draft 등록 완료 · 게시(라이브) 전 · 사용자 검토 대기**

> **[2026-07-07 추가 작업]** 남성(옴므) 상품 링크 연결 + 갤러리 카드 디자인 수정 완료 (draft PATCH, 게시 전).
> - **09~13 갤러리 아이템 48개에 상품 URL 링크** = `gallery.images[i].linkButton {type:"url",link:{href,openNewTab:true}}` (JS 번들 5784 실측 검증 키). 셀→품번 매핑은 셀 이미지에 합본된 상품명+가격+색상으로 확정(엑셀 `_ _ _ 룩 EDM…` `EDM 구성(SH-순서변경버전)_최종` URL 블록). 검수: 도메인몰(ssfshop) 42개 = 페이지 title에 품번 임베드 확인(100%), 국제몰(sandro-paris) 6개 = 엑셀 지정 slug 그대로. 09-2-8/10-2-9/10-2-10/12-2-1/12-2-9/12-2-10 = 국제몰.
> - **02~06 + 09~13 갤러리 카드 10개**: 배경 투명화 = `backgroundImage.enabled=false` (0N-2-BG #FAFAFA+서브타이틀 비노출, url은 보존—재활성 가능) / **상단 여백** = `style.padding "40px 24px 32px" → "24px 24px 32px"` (top 40→24, 사용자 지시).
> - Supabase refresh_token 재발급: `.env`(cdbd-templates) CDBD_EMAIL/PASSWORD로 password-grant 로그인 → credentials.json 갱신. (worklog §6 소진 이슈 해결)
> - 게시는 여전히 사용자 UI 위임(14P > base quota). `editor_published` 미동기화 유지.

---

## 1. 한 줄 요약

산드로 초안 **여성(01~07) + 남성(08~14) = 14페이지**를 한 CdBd 에디터(4984)에 등록. `editor.pages`(draft)는 14페이지로 PATCH 완료·검증 통과. **`editor_published`(게시본)는 아직 이전 4페이지 상태 — 동기화/게시 안 함.** 사용자가 에디터에서 검토 후 게시 예정.

---

## 2. 리소스 / 위치

| 항목 | 값 |
|---|---|
| Figma 파일 | `SBsrBkMn2jsYLTJ94UYAv2` (산드로_2606) |
| 초안 섹션 | `4016:2` ("산드로 초안 (26 SUMMER)") — 14 프레임 |
| CdBd 에디터 | `4984` · title=SANDRO · slug(url_key)=`2026SS` · live=`cdbd.in/2account/2026SS` |
| 에셋 폴더 | `~/Desktop/CdBd/제작서비스 2026/06/산드로/작업파일/초안/` (+ `store_cells/` 서브폴더) |
| 문서 | `.../산드로/문서/` (엑셀 2종, 견적서) — 상품 URL·ssfshop.com/SANDRO 브랜드허브 |

### 페이지 프레임 노드 ID (Figma, 리네임 `01`~`14`)
`01=4041:314` · `02=4008:4` · `03=4009:2` · `04=4010:2` · `05=4010:87` · `06=4010:160` · `07=4012:2`(여성매장) · `08=4041:329` · `09=4038:5` · `10=4038:37` · `11=4038:75` · `12=4038:113` · `13=4038:151` · `14=4038:189`(남성매장)

### 갤러리 카드 배경 standalone 프레임 (0N-2-BG, export용)
`02=4054:2` `03=4054:4` `04=4054:6` `05=4054:8` `06=4054:10` / `09=4054:20` `10=4054:12` `11=4054:14` `12=4054:16` `13=4054:18`

---

## 3. 이번 세션에 한 일

### Figma (draft 정리)
- 각 상품 페이지에 **독립 `0N-2-BG` 카드배경 프레임 10개** 생성 (시안 방식 = #FAFAFA + 서브타이틀만, PNG 3배 export, 셀 없음).
- 그리드 셀 **106개 → `0N-2-{n}`** 리네임.
- 페이지 프레임 14개 → **`01`~`14`** 리네임(설명 텍스트 제거).

### 에셋 내보내기 (Figma REST API, 3배)
- 전체 **141개** → 초안 폴더: 표지 `01/08.jpg`, scl `0N-logo.png·0N-1.jpg·0N-2-BG.jpg·0N-2-{n}.png`, 매장 `07/14.jpg·store-logo.png`.
- 추가: 여성 매장셀 46개(`store-NN-N.png`) + 남성 매장셀 8개(`store14-NN-N.png`) → `store_cells/`.

### CdBd 등록 (Supabase 직접 자동화)
- 이미지 라이브러리 **총 192개** 업로드(`image_library.py` 헬퍼 경유, fresh).
- `editor.pages` = 14페이지 PATCH (204) · 구조 검증 통과.
- 페이지 구성:
  - **01/08** 표지 = 이미지 카드(풀블리드) + 다음 페이지 이동 링크
  - **02~06 / 09~13** scl = 이미지(로고 32%) + 이미지(메인 100%) + **갤러리 그리드 2단**(cells + `backgroundImage`=0N-2-BG)
    - 셀 수: 02=12 · 03=10 · 04=14 · 05=10 · 06=12 / 09=8 · 10~13=각 10
  - **07** 여성 매장 = 텍스트(STORE INFORMATION) + **23행 2단 multiCard**(이미지셀 + `tel:` linkButton) + 구분선 22 + 로고(비고정)
  - **14** 남성 매장 = 텍스트 + **4행 multiCard** + 구분선 3 + 로고(`fixedPosition:"bottom"`)
  - 전화 링크 **총 54개** (46 + 8), 표준 `linkButton` 키.
- **구분선 상하여백 0** (`style.padding:"0px 24px 0px"`, 07·14 총 25개).
- **여성 매장(07) 셀 높이 재수정 반영** (58→62px) — 46셀 재내보내기·라이브러리 교체·multiCard URL 스왑.

---

## 4. 현재 상태 / DB

| 테이블 | 상태 |
|---|---|
| `editor` (4984) | **pages=14 (draft, 최신)** ✓ |
| `editor_published` | **이전 4페이지 (미동기화)** — 게시 시 반드시 PATCH 필요 |
| `editor_published_metadata` | title=SANDRO · desc=26 SUMMER COLLECTION · is_active=true · OG=기존(06-29본) |
| `editor_url` | url_key=`2026SS` |
| `editor_published.is_menu` | false ✓ |

---

## 5. 남은 일 (다음 세션)

1. **사용자 에디터 검토** (`cdbd.in/editor/4984`) → 수정 요청 반영 (draft PATCH).
2. **게시** — ⚠️ **14P > base quota(~10P)** → 자동화 4/5-call publish 후 `get_editor_status_v2.is_available`가 false일 수 있음. 이 경우 **DB(editor+editor_published+metadata+editor_url) 다 채워두고, 사용자에게 cdbd.in UI 「게시」 버튼(또는 에디터 복제→URL 생성) 위임.** ⛔ `pay_individual_urls` 미리 결제 금지.
3. 게시 시 **`editor_published` 동기화 PATCH** 필수 (draft만 바꾸면 라이브 반영 안 됨).
4. **PATCH 전 사용자 에디터 탭 완전 close** (race condition — 자동저장 덮어쓰기).

---

## 6. ⚠️ 주의사항 / Gotchas

- **🔴 Supabase refresh_token 소진됨** (`already_used`). 원인 = 백그라운드 업로드 + 포그라운드 스크립트가 **동시에 refresh 호출** → rotation 충돌. 현재는 **캐시 access_token 직접 사용**(`.access_token_cache.json`, monkey-patch로 `get_credentials` 대체)으로 우회 중이나 **1시간 만료**. → **다음 작업 전 refresh_token 재발급 필수**: cdbd.in 로그인 F12 콘솔 1줄 실행 후 `~/.config/cdbd/credentials.json`의 `supabase_refresh_token` 교체.
  ```js
  JSON.parse(atob(decodeURIComponent(document.cookie.split('; ').filter(c=>c.startsWith('sb-jzwrixxevnfogfjzgaqz-auth-token.')).sort().map(c=>c.split('=').slice(1).join('=')).join('')).replace(/^base64-/,''))).refresh_token
  ```
- **자동화 시 백그라운드+포그라운드 동시 refresh 금지** — 순차 실행 or 캐시 토큰 공유.
- **매장 = 이미지 셀 multiCard** (텍스트 아님). 각 셀 이미지 + `linkButton:{type:"call",phone:{phone:"숫자만"}}`. 우리 산드로 매장 디자인엔 **브랜드관 버튼 없음** (타이틀+행+로고만).
- **중복 셀 4개 유지** (사용자 결정): 02(`02-2-4`,`02-2-12`) · 04(`04-2-12`) · 05(`05-2-4`) — 동일 이미지지만 순번 포함.
- 그리드 갤러리 카드 배경 = **`block.backgroundImage:{url,type:"original",enabled:true}`**.
- 페이지 이동 링크 = `linkButton:{type:"page",link:{href:"pageId={id}"}}`.

---

## 7. 임시 파일 (tmp, 재실행/복구용)

`/tmp/pages_final.json`(14P 최종) · `/tmp/vfem_urls.json`·`/tmp/vmen_urls.json`(에셋 URL) · `/tmp/store_urls.json`·`/tmp/store14_urls.json`(매장셀) · `/tmp/build_men.py`·`/tmp/reexport_store07.py`(빌드 스크립트) · `/tmp/cdbd_doc.md`(1-4 문서 사본)
