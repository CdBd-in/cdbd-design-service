# 세션 컨텍스트 — 2026-06-10 저장 경로 규칙 변경·CdBd 이미지 라이브러리 헬퍼 도입·PRENDANG anti-pattern 진단

> 이 문서는 새 대화에서 작업을 바로 이어갈 수 있도록 작성된 컨텍스트 파일이다.
> 이전 세션: [[2026-06-09 PRENDANG 시안 CdBd 등록·갤러리 레이어 schema·default OFF 룰]]

---

## 작업 파일

- **수정 문서:**
  - `룩북/1. 제작 프로세스/1-1. 공통.md` *(저장 경로 규칙 변경 — line 45 인라인 + 「저장 위치」 섹션 폴더 구조·생성 규칙 + 내보내기 체크리스트)*
  - `룩북/1. 제작 프로세스/1-4. CdBd 콘텐츠.md` *(「이미지 라이브러리 (사용자 자산 관리)」 섹션 신설 + 「Supabase Storage 업로드」 헬퍼 사용 패턴으로 교체 + 한계/회피 표 + 작업 후 검증 체크리스트 + 🚨 PRENDANG 4739 anti-pattern 사례 기록 + 「CdBd 등록 워크플로우」 전제 폴더 경로)*
  - `CLAUDE.md` *(작업 원칙 신설: ⚠️⚠️ 카드/페이지 이미지 = 반드시 이미지 라이브러리 경유 · ⚠️ 브라우저 자동 로그인 절차(state save/load) · 인라인 폴더 경로 갱신)*
- **신규 파일:**
  - `~/.config/cdbd/image_library.py` *(이미지 라이브러리 업로드·등록·조회 헬퍼 — `upload_to_library` / `upload_if_missing` / `list_library` / `find_in_library` / `delete_from_library` / `short_id`)*
  - `./.gstack/browse-states/cdbd.json` *(헤드 브라우저 cdbd.in 로그인 세션 state — mode 600, `.gitignore` 포함)*
- **신규 문서:**
  - `컨텍스트: 이선호/2026-06-10 저장 경로 규칙 변경·CdBd 이미지 라이브러리 헬퍼 도입·PRENDANG anti-pattern 진단.md` *(본 문서)*
- **CdBd 검증 대상:**
  - editor `4355` (테스트용 — 「내 이미지」 모달 + 이미지 라이브러리 백엔드 파악 + end-to-end 업로드/정리 200/204 검증)
  - editor `4739` (PRENDANG — 12장 중 11장 라이브러리 미등록 진단)

---

## 오늘 완료한 작업 (2026-06-10)

### A. 저장 경로 규칙 변경 ✅

사용자 요청: `CdBd > 제작서비스 2026 > 현재월(MM) > 브랜드 > 작업파일 > 시안/초안` 폴더 구조로 변경.

**새 폴더 구조** (1-1. 공통):
```
~/Desktop/CdBd/                          (로컬 데스크탑 / 바탕화면 안 CdBd 작업 루트)
└── 제작서비스 2026/                       ← 연도별 폴더 (해마다 갱신: 2027 → `제작서비스 2027`)
    └── 06/                              ← 작업 시작/저장 시점의 시스템 월 (2자리, zero-pad)
        └── 브랜드명(국문)/                 ← 예: 쁘렝땅
            └── 작업파일/
                ├── 시안/                 A·A01~A03 · B·B01~B03 (+ og.jpg)
                └── 초안/                 01·02·03 …
```

**규칙 결정 사항** (사용자 확정):
- 루트 위치: `~/Desktop/CdBd/...`
- `MM`: 작업 시작/저장 시점의 **시스템 월** zero-pad (`date +%m`). 월 바뀌면 새 작업부터 다음 월 폴더에, 진행 중인 작업은 시작 월 폴더 유지.
- `YYYY`: 현재 연도 (2026).
- 폴더 없으면 자동화에서 `mkdir -p`로 전체 경로 생성.

**갱신한 곳 3건**:
- `1-1. 공통.md` line 45 인라인 / 「저장 위치」 섹션 / 내보내기 체크리스트
- `1-4. CdBd 콘텐츠.md` 「CdBd 등록 워크플로우」 전제 폴더 경로
- `CLAUDE.md` 「작업 원칙」 인라인 ① 단계

**남겨둔 곳**: `컨텍스트: 이선호/2026-06-01.md` 251줄 (당시 작업 기록이라 의도적 보존).

---

### B. CdBd 이미지 라이브러리 메커니즘 도입 ✅

**배경**: 사용자가 cdbd.in 「이미지 추가하기 → 내 이미지」 모달에서 이름 변경·삭제·검색·재선택으로 자산을 관리. 기존 자동화(raw `storage/v1/object` POST + `block.content` set)는 사용자 라이브러리 UI에 안 보여 관리 불가 — **anti-pattern**.

**해결**: 모든 카드/페이지 이미지 자동화는 **`~/.config/cdbd/image_library.py` 헬퍼 경유 의무화**.

#### 백엔드 구조 (editor 4355 실측 — 2026-06-10)

| 항목 | 값 |
|---|---|
| 테이블 | `image_modal` (user당 1 row, `images` jsonb array) |
| Storage 버킷 | `user_image` (private — signed URL 필요) |
| Storage 경로 | `{user_id}/{YYYYMMDDHHMMSS}_{rand12}.{ext}` |
| signed URL 유효 | 약 30년 (`expiresIn: 946080000` — UI 발급값과 동일) |
| 카드 참조 | `block.content`(image) / `block.gallery.images[].url`(gallery)에 같은 signed URL 그대로 사용 |

**`image_modal.images[]` entry 스키마**:
```json
{
  "id": "{nanoid 8-4-4-4-12, [A-Za-z0-9_-]}",
  "url": "{전체 signed URL}",
  "name": "{확장자 제외 파일명, 예: 'A01'}",
  "path": "{user_id}/{YYYYMMDDHHMMSS}_{rand12}.{ext}",
  "size": "{bytes as string}",
  "type": "{lowercase 확장자: 'jpeg', 'png', 'webp'}",   // 'jpg' 아닌 'jpeg'
  "pexels": null,
  "user_id": "{user_id}",
  "folder_id": null,
  "created_at": "{ISO8601 UTC + ms + Z, 예: '2026-06-10T03:11:06.551Z'}",
  "deleted_at": null,
  "is_deleted": false,
  "resolution": "{W}*{H}",                            // '*' 구분자 ('x' 아님)
  "is_bookmarked": false
}
```

#### 검증 완료 3-call 시퀀스

```
1) Storage POST   /storage/v1/object/user_image/{uid}/{ts}_{rand12}.{ext}
   Headers       apikey + Bearer + Content-Type: image/{ext} + x-upsert: false
   Body          raw bytes
   ←             200  {Key, Id}

2) Sign URL POST  /storage/v1/object/sign/user_image/{uid}/{ts}_{rand12}.{ext}
   Body          {"expiresIn": 946080000}
   ←             200  {signedURL: "/object/sign/user_image/{path}?token=..."}
   Full URL      {SUPABASE_URL}/storage/v1{signedURL}

3) Modal PATCH    /rest/v1/image_modal?id=eq.{modal_id}
   Body          {"images": [<new_entry>, ...existing], "is_saving": false}
   ←             204
```

editor 4355에서 테스트 업로드 → 라이브러리 31→32 → 정리 모두 200/204 통과.

#### 헬퍼 `~/.config/cdbd/image_library.py`

| 함수 | 용도 |
|---|---|
| `upload_to_library(path, name=, resolution=)` | 신규 업로드 + 등록 (3-call) |
| `upload_if_missing(path, name=)` | 동일 name 이미 있으면 entry 재사용 (룩북 재작업용) |
| `list_library(name_filter=)` | 라이브러리 그리드 조회 |
| `find_in_library(name, exact=)` | exact name 매치 1장 |
| `delete_from_library(id_or_name, also_delete_storage=)` | 라이브러리 + 스토리지 동시 제거 |
| `short_id(length=21)` | 갤러리 카드의 `images[].id` 발급 (21자 no-dashes) |

```python
import sys, os
sys.path.insert(0, os.path.expanduser('~/.config/cdbd'))
from image_library import upload_if_missing, short_id
res = upload_if_missing('/path/A01.jpg', name='A01')
card['content'] = res['url']                                             # image 카드
block['gallery']['images'].append({'id': short_id(), 'url': res['url']}) # gallery 카드
```

**진단 모드**: `python3 ~/.config/cdbd/image_library.py` → 현재 라이브러리 항목 수·최근 5개 출력.

#### 자동화 시그니처 차이 (storage path suffix 알파벳)

- **mixed-case** (`Hp6p1nMDbfjS`) → UI 업로드 또는 새 헬퍼 (`string.ascii_letters + string.digits`)
- **lowercase-only** (`793itkm8byet`) → 이전 자동화 (= 라이브러리 미등록 가능성 높음)

새 헬퍼는 mixed-case로 발급해 UI 업로드와 외관 일치.

---

### C. PRENDANG (editor 4739) anti-pattern 진단 ✅

사용자 질문 "이전 PRENDANG에 사용한 이미지들은 어디에 업로드한 거야?" 답변:

| 항목 | 결과 |
|---|---|
| editor 4739가 참조하는 이미지 | **12장** (signed URL — 페이지·게시 URL은 정상 동작) |
| `image_modal` 라이브러리에 등록됨 | **1장** (`vxZv5xTrwxYa.png` 로고 — UI 업로드로 추정, mixed-case suffix) |
| 미등록 (storage 직접 POST만) | **11장** (suffix `[a-z0-9]` lowercase-only — 어제 자동화 시그니처) |

**의미**: 11장은 storage엔 있지만 사용자의 「내 이미지」 모달에 안 보임 → 이름 변경·삭제·재선택 불가. 이게 새 규칙이 막으려는 anti-pattern의 살아있는 사례.

**결정 (사용자)**: PRENDANG은 이미 게시 완료 → 그대로 두고 다음 작업부터 새 규칙(헬퍼 경유)으로 시작.

**보강이 필요해질 경우**:
- 원본 파일명(`A01`/`B03-1` 등)은 storage path엔 안 남음 → 페이지·카드 컨텍스트로 추정하거나 사용자에게 묻기
- `image_library.py`에 기존 storage 파일은 그대로 두고 entry만 추가하는 함수가 필요해지면 별도 작성

---

### D. CdBd 브라우저 자동 로그인 ✅

**문제**: cdbd.in은 Next.js 미들웨어가 httpOnly + chunked supabase 쿠키를 검증 → Supabase access_token만으로 cookie 주입 불가. 비밀번호는 보안상 credentials.json에 저장 안 함.

**해결**: `$B state save cdbd` 방식 — 사용자가 1회 로그인 후 저장하면 다음 세션부터 자동 복원.

**진입 시퀀스** (CLAUDE.md에 문서화):
1. `$B status` → daemon 확인
2. `$B state load cdbd` → 쿠키 복원 → 에디터 URL 이동
3. `/login`으로 redirect되면 = 세션 만료 → 사용자 1회 로그인 요청 → 로그인 후 **반드시 `$B state save cdbd`로 갱신**

저장 위치: `./.gstack/browse-states/cdbd.json` (mode 600, `.gitignore` 포함)

`~/.config/cdbd/credentials.json`은 Supabase refresh_token (REST 자동화용)만 저장. 브라우저 세션과는 별개 트랙.

---

## 핵심 규칙 요약 (CLAUDE.md 신설)

1. **⚠️⚠️ (최상위) CdBd 카드/페이지 이미지 = 반드시 「이미지 라이브러리」 경유**
   - raw `storage/v1/object` POST + `block.content`/`gallery.images[].url` 직접 set 금지
   - `~/.config/cdbd/image_library.py` 헬퍼의 `upload_to_library()` / `upload_if_missing()`만 호출
   - 갤러리 카드 image id는 헬퍼의 `short_id()`(21자 no-dash) 발급
   - 작업 후 `python3 ~/.config/cdbd/image_library.py`로 새 entry 검증

2. **⚠️ CdBd 브라우저 자동 로그인**
   - 매번 비밀번호 묻지 말 것
   - `$B state load cdbd` → redirect되면 1회 로그인 → `$B state save cdbd` 갱신

3. **저장 경로 규칙**
   - `~/Desktop/CdBd/제작서비스 {YYYY}/{MM}/{브랜드명}/작업파일/시안 or 초안/`

---

## 다음 세션 진입 시

### 자동화 진입 정상 흐름

```bash
# 1. 인증
python3 -c "
import sys, os
sys.path.insert(0, os.path.expanduser('~/.config/cdbd'))
from auth import get_credentials
creds = get_credentials()  # access_token 자동 refresh
"

# 2. 브라우저 (필요 시)
B=/Users/designer/.claude/skills/gstack/browse/dist/browse
$B status                    # daemon 확인
$B state load cdbd           # 세션 복원 (있으면)

# 3. 이미지 라이브러리 진단 (옵션)
python3 ~/.config/cdbd/image_library.py
```

### CdBd 자동화 시 필수 패턴

```python
import sys, os
sys.path.insert(0, os.path.expanduser('~/.config/cdbd'))
from auth import get_credentials
from image_library import upload_if_missing, short_id

creds = get_credentials()

# 카드 이미지: 라이브러리 등록 → 그 URL 사용
for figma_export_path in [...]:
    res = upload_if_missing(figma_export_path)   # name = 파일명 자동
    image_card['content'] = res['url']

# 갤러리 카드: 라이브러리 entry + 갤러리 image id 별도
gallery_block['gallery']['images'] = [
    {'id': short_id(), 'url': upload_if_missing(p)['url']}
    for p in look_export_paths
]
```

### 검증 체크리스트 (배포 직전)

- [ ] 모든 이미지 자산이 「내 이미지」 라이브러리에 등록됨 (storage 직접 POST 흔적 없음)
- [ ] `python3 ~/.config/cdbd/image_library.py` 출력에서 이번 작업 자산 모두 보임
- [ ] `name` 필드 = 파일명에서 확장자 제거 (사용자가 이해할 수 있는 이름)
- [ ] `resolution = W*H` (별표, `x` 아님), `type = jpeg` (jpg 아님)

---

## 미해결·후속 작업

- [ ] **이전 작업물(PRENDANG 4739) retroactive 등록 함수** — 필요해지면 `image_library.py`에 `register_existing_storage_path(path, name)` 형태로 추가 (storage 파일은 안 건드리고 entry만 PATCH로 추가). 현재는 사용자 결정으로 보류.
- [ ] **에디터 PATCH 전 close 확인** + **이미지 라이브러리 헬퍼** 조합 시 race condition 확인 — `image_modal` PATCH도 에디터 client-side state와 충돌할 수 있는지 (이미지 라이브러리 모달이 열려있을 때만 위험할 듯) 실측 필요
- [ ] **갤러리 카드 image id 포맷 재검증** — 관측한 `6AIrcWpM8LUXW7uVQoOnk`(21자)이 표준인지, 다른 길이도 허용되는지. 헬퍼는 21자 고정 발급 중.
- [ ] **`folder_id` 활용** — `image_modal.folder_id` 컬럼 존재. 사용자가 「폴더로 분류」 기능 사용하는지, 자동화에서 폴더 자동 할당이 필요한지 확인 필요.

---

## 관련 문서·자산

- [[1-1. 공통]] — 저장 경로 규칙
- [[1-4. CdBd 콘텐츠]] — 이미지 라이브러리 섹션 + 운영 체크리스트 + 🚨 PRENDANG 4739 anti-pattern 사례
- [[CLAUDE.md]] — 최상위 작업 원칙
- `~/.config/cdbd/auth.py` — Supabase access_token + Figma PAT 헬퍼
- `~/.config/cdbd/image_library.py` — 이미지 라이브러리 헬퍼 (오늘 신설)
- `./.gstack/browse-states/cdbd.json` — 브라우저 세션 state (오늘 신설)

---

# 2026-06-10 추가 세션 — PRENDANG 초안 CdBd 등록 + 가이드 갱신 + paid_pages 발견

## 사용자 요청 (순서대로)

1. 인수인계 문서 + 배경 늘림 보드(`16137:2`) 확인 → 가이드 강화 + 풀샷 상하 여백 3:2 비율로 갱신
2. 시안 참고해서 초안 CdBd 콘텐츠 제작 (swp 갤러리 + image_library 경유 + 19페이지 prendangfashion/26SUMMER page 17 ref + PPT 링크)
3. 게시 시도 → 「게시 중지」 화면 → 디버그
4. 사용자가 4764 복제 → 4765에서 작업 진행
5. 19페이지 일부 수정 (white 로고, 버튼 카드, 하단 정렬)
6. 08-swp2 상단 화이트 픽셀 제거

## 결과 (한 줄)

쁘렝땅 초안 CdBd 등록 + 게시 완료: **`https://www.cdbd.in/2account/26PREWINTER`** (editor 4765, 19P, version 1062, paid_pages=19 · is_available=true). 디자인 가이드 「풀샷 3:2 비율」 + 「배경 늘림 보드 패턴」 신설. `paid_pages` quota 자동화 불가 케이스 실측 + 복제 우회 패턴 문서화.

---

## 1. 가이드 문서 갱신 (배경 늘림 보드 + 풀샷 3:2 비율)

### 1-1. 배경 늘림 보드 (Figma AI 처리 요청)

**[[2-1. 공통]] 「화보 이미지 배치」** 안에 신설 서브섹션:

- Figma AI 배경 늘림은 에디터 전용 → 자동화 API 호출 불가 → 별도 보드에 모아서 사용자에게 일괄 요청
- 보드 구조 (참조: 쁘렝땅 `16137:2` `배경 늘림 필요 이미지`)
  - 카드명: `BG-EXT-{imageName}-{방향}` (`BG-EXT-image5-상단`, `BG-EXT-image19-좌우늘림필요` 등)
  - 카드 한 장: direction badge + extend-source RECT + image-name + reason
- 워크플로우 6단계 (블록 / blocking):
  ① 수집 → ② 사용자에게 보드 위치 + 방향 안내 → ③ 가공 완료 신호 대기 (해당 셀 빌드 보류) → ④ 새 hash로 fill 교체 → ⑤ 위치·사이즈 결정 트리 재적용 → ⑥ 보드는 비교/추적용으로 남겨 둠
- 좌우 늘림은 별도 보드 가능 (`16146:2` 패턴)

**[[CLAUDE.md]] 「레이아웃 핵심 원칙」 신규 한 줄 추가**:
> ⚠️ 상하·좌우 여백 동시 만족 불가 시 = 임의 크롭 금지, 「배경 늘림 보드」로 사용자에게 일괄 요청

### 1-2. 풀샷 상하 여백 = 3:2 비율 (40/20 근사치)

**이전 표기**: 「상단 ≥ 40, 하단 ≥ 20」 = 2:1 분배 기본
**갱신**: **「상단:하단 ≈ 3:2 비율」** (상단 여백이 하단의 약 1.5배), 가용 마진 60 → top ≈ 36 / bottom ≈ 24 권장. **40/20은 정확 픽셀이 아니라 근사 참조값**. 가용 마진이 달라지면 같은 비율로 분배 (예: M=80 → top=48, bottom=32). 1:1처럼 같거나 하단이 더 크면 실패.

**갱신 위치**:
- [[2-1. 공통]] 결정 트리 [규칙 A] + 빠른 참조 표 + 「풀샷 (Rule A) 상단:하단 ≈ 3:2 비율 계산」 섹션 전면 갱신
- [[2-4. 화보·상품]] 03-BG 풀샷 마진 갱신
- [[CLAUDE.md]] 「레이아웃 핵심 원칙」 첫 항목 갱신

---

## 2. 쁘렝땅 초안 CdBd 등록 (editor 4765, 공개 URL: `26PREWINTER`)

### 2-1. 구조 — 시안 A03 패턴 그대로 복제 + 19페이지 추가

| 페이지 | 카드 시퀀스 | 비고 |
|---|---|---|
| 01 표지 | image(100% width) | `01.png` 전체 export |
| 02 컬렉션 소개 | image(100%) | `02.png` 전체 export |
| 03~18 (LOOK 1~16) | image(로고 38%) + gallery(swp 컷, 넘겨보기, navigation=OFF) + text(OUTER + SKU) | 시안 A03 패턴 그대로 |
| 19 매장 정보 | image(로고 50%) + button(오프라인 매장 안내, linkButton url) + SNS(homepage·instagram·kakaotalk) | BG=`19.png` (dim baked-in) |

- LOOK 4·14만 3컷 갤러리, 나머지 14 LOOK은 2컷 — **총 34컷**
- 갤러리 navigation 모두 OFF (CLAUDE.md 기본 OFF 규칙)
- `is_menu = False` (룩북 기본 OFF)

### 2-2. 자산 export + 라이브러리 등록

- Figma file `KtAfHIIDEUt0XoSXPNHC0x` 섹션 `쁘렝땅 초안` `16006:247`에서 39개 자산 export
- `og.jpg` (1배수 JPG, 800×400, node `16026:20`)
- `logo.png` (3배수, 검정 워드마크, node `16028:2` — 03 페이지 logo-bk)
- **`logo_white.png`** (3배수, 흰 워드마크, node `16027:15` — 02 페이지 `_레이어_1`)
- `01.png`, `02.png`, `19.png` (3배수 페이지 frames)
- 34 swp 컷 (`03-swp1`~`18-swp2`, node `16087:*`)
- 모두 `~/.config/cdbd/image_library.py` 경유 등록 → 사용자 「내 이미지」에서 관리 가능
- 이름 prefix: `draft_*` (시안 자산과 구분)

### 2-3. 19페이지 변경 이력 (사용자 요청에 따른 PATCH 시퀀스)

| version | 변경 |
|---|---|
| 1056 | 초기 빌드 (logo black, text 카드 with linkButton, SNS) |
| 1060 | 로고 → **white** (`draft_logo_white`) + 버튼 카드 상단 여백 `20px → 260px` (페이지 하단 정렬) |
| 1062 | **text 카드 → button 카드** 변환 (innerStyle.background `rgba(255,255,255,0.25)`, color 흰, fontWeight bold, width 100%, buttonStyle 100/100, linkButton 유지) |

### 2-4. 08-swp2 상단 화이트 제거 (Figma 수정 → re-export → PATCH)

- 진단: `08-swp2.png` 상단 6px (1배수 ≈ 2px) 순백 픽셀 (255,255,255,255)
- 원인: Figma frame `08-swp2` `16087:26` (340×440) 안에서 image rect `16087:27`이 `y=2`로 배치됨 → 상단 2px 비어 화이트 export
- 수정: `use_figma`로 rect `y=2 → y=0` → re-export → 라이브러리 재업로드 (`draft_08-swp2_v2`) → editor 4765 page 08 (LOOK 6, OUTER `PA4FV03-0GS`) 갤러리 `images[1].url` 교체 → version 1061
- 검증: y=0 픽셀 `(243, 244, 241, 255)` 화보 컬러 ✓ (white rows = 0)

---

## 3. ⚠️ paid_pages quota 활성화 자동화 불가 (신규 발견)

### 3-1. 증상

자동화로 4-call publish 시퀀스(`editor_published` UPSERT → `metadata.is_active=true` PATCH → `update-url-key` → `save_editor_version` RPC) 정상 완료 후에도 **공개 URL이 「게시 중지 혹은 삭제된 페이지입니다」 화면**으로 fallback.

### 3-2. 원인 — `get_editor_status_v2` RPC가 `paid_pages` 베이스 quota 별도 체크

| editor | pages | individual_url_count | RPC `paid_pages` | RPC `is_available` |
|---|---|---|---|---|
| 4739 시안 (8P) | 8 | None | 10 | true ✓ |
| 4681 TISSOT (4P) | 4 | None | 2 | true ✓ |
| **4764 초안 (19P)** | 19 | 19 (pay_individual_urls 후) | **0** | **false ❌** |
| 4637 빈 페이지 (2P) | 2 | None | 0 | false ❌ |

10페이지 이하는 base quota로 자동 통과. 11페이지 이상은 quota 활성화가 별도로 필요.

### 3-3. 시도해본 자동화 (모두 실패)

1. **`pay_individual_urls` RPC** → ✓ credit 차감 + `editor_admin_setting.individual_url_count` 증가, 그러나 `paid_pages`·`is_available`은 변화 없음. **`individual_url_count`와 `paid_pages`는 별개 컬럼**.
2. **`editor_admin_setting.expires_at` PATCH**로 `created_at + 2개월` 강제 set → status RPC는 여전히 `expires_at: null` 반환
3. **`/api/create-admin-setting`** Next.js API → `{success: true}` 응답이지만 quota 변화 없음 (신규 발견 API route이긴 함)
4. **5-call republish 시퀀스** (PATCH editor + PATCH editor_published + PATCH metadata + update-url-key + save_editor_version) → status 변화 없음
5. **slug 변경** (`prendang_2606_draft` → `prendang_2606d`) → 영향 없음

### 3-4. ⚠️ 비용 손실 (다음 자동화 시 반복 금지)

`pay_individual_urls` 호출로 **사용자 계정에서 19 credit 차감** 발생 (1 + 18). quota 활성화는 안 됨 → credit만 소모. **다음부터 호출 금지**.

### 3-5. 우회 패턴 (사용자 실측) — UI 복제

사용자가 cdbd.in UI에서 **에디터 4764 복제 → 4765 생성 + URL 발급** → 즉시 `paid_pages=19 · is_available=true` 활성화. 모든 카드/이미지가 그대로 따라옴.

**4764 → 4765 변화**:
- 자동화 직접 INSERT → UI 복제 흐름
- individual_url_count: 19 → None
- paid_pages: 0 → **19** ← 활성화
- expires_at: null → 2026-08-10
- is_available: false → **true** ✅

### 3-6. 신규 발견 RPC·API

- **`get_editor_status_v2(p_editor_id)`** RPC — SSR 게시 gate. 응답 `{is_available, is_banner, expires_at, paid_pages}`. **자동화 publish 후 반드시 호출하여 `is_available` 검증**, false면 추가 자동화 시도 금지·UI 위임.
- **`/api/create-admin-setting`** Next.js API — `editor_admin_setting` 초기화 (createPublished 흐름 `!r._5` 조건 호출). Body: `{userId, editorId}`.
- **신규 발견 테이블**: `editor_admin_setting` (paid quota 메타데이터: expires_at, restricted, url_key, is_first_free, individual_url_count), `editor_version` (save_editor_version 출력).

---

## 4. 문서·문서간 동기화

### 4-1. 갱신된 가이드 문서

- [[2-1. 공통]] — 「배경 늘림 보드」 신설 + 「풀샷 (Rule A) 상단:하단 ≈ 3:2 비율 계산」 갱신 + 결정 트리·빠른 참조 표 갱신
- [[2-4. 화보·상품]] — 03-BG 풀샷 마진 3:2 비율 갱신 + 배경 늘림 보드 참조
- [[1-4. CdBd 콘텐츠]] — paid_pages quota 경고 + 복제 우회 패턴 + `get_editor_status_v2` 진단 RPC + `/api/create-admin-setting` 발견
- [[CLAUDE.md]] — 「풀샷 3:2 비율」, 「배경 늘림 보드」, 「11P 이상 = UI 게시 필수, pay_individual_urls 금지」 3개 원칙 한 줄씩

### 4-2. 갱신된 인수인계 문서

- `~/Documents/Codex/cdbd-design-service/룩북/작업 기록/쁘렝땅-초안-수정-인수인계.md` — 「2026-06-10 추가 작업」 섹션 신설 (4764 자동화 실패 → 4765 UI 복제 우회 케이스, 비용 손실 경고, 다음 에이전트 주의사항)

---

## 5. 다음 에이전트 주의사항

### CdBd 등록 시 (특히 11P 이상)

1. **자동화 publish 4-call 직후 반드시 `get_editor_status_v2`로 `is_available` 검증**
2. `is_available=false`면 **즉시 자동화 중단**. `pay_individual_urls` 호출 금지 (credit만 소모)
3. **사용자에게 "cdbd.in UI에서 에디터 복제 → URL 생성" 위임**
4. 복제 후 새 editor_id로 PATCH/검증 재개 — 자산 URL·페이지 JSON 그대로 따라옴

### 가이드 적용 시

- **풀샷 화보 배치**: 픽셀값(40/20) 강제 X → 상단:하단 ≈ 3:2 비율 우선. 가용 마진에 맞춰 분배.
- **상하·좌우 동시 부족**: 임의 크롭 X → `배경 늘림 필요 이미지` 보드에 `BG-EXT-{name}-{방향}` 카드 추가 + 사용자 일괄 요청 → 완료 후 새 hash로 fill 교체.

### 19페이지 (매장 정보) 카드 패턴

- BG = 화보 이미지 (Figma에서 dim 베이크) `type=default`
- 로고 = **흰 워드마크** (`16027:15` 흰 로고 source, 50% width, padding `65px 20px 45px`)
- 「오프라인 매장 안내」 = **button 카드** (innerStyle bg `rgba(255,255,255,0.25)`, 흰 텍스트, bold, width 100%, buttonStyle 100/100), `linkButton.type=url`
- 버튼+SNS를 페이지 하단으로 보내려면 **버튼 style.margin = `260px 20px 0px`** (top 260 push down)
- SNS = homepage·instagram·kakaotalk 3채널 (다른 채널은 enabled=false)

### Figma 화보 frame 빈 여백 (y>0)

- 자식 RECT가 frame 상단보다 아래에서 시작하면 export PNG 상단에 **순백 픽셀 band**가 박힘 (frame 빈 영역이 화이트로 렌더)
- 해결: `use_figma`로 RECT y를 0으로 이동 + frame 외 overflow는 clipsContent로 잘림
- 후속: re-export → 라이브러리 재업로드 → editor 4765 갤러리 URL PATCH → version 갱신
- 사례: 08-swp2 `16087:27` y=2 → y=0 (2026-06-10)

---

## 6. 다음 미해결 작업

- [ ] 19페이지에 PPT MALL/INSTAGRAM/KAKAO CH 링크를 button 카드로 추가할지 결정 (현재 SNS 아이콘만 — 사용자 확인 대기)
- [ ] (선택) 19페이지 「오프라인 매장 안내」 버튼 style.margin top 값 미세 조정 (현재 260px — 사용자 시각 검토 후)
- [ ] (선택) `editor_admin_setting`·`editor_version` 테이블 schema·트리거 source 입수 시 `paid_pages` 활성화 로직 재시도 가능
- [ ] 이전 작업물(PRENDANG 4739) retroactive 등록 함수 — 결정 보류 상태 (위 「미해결·후속 작업」 참고)
