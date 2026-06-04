#!/usr/bin/env bash
# figma-ai-bridge 설치 스크립트
# ~/.hammerspoon/init.lua 를 이 레포의 init.lua 로 심볼릭 링크한다.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE="$SCRIPT_DIR/init.lua"
TARGET_DIR="$HOME/.hammerspoon"
TARGET="$TARGET_DIR/init.lua"

red()    { printf "\033[31m%s\033[0m\n" "$1"; }
green()  { printf "\033[32m%s\033[0m\n" "$1"; }
yellow() { printf "\033[33m%s\033[0m\n" "$1"; }

echo "▶ figma-ai-bridge 설치"
echo "  source: $SOURCE"
echo "  target: $TARGET"
echo ""

# 1) Hammerspoon 설치 여부
if [ ! -d "/Applications/Hammerspoon.app" ]; then
  red "❌ Hammerspoon 미설치"
  echo ""
  echo "다음 중 하나로 설치 후 다시 실행하세요:"
  echo "  - GitHub 릴리스: https://github.com/Hammerspoon/hammerspoon/releases"
  echo "  - Homebrew:      brew install --cask hammerspoon"
  exit 1
fi
green "✅ Hammerspoon 확인됨"

# 2) ~/.hammerspoon 생성
mkdir -p "$TARGET_DIR"

# 3) 기존 init.lua 백업 (심볼릭 링크가 아니면)
if [ -e "$TARGET" ] && [ ! -L "$TARGET" ]; then
  BACKUP="$TARGET.backup-$(date +%Y%m%d-%H%M%S)"
  yellow "⚠ 기존 init.lua 발견 → 백업: $BACKUP"
  mv "$TARGET" "$BACKUP"
elif [ -L "$TARGET" ]; then
  # 이미 심볼릭 링크면 덮어쓰기 OK
  rm "$TARGET"
fi

# 4) 심볼릭 링크
ln -s "$SOURCE" "$TARGET"
green "✅ 심볼릭 링크 생성"

# 5) 후속 안내
echo ""
echo "다음 단계:"
echo "  1. Hammerspoon 실행:    open -a Hammerspoon"
echo "  2. 메뉴바 아이콘 클릭 → Reload Config"
echo "  3. Accessibility 권한 부여:"
echo "     System Settings → Privacy & Security → Accessibility → Hammerspoon ✓"
echo "     (Hammerspoon이 첫 실행 시 다이얼로그로 안내)"
echo "  4. 헬스 체크:"
echo "     curl -sS http://127.0.0.1:39632/v1/health"
echo ""
green "설치 완료."
