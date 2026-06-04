-- figma-ai-bridge: Hammerspoon 데몬 (Figma AI 메뉴 액션 자동 트리거)
-- 스펙: docs/superpowers/specs/2026-06-04-figma-ai-bridge-design.md
-- 호출자: Claude(use_figma) → curl POST → 본 데몬 → Figma Quick Actions → AI 실행
--
-- 엔드포인트:
--   GET  /v1/health
--   POST /v1/remove-bg   body: { timeout_ms?: 5000 }
--   POST /v1/extend-bg   body: { prompt: string, timeout_ms?: 10000 }

----------------------------------------------------------------
-- 상수 (Figma 언어 설정에 따라 검색어 조정)
----------------------------------------------------------------
local PORT = 39632
local FIGMA_APP_NAME = "Figma"
local REMOVE_BG_QUERY = "remove background"
local EXTEND_BG_QUERY = "extend image"
local DEFAULT_REMOVE_BG_TIMEOUT_MS = 5000
local DEFAULT_EXTEND_BG_TIMEOUT_MS = 10000
local VERSION = "0.1"

local JSON_HEADERS = { ["Content-Type"] = "application/json" }

----------------------------------------------------------------
-- 유틸
----------------------------------------------------------------
local function jsonOk(tbl)
  return hs.json.encode(tbl), 200, JSON_HEADERS
end

local function jsonErr(status, errCode)
  return hs.json.encode({ ok = false, error = errCode }), status, JSON_HEADERS
end

local function nowMs()
  return hs.timer.secondsSinceEpoch() * 1000
end

local function sleepMs(ms)
  if ms and ms > 0 then
    hs.timer.usleep(ms * 1000)
  end
end

local function findFigma()
  return hs.application.find(FIGMA_APP_NAME)
end

local function activateFigma()
  local app = findFigma()
  if not app then return false end
  app:activate()
  sleepMs(200)
  return true
end

-- 영문 입력 소스 강제 (한국어 IME 등에서 query 글자가 한글로 변환되는 것 방지)
local function ensureEnglishInput()
  local layout = hs.keycodes.currentLayout()
  print(string.format("[figma-ai-bridge] current layout: %s", tostring(layout)))
  if layout ~= "ABC" and layout ~= "U.S." and layout ~= "US" then
    print("[figma-ai-bridge] switching to ABC layout")
    hs.keycodes.setLayout("ABC")
    sleepMs(150)
    return layout
  end
  return nil
end

local function restoreInputSource(prev)
  if prev then
    print(string.format("[figma-ai-bridge] restoring layout: %s", prev))
    hs.keycodes.setLayout(prev)
  end
end

-- AppleScript escape: " → \", \ → \\
local function escapeAS(s)
  return (s:gsub("\\", "\\\\"):gsub('"', '\\"'))
end

-- Quick Actions 호출 → 검색어 입력 → Enter
-- 방식: hs.application:selectMenuItem({"Figma", "Actions…"})로 메뉴 직접 호출
-- (Cmd+/ 키스트로크는 Figma까지 도달은 하지만 Actions 열기로 처리되지 않는 케이스 확인됨)
-- ⚠️ Escape는 Figma 선택을 해제하므로 절대 쓰지 않는다.
local function runQuickAction(query)
  local prev = ensureEnglishInput()
  local figma = findFigma()
  if not figma then return false, "figma_not_running" end
  figma:activate(); sleepMs(250)

  print("[figma-ai-bridge] selectMenuItem {Figma, Actions…}")
  local ok = figma:selectMenuItem({ "Figma", "Actions…" })
  if not ok then
    -- 폴백: 메뉴 path 변형 시도
    ok = figma:selectMenuItem({ "Figma", "Actions" })
    print(string.format("[figma-ai-bridge] fallback Actions (no ellipsis) → %s", tostring(ok)))
  end
  if not ok then
    print("[figma-ai-bridge] selectMenuItem FAILED")
    restoreInputSource(prev)
    return false, "actions_menu_not_found"
  end
  print("[figma-ai-bridge] menu invoked, waiting for search box focus")
  sleepMs(1200)  -- Quick Actions 패널 열림 + 검색창 포커스 대기 (보수적)

  -- 키스트로크는 hs.eventtap.keyStrokes 직접 사용 (현재 포커스된 요소로)
  -- AppleScript System Events 대신 native eventtap 사용 — IME는 이미 영문으로 전환
  print("[figma-ai-bridge] typing query via eventtap.keyStrokes: " .. query)
  hs.eventtap.keyStrokes(query); sleepMs(400)
  print("[figma-ai-bridge] sending Return via eventtap")
  hs.eventtap.keyStroke({}, "return")
  restoreInputSource(prev)
  return true
end

-- 디버그: Figma에 단순 문자열만 입력 (Cmd+/ 없음, Enter 없음)
local function typeTest(query)
  local prev = ensureEnglishInput()
  local q = escapeAS(query or "TEST")
  local script = string.format([[
    tell application "System Events"
      tell process "Figma"
        set frontmost to true
        delay 0.25
        keystroke "%s"
      end tell
    end tell
  ]], q)
  print("[figma-ai-bridge] typeTest via AppleScript, query=" .. q)
  hs.osascript.applescript(script)
  restoreInputSource(prev)
end

----------------------------------------------------------------
-- 라우트 핸들러
----------------------------------------------------------------
local function handleHealth()
  return jsonOk({
    ok = true,
    figma_running = findFigma() ~= nil,
    accessibility_granted = hs.accessibilityState(),
    version = VERSION,
  })
end

local function handleReload()
  hs.timer.doAfter(0.2, function() hs.reload() end)
  return jsonOk({ ok = true, reloading_in_ms = 200 })
end

local function handleRemoveBg(body)
  if not activateFigma() then
    return jsonErr(409, "figma_not_running")
  end
  local timeout = (body and body.timeout_ms) or DEFAULT_REMOVE_BG_TIMEOUT_MS
  local t0 = nowMs()
  local ok, err = runQuickAction(REMOVE_BG_QUERY)
  if not ok then
    return jsonErr(500, err or "quick_action_failed")
  end
  sleepMs(timeout)
  return jsonOk({ ok = true, elapsed_ms = math.floor(nowMs() - t0) })
end

local function handleExtendBg(body)
  if not body or type(body.prompt) ~= "string" or body.prompt == "" then
    return jsonErr(400, "invalid_body_prompt_required")
  end
  if not activateFigma() then
    return jsonErr(409, "figma_not_running")
  end
  local timeout = body.timeout_ms or DEFAULT_EXTEND_BG_TIMEOUT_MS
  local t0 = nowMs()
  runQuickAction(EXTEND_BG_QUERY)
  sleepMs(180)
  hs.eventtap.keyStrokes(body.prompt)
  sleepMs(120)
  hs.eventtap.keyStroke({}, "return")
  sleepMs(timeout)
  return jsonOk({ ok = true, elapsed_ms = math.floor(nowMs() - t0) })
end

----------------------------------------------------------------
-- HTTP 서버
----------------------------------------------------------------
local function dispatch(method, path, _, body)
  local parsed = nil
  if body and #body > 0 then
    local ok, decoded = pcall(hs.json.decode, body)
    if ok then parsed = decoded end
  end

  if method == "GET" and path == "/v1/health" then
    return handleHealth()
  elseif method == "POST" and path == "/v1/remove-bg" then
    return handleRemoveBg(parsed)
  elseif method == "POST" and path == "/v1/extend-bg" then
    return handleExtendBg(parsed)
  elseif method == "POST" and path == "/v1/reload" then
    return handleReload()
  elseif method == "POST" and path == "/v1/type-test" then
    local q = (parsed and parsed.text) or "TEST"
    typeTest(q)
    return jsonOk({ ok = true, typed = q })
  elseif method == "POST" and path == "/v1/open-console" then
    hs.openConsole()
    return jsonOk({ ok = true })
  elseif method == "POST" and path == "/v1/cmd-slash" then
    -- Cmd+/ ONLY (no typing, no Enter) — Quick Actions 단독 트리거 테스트
    local figma = findFigma()
    if not figma then return jsonErr(409, "figma_not_running") end
    figma:activate(); sleepMs(300)
    print("[figma-ai-bridge] /v1/cmd-slash: sending Cmd+/ via eventtap")
    hs.eventtap.keyStroke({ "cmd" }, "/")
    return jsonOk({ ok = true })
  elseif method == "POST" and path == "/v1/open-actions" then
    -- 메뉴만 열고 타이핑 없음 — Quick Actions가 진짜 뜨는지 시각 확인용
    local figma = findFigma()
    if not figma then return jsonErr(409, "figma_not_running") end
    figma:activate(); sleepMs(300)
    local ok = figma:selectMenuItem({ "Figma", "Actions…" })
    print(string.format("[figma-ai-bridge] /v1/open-actions selectMenuItem → %s", tostring(ok)))
    return jsonOk({ ok = true, menu_invoked = ok })
  elseif method == "POST" and path == "/v1/menu-dump" then
    -- Figma의 메뉴 트리를 덤프 → 통신 자체가 되는지 + 'Remove background' 메뉴 위치 확인
    local figma = findFigma()
    if not figma then return jsonErr(409, "figma_not_running") end
    local menu = figma:getMenuItems() or {}
    local function trim(items, depth)
      if depth <= 0 then return {} end
      local out = {}
      for _, it in ipairs(items) do
        local entry = { title = it.AXTitle or "" }
        if it.AXChildren and depth > 1 then
          entry.children = trim(it.AXChildren[1] or {}, depth - 1)
        end
        table.insert(out, entry)
      end
      return out
    end
    return jsonOk({ ok = true, menus = trim(menu, 2) })
  else
    return jsonErr(404, "not_found")
  end
end

-- 모듈을 재로드해도 포트가 점유되지 않도록 핸들을 전역에 보관
if _G._figmaBridgeServer then
  pcall(function() _G._figmaBridgeServer:stop() end)
end
local server = hs.httpserver.new(false, false)
server:setPort(PORT)
server:setInterface("127.0.0.1")
server:setCallback(dispatch)
server:start()
_G._figmaBridgeServer = server

hs.alert.show("figma-ai-bridge ready :" .. PORT)
print(string.format("[figma-ai-bridge v%s] listening on 127.0.0.1:%d", VERSION, PORT))
