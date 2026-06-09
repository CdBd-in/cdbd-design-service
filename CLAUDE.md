# CLAUDE.md — CdBd 디자인 서비스 작업 규칙

이 저장소에서 작업할 때 항상 참고할 규칙과 기억입니다.

---

## 프로젝트 개요

CdBd 디자인 서비스는 CdBd 멀티페이지로 **룩북·카탈로그** 콘텐츠를 디자인하는 대행 서비스입니다.  
룩북은 반복되는 레이아웃 패턴이 많아, 이를 규칙으로 문서화하고 동일 패턴으로 **시안/초안**을 제작합니다.

- **시안**: 동일한 콘텐츠·구성요소로 **서로 다른 디자인 2안(A·B)**을 제시 → 각 4페이지(시안표지 + 01 + 02 + 03) = 총 8페이지
- **초안**: 시안에서 선택된 안을 기반으로 **전체 페이지** 완성

---

## 핵심 문서 (`룩북/`)

작업 전 반드시 해당 문서를 확인하고, 변경 시 함께 갱신합니다. 문서는 **작업 프로세스**(`1. 제작 프로세스/`)와 **디자인 가이드**(`2. 디자인 가이드/`)로 분리되어 있습니다.

**`룩북/1. 제작 프로세스/`** — 구성·파일명·내보내기·CdBd 콘텐츠 매핑 등 작업 프로세스
| 문서 | 내용 |
|------|------|
| `1. 제작 프로세스/1-공통.md` | 페이지 규격(380×580), OG 이미지, 해상도·파일 형식·파일명·저장위치 규칙 |
| `1. 제작 프로세스/2-시안.md` | 시안 프로세스 (A/B 2안 채택, 4×2=8페이지 구성, 시안 표지, 체크리스트) |
| `1. 제작 프로세스/3-초안.md` | 초안 프로세스 (전체 페이지 흐름·체크리스트, 디자인은 선택된 시안 승계) |
| `1. 제작 프로세스/4-CdBd 콘텐츠.md` | 내보내기 파일 ↔ CdBd 카드 매핑 (룩북 사용 카드 3종: 이미지·갤러리[나열하기/넘겨보기/그리드]·구분선) + 멀티페이지 구조·카드별 옵션 명세·페이지 유형별 속성 규칙 + **개발자/AI용 Supabase 직접 자동화**(백엔드 인프라·테이블/RPC·`editor.pages` PATCH·JSON 카드 spec·Figma REST API 자산 파이프라인·슬러그 언더바 규칙) |

**`룩북/2. 디자인 가이드/`** — 페이지 유형별 디자인 규칙
| 문서 | 내용 |
|------|------|
| `2. 디자인 가이드/1-공통.md` | 화보 비크롭, 기본 폰트(Pretendard), border radius, 01·02 핵심 원칙·공통 텍스트/로고 스펙 |
| `2. 디자인 가이드/2-표지.md` | 01 표지 + 표지 레이아웃 타입(thin/clean/thick frame, blur BG) |
| `2. 디자인 가이드/3-브랜드·컬렉션 소개.md` | 02 브랜드·시즌 소개(dim 오버레이, 02-A~D) + 표지 레이아웃 타입 |
| `2. 디자인 가이드/4-화보·상품.md` | 03 내지 (basic / swp / scl) |
| `2. 디자인 가이드/5-매장 정보.md` | 매장·연락처 페이지 (빈 골격, 추후 작성) |

| 기타 | 내용 |
|------|------|
| `룩북/참조 이미지/` | 레이아웃 레퍼런스 이미지 (`ref-*.png`) |

### 용어·체계 (혼동 주의)
- **파일명**: 시안 = `A`/`B`(시안표지)·`A01~A03`/`B01~B03`, 초안 = `01·02·03…`, OG = `og.jpg`
- **세부 구분**: `A02-1`(섹션), `A03-top/bottom`(고정 영역), `A04-btn/insta`(역할)
- **표지 레이아웃 타입**: `thin frame`(외곽선 있음) / `clean`(외곽선 없음) — 둘 다 화보 위 오버레이 / `thick frame`(화보를 두꺼운 여백 안에 배치, 로고는 여백에) — `thick frame`(01)과 `03-basic-frame`은 기본 세트
- **01**=각 시안의 표지, **02**=브랜드·시즌 소개, **03**=내지(basic / basic-frame)

### 레이아웃 핵심 원칙
- **⚠️ (가장 중요) 모든 화보 이미지는 절대 크롭하지 않는다.** 원본 비율을 유지한 채, **clip contents가 걸린 화보 프레임 안에서 위치(필요 시 크기)만 조정**해 노출 영역을 정한다. 이때 **모델 얼굴·상품 정보에 포함된 착장 상품 영역 등 중요한 부분이 잘리지 않도록** 위치를 맞춘다. Figma에서는 **이미지를 프레임에 맞춰 줄이는 scale-to-fill 크롭이 아니라, 원본 비율 그대로 두고 위치·배율만 조정**해 프레임 clip이 잘라내게 한다. **모델이 한쪽으로 심하게 치우친 컷이 아니면 모델이 노출 영역 정중앙(좌우·상하)에 오도록** 배치하고, **풀샷은 머리·발 모두 보이도록** 사이즈/위치 조정하되 **380×580 프레임에서 머리 위 여백 ≥ 40 / 발 아래 여백 ≥ 20** (= 모델 키 ≥ 520, 뷰포트의 약 90%; 마진은 정확히 2:1 분배가 기본 — 03-BG·표지·OG 등 풀샷 화보 페이지 공통), **blur BG는 BG 화보를 더 크게 확대**한다. (시안·초안 / 01·02·03 모든 화보 페이지 공통, 세부 결정 트리 [[2-1. 공통]] 「위치·사이즈 결정 트리」)
- **⚠️ 화보 이미지 = 별도 자식 RECTANGLE 레이어 (프레임 fill 금지)**: 모든 화보는 **frame.fills로 직접 적용하지 않고**, 별도 RECTANGLE 레이어로 만들어 부모 프레임에 `insertChild(0, rect)` (z-index 0, 가장 아래)로 추가한다. 부모 프레임 `clipsContent = true`. 자식 rect는 원본 비율(예: 442×580)로 만들어 프레임 외부로 overflow되면 clip되게 한다. **프레임 fill 패턴은 사이즈/위치 조정이 안 되어 imageTransform/CROP에 의존하는 anti-pattern이며 화보 비크롭 원칙 위반.** 상세: [[2-1. 공통]] 「화보 이미지 배치」.
- **01·02 레이아웃 결정 1순위 = 배경 화보의 여백**(모델 얼굴이 상단·양옆에서 떨어진 정도)로 로고·텍스트 위치 결정
- 로고와 텍스트는 **항상 동일 컬러**
- 02는 화보 위 `#000000` dim 오버레이 (기본 40%, 화보 밝기에 따라 조정)
- **누끼 그리드 통일감 (= 면적 정규화)**: 그리드 **단 수(2단/3단)와 무관하게, 각 셀 RECT의 가로×세로 면적 S가 페이지 내 모든 product 셀에서 비슷한 값**이 되도록 정규화한다(2단이라고 크고 3단이라고 작아지지 않게). **셀 RECT는 alpha bbox 크롭 후 비율 `a = bbox_w / bbox_h`를 그대로 따르고**(원본 비율 유지), 면적 S를 고정해 `w = √(S·a), h = √(S/a)`로 산정 — 시각 면적 균등 + 비율 원본 유지. 셀 가용 영역(텍스트 위 10px 갭) 초과 시 가장 제약 큰 셀에 맞춰 S를 페이지 단위로 다시 잡는다. **같은 행 상품끼리는 상하 중앙 정렬**, **2단(2개) 행은 상품 간 간격을 더 넓게** 둔다. 전체 상품 크기는 카드 여백이 답답하지 않게 **과하지 않은 크기**로. **같은 라인 상품을 한 행에 배치할 때 = 좌측 상의(top), 우측 하의(bottom) 순서 고정** (예: Jacket 좌 + Pants 우, Cropped Jkt 좌 + Cotton Short 우). **3개 셀 라인(상의+하의+악세사리)** = **좌부터 상의 → 하의 → 악세사리** 고정 (예: Crochet Floral Mini Top 좌 + Crochet floral mini short 중 + Crochet hair accessory 우). ⚠️ **anti-pattern**: 셀 RECT가 일률 사이즈/임의 비율인 것 → alpha 크롭 비율과 어긋나 상품이 가로/세로로 늘어남(원본 비율 손실). 셀별로 비율을 다시 계산해야 함.
- **swp 페이지 = 최소 2행 (1행 페이지 금지)**: 모든 swp(스와이프) 페이지는 **반드시 2행 이상**으로 배치한다. 1행만 채워 빈 영역이 크게 남는 페이지는 만들지 않는다(과금 단위라 비효율 + 시각적 균형 깨짐). 상품 수가 적어 1행만 나오면 다른 페이지와 통합하거나 행을 추가한다.
- **swp 페이지 2행 그리드 = 카드 내 vertical center (오토레이아웃) + 행간 40**: swp 페이지에 **정확히 2행**만 배치되는 경우, **카드 자체를 세로 auto-layout** + `primaryAxisAlignItems = "CENTER"`로 설정해 행을 카드 안에서 **수직 중앙 정렬**한다 (가이드 노드 `16615:330`). 각 행은 가로 auto-layout(itemSpacing 0, counterAxisAlignItems CENTER)으로 래핑. **2행일 때 행간은 40으로 키운다** (3행 이상은 swp 유형 기본 행간 사용 — `clean` 18 / `blur` 24). 카드 패딩은 유형별 규격(`clean` 상20·좌우20·하18 / `blur` 상22·좌우20·하24)을 따른다. ⚠️ auto-layout 적용 후 카드 사이즈가 hug로 줄면 `resize(340, 501)` 등으로 명시적으로 다시 고정한다.
- **swp 그리드 = 균등 컬럼 분배** (가이드 노드 `16089:991`): 한 행은 **사용 폭(약 300)을 상품 수만큼 등분한 균등 컬럼**에 배치하고 각 상품을 **컬럼 중앙(좌우·상하)**에 둔다 — **가운데로 몰지 말고 행 전체 폭에 고르게 분배**(3개→3등분 / 1개→풀폭 중앙 / 2개→2등분). **셀 높이·행 간격은 일정**(이미지 밴드 + 하단 라벨 밴드). 프레임 색상 코드: 3단=`#ECECEC`·1단=`#D9D9D9`·2단=`#AFAFAF`. **swp는 3유형** — `clean BG`(BG 위 카드 **340×501**, 콘텐츠 300, 셀 100/150/300) · `full`(풀페이지 **380×580**+상단 로고, 콘텐츠 340, 셀 113.3/170/340) · `blur BG`(380×580 + 내부 카드 **340×520**, 콘텐츠 300, 셀 100/150/300). 모두 **셀 높이 142 고정·행 균등분할**. scl은 `frame-grid2/3`·`full-grid`·`blur-grid`·`row` 유형. 상세·오토레이아웃·노드ID는 [[2-4. 화보·상품]] (전체 타입 라이브러리 보드 `16100:1759`).
- **swp 셀 구조 = 절대 좌표 + 텍스트 wrapper만 auto-layout**: 셀 자체는 **`layoutMode = "NONE"`** (절대 좌표). 자식 2개: ① 이미지 RECTANGLE (절대 좌표, 셀 가용 영역 상하·좌우 중앙) ② **텍스트 wrapper FRAME** = name + price 2개만 묶은 VERTICAL hug auto-layout (`primaryAxis = MAX`, `counterAxis = CENTER`, itemSpacing 0, padding 0). wrapper도 절대 좌표로 셀 하단·좌우 중앙에 anchor (`x = (cell.w - wrapper.w) / 2`, `y = cell.h - wrapper.h`). ⚠️ **셀에 auto-layout 걸면 안 됨** — 상품마다 이미지 높이가 달라서 같은 행 안에서 상하 중앙 정렬을 **수동 조정**해야 하기 때문(이미지 RECT를 자유롭게 드래그 가능해야 함). **이미지 rect 기본 위치**: `x = (cell.w - rect.w) / 2`, `y = ((wrapper.y - 10) - rect.h) / 2` (가용 영역 = 셀 상단 ~ wrapper.y − 10, 그 안 상하 중앙). 같은 행 셀들의 wrapper.h가 동일하면(2행 텍스트 시 항상 h=39) 가용 영역도 동일 → 자동으로 행 단위 vertical-center 정렬. 사용자는 필요 시 image rect의 y를 수동 미세조정.
- **swp 셀 배치·상품명 줄바꿈**: 상품명 **1행 폭이 줄바꿈 임계값을 초과하면 2행** — **임계값은 단 수별로 다름: 1·2단 = 120px, 3단 = 90px**. **⚠️ 같은 행은 「렌더 라인 수」가 같아야 한다** — 한 셀이 2행이면 같은 행의 모든 셀이 시각적으로 2행이어야 한다 (프레임 height만 26으로 맞추는 것으로는 부족, **실제 렌더 라인 수가 일치**해야 함). **동일 상품 다색상은 1행 고정**. 줄바꿈은 **「상품특징」 / 「사이즈·카테고리」** 로 끊되, **`with` 같은 접속사가 포함되면 그 앞에서 끊는다** (자연스러운 끊기 = "Suit jacket / with brooch", "Striped Knit Top / With Boat Neck", "Suit / trousers", "Cotton skirt / shorts"). ⚠️ **swp 상품명은 모두 CAPS (textCase = "UPPER")** — 가격은 영향 없음(₩+숫자). **자동화 구현 (행 단위 라인 수 일치)**: ① row 내 셀 수로 임계값 결정 (`cells.length >= 3 ? 90 : 120`) → 상품명 텍스트 박스 width = 임계값 고정. ② 렌더 폭 > 임계값인 상품명은 Figma가 자동으로 2행 wrap (needs2Lines). ③ **row 내 셀이 하나라도 needs2Lines면 같은 row의 짧은(자동 wrap 안 되는) 셀에도 `characters`에 `\n`을 명시 삽입해 강제 2행** (예: "Suit trousers" → "Suit\ntrousers", "Cotton skirt shorts" → "Cotton skirt\nshorts", "Linen Blended Short" → "Linen Blended\nShort"). 「상품특징/카테고리」 경계 우선, 단어 2개뿐이면 단일 공백에서 끊기. ④ **`with` 등 접속사 포함 + needs2Lines 셀은 자동 wrap에 맡기지 말고 `characters`에 `\n`을 명시 삽입** (정규식 `/(\s+)(with\b)/gi` → `\n$2`). ⑤ 행 단위 frame 통일을 위해 needs2Lines row의 모든 셀 텍스트 박스에 `textAutoResize = "NONE"`, `height = 26`, `textAlignVertical = "BOTTOM"` 적용. ⑥ 적용 후 가용 이미지 영역(= name.y − 10) 재계산 + image rect 재정렬.
- **그리드 행 구성 순서**: 엑셀/전달 순서를 그대로 따를 필요 없음. **1·2·3개처럼 단조 증가하는 행 배열은 시각적 균형을 위해 2·1·3 등으로 재배열**한 뒤 사용자에게 알린다.
- **03 swp BG 서브타이틀 = 컬렉션명**(예: `26 SS Collection`).
- **배경 가공만 Figma AI를 사용**한다 — **배경 삭제(`Remove background`) · 배경 늘림(확장/생성형 fill)** 등. 로컬 rembg/BiRefNet 등 외부 ML은 쓰지 않는다. ⚠️ Figma AI는 **에디터 전용**이라 자동화 API(`use_figma`)로 호출 불가(`createImage`/`getImageByHash`만 존재) → 에디터에서 적용(필요 시 사용자에게 요청)한 결과로 진행.
- **로고·누끼 이미지 처리**: 로고와 상품 누끼는 둘 다 **「배경 제거 + 여백 없이 + 원본 비율」**로 사용. 배경이 있으면 Figma AI(Remove background)를 **사용자에게 요청**(에디터 전용). **이미 배경이 없는 경우(SVG · 투명 PNG 등)는 요청하지 않고 그대로 사용** — 업로드 직후 alpha 채널 유무를 먼저 확인. 적용 범위: 시안·초안 모든 페이지(01·02·표지·OG·03 swp/scl) 공통. 상세: [[2-1. 공통]] 「로고·누끼 이미지 처리」.
- ⚠️ **누끼 alpha bbox 크롭은 swp/scl 빌드의 필수 사전 단계**: Remove background만으로는 캔버스 크기가 유지되어 PNG에 alpha=0 여백이 남는다. **PIL `getbbox()` + `crop()`으로 잘라낸 PNG를 재업로드해 fill 교체**해야 cell 내 상품 면적이 균등해진다. 워크플로우 5단계(export→getbbox→crop→re-upload→fill swap) + RECT 동일 면적 공식(w=√(S·a), h=√(S/a)) 상세는 [[2-4. 화보·상품]] 「공통 — 상품 누끼 alpha bbox 크롭」 / [[2-1. 공통]] 「로고·누끼 이미지 처리」.
- **그 외 가공(리사이즈·위치 조정·scaleMode·imageTransform·crop 등)은 기존대로 `use_figma`로 처리**한다 (AI 아님).
- 정확한 픽셀값보다 **범용 비율·여백**으로 기재 (로고 규격은 브랜드마다 다름)

---

## Figma 작업 규칙

- **파일 key**: `SI36czRu3lBgkPzyrnPYkB`
- `use_figma` 호출 **전 반드시 `figma:figma-use` 스킬을 로드**한다.
- 텍스트 편집 시 canonical recipe 준수: 현재 폰트 로드(`getStyledTextSegments`→`loadFontAsync`) → `await` → 변경 → 변경된 노드 ID 반환.
- 쓰기 작업 후 `screenshot()` 또는 `get_screenshot`으로 결과 검증.

### 🔤 폰트 규칙 (중요)

- **기본 폰트는 Pretendard.** 별도 요청이 없으면 Pretendard를 사용한다.
- **로컬 설치 폰트(`~/Library/Fonts` 등)는 MCP 작업 환경에서 인식되지 않는다.** Figma 데스크톱 화면에는 보여도 자동화로는 로드 불가.
- **MCP 환경에서 로드 가능한 폰트 = Figma 내장 Google Fonts + 팀 "Your uploaded fonts"에 업로드된 폰트.**
- **➡️ 사용자가 Pretendard가 아닌 다른 폰트로 변경을 요청하면:**
  1. 먼저 `listAvailableFontsAsync`로 해당 폰트의 사용 가능 여부·정확한 스타일명을 확인한다.
  2. 목록에 없으면, **"해당 폰트를 Figma 팀의 'Your uploaded fonts'에 업로드해 주세요"**라고 안내한다. (지금 Pretendard를 적용한 것과 동일한 방법 — 업로드하면 즉시 인식됨)
  3. 업로드 확인 후, 다시 가용성을 확인하고 적용한다.
- 텍스트의 현재 폰트를 로드할 수 없으면(로컬 폰트로 디자인된 경우) **내용 변경조차 막히므로**, 폰트 업로드가 선행되어야 한다.

### 📐 스와이프(swp) 페이지 제작 (과금 주의)

- **스와이프 페이지 수는 과금 기준에 포함된다.**
- swp(03 스와이프) 페이지를 만들 때는, 확인한 리소스(상품 이미지)로 **제품 개수를 먼저 파악**한 뒤, **사용자에게 "몇 페이지로 나눌지" 반드시 확인**하고 진행한다.

---

## 작업 원칙

- **시안 제작 요청 시, 반드시 [[룩북/1. 제작 프로세스/1-2. 시안.md]] 「제작 단계 (Step by Step)」 8단계를 그대로 따른다.** 핵심은 ⑤단계의 **누끼컷 × URL 매트릭스**로 03 페이지 유형(basic / swp · scl × 버튼·마커 유무)이 한 번에 결정된다는 점이며, 이후 ⑥·⑦단계는 ⑤의 결과를 그대로 따른다(누끼 유무 재판단 없음). 02 생략 분기, BG 페이지 누락 방지, 「최종 검증 (완료 보고 전)」 체크리스트를 빠짐없이 확인한 뒤 사용자에게 완료 보고한다.
- **CdBd 콘텐츠 등록 요청 시**(예: "(시안/초안) 이미지 CdBd 콘텐츠로 만들어줘", "CdBd 페이지 만들어줘", "CdBd에 올려줘"), **반드시 [[룩북/1. 제작 프로세스/1-4. CdBd 콘텐츠.md]] 「CdBd 등록 워크플로우」 7단계를 그대로 따른다.** 핵심: ① `~/Desktop/{브랜드명}/시안 or 초안/` 폴더의 파일을 확인 → ② 브랜드 영문명·컬렉션명은 `[문서]`(엑셀·PPT)에서 우선 확인, 없으면 사용자에게 묻기 → ③ GStack 브라우저로 `cdbd.in` 로그인 → ④ 멀티페이지 380×580 생성 → ⑤ 「페이지 유형별 카드 매핑」 표대로 페이지·카드 등록(`03-BG`는 페이지 사이드바 케밥 → 페이지 배경 설정, 03-row 구분선은 `#292929`·두께 1·투명도 20%·실선, `03-logo` 비고정) → ⑥ URL 정보 편집(**시안 슬러그=`{브랜드영문}_{YYMM}` 자동 — 언더바만 허용·초안 슬러그=문서 확인 후 없으면 사용자 확인** / OG 썸네일=`og.jpg` / 제목=브랜드영문 / 설명=컬렉션명) → ⑦ **게시 직전 사용자에게 반드시 확인** 후 게시 → URL·페이지 수·종류 보고. **시안·초안 같은 워크플로우** (폴더 경로·파일 패턴·슬러그 규칙만 분기).
- **⚠️⚠️ (최상위) CdBd 자동화 = 「디자인 보드 메뉴 1:1 매핑 키」만 사용 — 사용자 수동 수정 보장**: 모든 PATCH는 **CdBd 에디터 「디자인 보드 → 디자인」 메뉴에 실제로 존재하는 옵션과 1:1 대응되는 키**만 변경한다. 사용자가 추후 UI에서 동일 값을 보고 수정할 수 있어야 한다. ⛔ **금지 패턴**:
  - 같은 효과 노리고 후보 키를 한꺼번에 set하는 **shotgun** (예: `fixed`/`pinned`/`sticky`/`isFixed`/`position`/`fixedPosition` 동시 true)
  - UI 메뉴에 없는 임의 키·플래그 추가 (`alignment`/`horizontalAlign`/`alignSelf`/`justifySelf` 시도 등)
  - 표준 매핑 키를 우회한 데이터 직접 수정 (예: `link.href` 대신 `linkButton` — 이미 별도 규칙)
  ✅ **허용**: [[룩북/1. 제작 프로세스/1-4. CdBd 콘텐츠.md]] 「카드별 디자인 보드 메뉴 → JSON 키 매핑」 표에서 **「UI 옵션 ↔ JSON 키」 1:1 대응이 검증된 키만**. 검증 안 된 키 필요 시: UI에서 직접 임의 값 입력 → editor GET → diff로 키 확인 → 매핑 표 갱신 후 사용. 매핑 키 정확히 모를 때는 임의 키 박지 말고 **사용자에게 「UI 어느 메뉴로 변경하면 되나요?」 묻기**.
- **CdBd 자동화(Supabase 직접 호출) 사용 가능**: UI 자동화(React PointerEvent·dropzone·file picker)는 비효율 → **[[룩북/1. 제작 프로세스/1-4. CdBd 콘텐츠.md]] 「Supabase 직접 자동화」의 Supabase 직접 호출**이 우월. Figma REST API(PAT)로 3배 PNG 다운로드 → Supabase Storage POST → `editor.pages` PATCH → **게시 4-call** (1) `editor_published` UPSERT (snapshot) → (2) `editor_published_metadata` `is_active=true` PATCH → (3) **`POST https://www.cdbd.in/api/update-url-key`** body `{editor_id, user_id, url_key}` (Next.js API route — `editor_url` INSERT RLS 우회) → (4) rpc `save_editor_version` `{p_editor_id}`. **`use_figma.exportAsync`는 base64 응답 truncation 한계 있음** → 3배 export는 Figma REST API 사용. **`style.margin`은 3-value shorthand("상 좌우 하")만 작동**(UI 입력 형식과 동일·4-value·개별 키는 UI 비입력). **outline 버튼·테두리는 카드 디자인 키**(`style.borderWidth`/`borderColor`/`borderStyle`/`borderRadius`)로, innerStyle이 아닌 카드 자체 style. **작은 요소 가운데 정렬은 카드 width 100% + padding LR 계산값**. 슬러그 언더바 필수(`-` 불가). ⚠️ 이전 표기 `extend_published_url_v2` RPC는 schema cache에 존재하지 않음 (chunk 5784 실측 — 2026-06-09). **⚠️ 「하단 고정」·정렬 후보 등 UI 매핑 키 미검증 옵션은 shotgun 금지 — 위 최상위 규칙대로 사용자에게 묻기 또는 UI diff로 검증 후 사용.**
- **⚠️ CdBd 자동화 진입 시 인증 헬퍼 자동 사용**: 매번 사용자에게 token 요청하지 말 것. **`~/.config/cdbd/auth.py`의 `get_credentials()`** 함수가 figma_pat + 최신 access_token(refresh_token으로 자동 발급) + user_id를 한 번에 반환한다. 사용 패턴: `import sys, os; sys.path.insert(0, os.path.expanduser('~/.config/cdbd')); from auth import get_credentials; creds = get_credentials()`. credentials.json 없거나 refresh 실패 시에만 사용자에게 안내 (cdbd.in 재로그인 후 refresh_token 재추출). **Supabase access_token은 1시간 만료지만 refresh_token으로 자동 갱신되므로 사용자 알림 불필요**. Figma PAT 90일 만료만 사용자에게 미리 알릴 것.
- **⚠️ CdBd 자동화 PATCH 전 에디터 close 필수**: 사용자가 `https://cdbd.in/editor/{id}` 탭을 열어둔 상태에서 `editor.pages` PATCH하면 에디터 client-side state(빈/이전 pages)가 다음 `save_editor_version` 자동저장에서 **우리 PATCH를 덮어쓴다**(`updated_at`이 PATCH 시점보다 늦어짐 = 덮어쓰기 확정). **PATCH 전 사용자에게 에디터 탭 close 요청 → close 확인 응답 받기 → editor + editor_published 둘 다 PATCH → 사용자 새 탭 검증**. 단순 새로고침은 부족 — 완전 close해야 client state가 비워진다. 상세: [[룩북/1. 제작 프로세스/1-4. CdBd 콘텐츠.md]] 「에디터 열린 상태 PATCH = race condition」.
- **⚠️ CdBd 「링크 연결」 = `linkButton` 키 (NOT `link`)**: UI 「디자인 보드 → 디자인 → 링크 연결」 메뉴가 저장하는 표준 키는 **`linkButton`** (block 또는 multiCard.items 안). `link.href`만 넣으면 데이터에는 들어가지만 UI 메뉴 비어 보이고 뷰어 클릭 무반응. 전화=`{type:"call", phone:{phone:"숫자만, 하이픈X"}}`, URL=`{type:"url", link:{href, openNewTab}}`. 상세: [[룩북/1. 제작 프로세스/1-4. CdBd 콘텐츠.md]] 「「링크 연결」 = `linkButton` 키」.
- **⚠️ CdBd 텍스트 카드 = Figma 「시각 결과」 입력 (characters 그대로 X)**: Figma 텍스트의 `textCase` 속성(UPPER/LOWER/TITLE)으로 디자인 시 변환되어 보여도 `characters`엔 원본이 남는다. CdBd 텍스트 카드는 textCase 옵션 없으므로 **변환된 결과를 직접 text에 입력**한다. 예: Figma `characters="store information"` + `textCase=UPPER` → CdBd text = `"STORE INFORMATION"`. 같은 원리로 fontWeight/italic도 lexical AST format 비트로 반영. 상세: [[룩북/1. 제작 프로세스/1-4. CdBd 콘텐츠.md]] 「Figma 시각 결과 → 카드 데이터 변환」.
- **⚠️ CdBd 등록 게시 전 「6.5 최종 검증」 단계 필수**: 모든 등록 워크플로우는 게시 직전에 [[룩북/1. 제작 프로세스/1-4. CdBd 콘텐츠.md]] 「6.5. 최종 검증 체크리스트」를 자동화로 통과해야 한다. 핵심: ① 페이지 수·순서 일치 ② 카드 시퀀스 일치 ③ **페이지별 로고/헤더 면적 = Figma 측정값** (`(Figma_width / 380) × 100 %` 정확 환산 — 예: 68px → 18%, 슬라이더 기본값 20% 의존 금지) ④ 누락/잘못 추가된 로고 없음 ⑤ 구분선·여백·버튼 height·링크 연결·텍스트 시각 결과 일치 ⑥ 에디터 close. 검증 절차: Figma `get_metadata` → CdBd editor GET → 비교 → 어긋나면 PATCH 정정.
- **⚠️ CdBd 버튼 height 조정 = 디자인 보드 「크기 → 세로」 (= `innerStyle.padding` 세로값)**: 사용자가 "CdBd 버튼 height/높이"를 언급하면 **항상 버튼 카드의 디자인 보드 메뉴 → 크기 → 세로** 값(= `innerStyle.padding`의 세로값)을 조정해 맞춘다. 자동화에서는 `block.innerStyle.padding = "{세로}px {가로}px"` (3-value shorthand 안 됨, 2-value만). 예: `padding: "12px 15px"` → 세로 12 / 가로 15. **width·border-radius·border-color 등 다른 속성은 건드리지 않는다.** Figma 버튼 높이 계산: `세로 padding = (Figma_height − text_height) / 2` (예: Figma 45 / text 13×1.6=20.8 → (45−20.8)/2 ≈ 12px). 가로(`스타일 → 안쪽 좌우 여백`)는 별도 요청 시에만 조정.
- **⚠️ 누끼 가공은 블록(blocking) 단계** (시안·초안 공통): ⑤에서 swp/scl을 채택하면, **swp/scl product 셀을 빌드하기 전에 반드시** 누끼를 **별도 위치**(작업 section 인접 임시 공간)에 먼저 업로드 → alpha 채널 선확인 → 사용자에게 Figma AI Remove background 요청 → **「가공 완료」 신호 대기** → 완료 후 셀 빌드. 가공 전 원본 누끼를 product 셀에 박지 않는다(hash 자동 교체 누락·셀별 개별 처리 anti-pattern). 다른 페이지(01·02·시안 표지·OG·03-BG 등 누끼와 무관)는 병렬 진행 가능. 상세 절차: [[룩북/1. 제작 프로세스/1-2. 시안.md]] Step 6.
- **⚠️ 엑셀 상품명 데이터 — `-`(대시) 포함 시 사용자 확인 필수**: 엑셀(또는 디자인 의뢰서)에서 상품명을 가져올 때 **`-` 문자가 포함된 부분이 있으면 절대 자동 결정하지 말고 사용자에게 「이 부분 생략할까요?」 물어본다**. 패턴:
  - **색상 접미사** (예: `Linen Blended Suit Jacket - Beige`, `Open shouldered top - White`): 보통 생략 (동일 제품 색상 변형은 라벨 1번만 표시·색 다르게 보이게 둠 — [[2-4. 화보·상품]] 「같은 라인 안 셀 순서」)
  - **사이즈 접미사** (예: `Mini Skirt - 36`): 보통 생략
  - **하이픈 단어** (예: `Short-sleeved cropped jacket`): 보통 유지 (단어 일부)
  - **사용자가 「생략」 결정 시 자동화 정규식**: `/\s+-\s*\w+\s*$/`로 trailing 색상/사이즈 패턴만 제거. `Short-sleeved` 같이 whitespace 없이 mid-word에 있는 `-`는 매치되지 않으므로 안전.
  - **예외 없이 항상 묻는다** — 같은 엑셀에서 처음 한 번만 묻고 같은 결정으로 일괄 적용.
- 새 기능·문서·규칙을 만들기 전, 관련 문서를 먼저 확인하고 일관성을 유지한다.
- **프로세스 규칙은 `1. 제작 프로세스/`, 디자인 규칙은 `2. 디자인 가이드/`에 둔다.** 규칙을 변경하면 두 폴더 문서 간 충돌·위계·용어 일치를 점검한다.
- 문서·폴더명은 국문, 파일명에 날짜·`-규칙` suffix는 사용하지 않는다.
