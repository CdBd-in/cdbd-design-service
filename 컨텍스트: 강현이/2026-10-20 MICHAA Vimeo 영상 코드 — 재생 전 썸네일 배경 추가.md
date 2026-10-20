---
title: 2026-10-20 MICHAA Vimeo 영상 코드 — 재생 전 썸네일 배경 추가
date: 2026-10-20
project: design
type: context
tags: [vimeo, 영상카드, 코드카드, 썸네일, MICHAA]
related:
  - "[[CdBd 기능 사전 (공통)]]"
---

# Vimeo 영상 코드 — 재생 전 썸네일 보이게 수정 (2026-10-20)

> 📝 브랜드 표기 `MICHAA`는 영상 title(`MICHAA_SHK_…`)에서 그대로 가져왔다.

## 1. 요청

- 이전 영상(OCT, `1229043148`) 코드는 영상이 시작되기 전에 **썸네일이 보였다**.
- 이번 영상(NOV_DEC, `1237489974`) 코드에는 썸네일 배경이 없다. → **이번에도 재생 전에 썸네일이 보이게** 해 달라.

## 2. 원리 — 썸네일이 보이는 이유

- 바깥 `div`의 `background`에 **Vimeo 썸네일 이미지(`i.vimeocdn.com/video/…`)를 cover로** 깔아 둔다.
- iframe에 `transparent=1`을 넣어 플레이어 배경을 투명하게 둔다. → 영상이 로드되기 전까지 뒤의 썸네일이 보인다.
- 썸네일 주소는 영상마다 다르다. **oEmbed API**로 받는다:

```bash
curl -s "https://vimeo.com/api/oembed.json?url=https://vimeo.com/{영상ID}&width=960"
# → 응답의 "thumbnail_url" 값을 사용 (예: …-d_960?region=us)
```

## 3. 이전 코드 vs 이번 코드 (원본)

**이전 (OCT · 썸네일 있음)**
```html
<div style="padding:162.04% 0 0 0;position:relative;background:#000 url('https://i.vimeocdn.com/video/2203602715-8cc894069a1a2704a9cffac725d5fa4f16b0d335c758c8c3c6c23b3c854d49a0-d_960?region=us') center/cover no-repeat;">
  <iframe src="https://player.vimeo.com/video/1229043148?badge=0&amp;autopause=0&amp;player_id=0&amp;app_id=58479&amp;autoplay=1&amp;muted=1&amp;playsinline=1&amp;transparent=1"
    frameborder="0"
    allow="autoplay; fullscreen; picture-in-picture; clipboard-write; encrypted-media; web-share"
    referrerpolicy="strict-origin-when-cross-origin"
    style="position:absolute;top:0;left:0;width:100%;height:100%;"
    title="MICHAA_SHK_OCT_9-16_0911_01"></iframe>
</div>
<script src="https://player.vimeo.com/api/player.js"></script>
```

**이번 (NOV_DEC · 받은 그대로 · 썸네일 없음)**
```html
<div style="padding:162.04% 0 0 0;position:relative;"><iframe src="https://player.vimeo.com/video/1237489974?badge=0&amp;autopause=0&amp;player_id=0&amp;app_id=58479&amp;autoplay=1&amp;muted=1&amp;loop=1" frameborder="0" allow="autoplay; fullscreen; picture-in-picture; clipboard-write; encrypted-media; web-share" referrerpolicy="strict-origin-when-cross-origin" style="position:absolute;top:0;left:0;width:100%;height:100%;" title="MICHAA_SHK_NOV_DEC_9_16_0929_01"></iframe></div><script src="https://player.vimeo.com/api/player.js"></script>
```

## 4. ✅ 수정본 (최종 전달)

```html
<div style="padding:162.04% 0 0 0;position:relative;background:#000 url('https://i.vimeocdn.com/video/2214276346-8d1b61a7cd12ccda7c9fdc78ee7f6a371a7b45ee7f0db828356f2708ce11fa44-d_960?region=us') center/cover no-repeat;">
  <iframe src="https://player.vimeo.com/video/1237489974?badge=0&amp;autopause=0&amp;player_id=0&amp;app_id=58479&amp;autoplay=1&amp;muted=1&amp;loop=1&amp;playsinline=1&amp;transparent=1"
    frameborder="0"
    allow="autoplay; fullscreen; picture-in-picture; clipboard-write; encrypted-media; web-share"
    referrerpolicy="strict-origin-when-cross-origin"
    style="position:absolute;top:0;left:0;width:100%;height:100%;"
    title="MICHAA_SHK_NOV_DEC_9_16_0929_01"></iframe>
</div>
<script src="https://player.vimeo.com/api/player.js"></script>
```

**변경점**
- 바깥 `div`에 썸네일 배경 추가 — `background:#000 url('{thumbnail_url}') center/cover no-repeat;`
- iframe 파라미터에 이전 코드의 `playsinline=1`(iOS에서 페이지 안 자동재생) · `transparent=1`(투명 플레이어 → 썸네일 노출)을 다시 넣었다.
- 이번 코드에 새로 들어온 `loop=1`(반복 재생)은 유지했다.

## 5. 참고

- 두 영상 모두 960×1556(세로형 9:16 근사) · 22초 → 비율 `padding:162.04%`는 그대로 쓴다.
- `<script src="…/player.js">`는 **CdBd 게시본에서 실행되지 않는다**(판정 164). 넣어 둬도 무해하고 이전 코드와 형식을 맞추려고 남겨 뒀다.
- 다음 달 영상이 오면 → **§2의 oEmbed로 `thumbnail_url`만 받아** §4 템플릿의 영상 ID · 썸네일 URL · title 3곳을 바꾸면 된다.
