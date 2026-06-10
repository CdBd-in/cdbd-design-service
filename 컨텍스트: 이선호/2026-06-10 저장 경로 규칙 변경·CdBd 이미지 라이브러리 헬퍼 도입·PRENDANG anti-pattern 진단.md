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

- [[룩북/1. 제작 프로세스/1-1. 공통.md]] — 저장 경로 규칙
- [[룩북/1. 제작 프로세스/1-4. CdBd 콘텐츠.md]] — 이미지 라이브러리 섹션 + 운영 체크리스트 + 🚨 PRENDANG 4739 anti-pattern 사례
- [[CLAUDE.md]] — 최상위 작업 원칙
- `~/.config/cdbd/auth.py` — Supabase access_token + Figma PAT 헬퍼
- `~/.config/cdbd/image_library.py` — 이미지 라이브러리 헬퍼 (오늘 신설)
- `./.gstack/browse-states/cdbd.json` — 브라우저 세션 state (오늘 신설)
