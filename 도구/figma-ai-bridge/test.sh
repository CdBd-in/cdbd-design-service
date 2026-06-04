#!/usr/bin/env bash
# figma-ai-bridge 스모크 테스트
# 실행 전 조건: Hammerspoon 실행 + init.lua 로드 + Figma 활성, 누끼 한 장 선택

set -uo pipefail

BASE="http://127.0.0.1:39632"

# pretty-print: jq 있으면 사용, 없으면 raw
pretty() {
  if command -v jq >/dev/null 2>&1; then jq .; else cat; fi
}

echo "▶ GET $BASE/v1/health"
curl -sS --connect-timeout 2 "$BASE/v1/health" | pretty
echo ""

echo "▶ POST $BASE/v1/remove-bg"
echo "  먼저 Figma에서 누끼 1장을 선택해 두세요. Enter 누르면 트리거합니다."
read -r _
curl -sS --connect-timeout 2 -X POST "$BASE/v1/remove-bg" \
  -H "Content-Type: application/json" \
  -d '{"timeout_ms":5000}' | pretty
echo ""

echo "스모크 테스트 종료. 선택한 노드의 배경이 제거되었는지 Figma에서 확인하세요."
