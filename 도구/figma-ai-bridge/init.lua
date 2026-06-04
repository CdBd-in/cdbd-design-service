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

-- Quick Actions(Cmd+/) 호출 → 검색어 입력 → Enter
local function runQuickAction(query)
  hs.eventtap.keyStroke({}, "escape"); sleepMs(50)   -- 잔재 패널 닫기
  hs.eventtap.keyStroke({ "cmd" }, "/"); sleepMs(180) -- 메뉴 열림 대기
  hs.eventtap.keyStrokes(query);        sleepMs(120) -- 필터 안정화
  hs.eventtap.keyStroke({}, "return")
end

----------------------------------------------------------------
-- 라우트 핸들러
----------------------------------------------------------------
local function handleHealth()
  return jsonOk({
    ok = true,
    figma_running = findFigma() ~= nil,
    version = VERSION,
  })
end

local function handleRemoveBg(body)
  if not activateFigma() then
    return jsonErr(409, "figma_not_running")
  end
  local timeout = (body and body.timeout_ms) or DEFAULT_REMOVE_BG_TIMEOUT_MS
  local t0 = nowMs()
  runQuickAction(REMOVE_BG_QUERY)
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
