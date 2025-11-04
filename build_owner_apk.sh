#!/usr/bin/env bash
set -euo pipefail

# ---- args (flags) ----
usage() {
  echo "Usage: $0 \
    --app-name NAME \
    --api-base-url URL \
    --owner-project-link-id ID \
    --project-id ID \
    [--ws-path /api/ws] \
    [--app-role both] \
    [--owner-attach-mode header] \
    [--app-logo-url URL] \
    --owner-bucket /path/to/output \
    --project-dir /path/to/hobbysphere"
  exit 1
}

APP_NAME=""
API_BASE_URL=""
OWNER_PROJECT_LINK_ID=""
PROJECT_ID=""
WS_PATH="/api/ws"
APP_ROLE="both"
OWNER_ATTACH_MODE="header"
APP_LOGO_URL=""
OWNER_BUCKET=""
PROJECT_DIR=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --app-name) APP_NAME="$2"; shift 2;;
    --api-base-url) API_BASE_URL="$2"; shift 2;;
    --owner-project-link-id) OWNER_PROJECT_LINK_ID="$2"; shift 2;;
    --project-id) PROJECT_ID="$2"; shift 2;;
    --ws-path) WS_PATH="$2"; shift 2;;
    --app-role) APP_ROLE="$2"; shift 2;;
    --owner-attach-mode) OWNER_ATTACH_MODE="$2"; shift 2;;
    --app-logo-url) APP_LOGO_URL="$2"; shift 2;;
    --owner-bucket) OWNER_BUCKET="$2"; shift 2;;
    --project-dir) PROJECT_DIR="$2"; shift 2;;
    *) echo "Unknown arg: $1"; usage;;
  esac
done

[[ -z "$APP_NAME" || -z "$API_BASE_URL" || -z "$OWNER_PROJECT_LINK_ID" || -z "$PROJECT_ID" || -z "$OWNER_BUCKET" || -z "$PROJECT_DIR" ]] && usage

cd "$PROJECT_DIR"

# 1) assets
mkdir -p assets/icons assets/splash
if [[ -n "$APP_LOGO_URL" ]]; then
  # -L for redirects; -f to fail on HTTP errors; -o for file
  curl -fL "$APP_LOGO_URL" -o ./assets/icons/app_icon.png
  cp -f ./assets/icons/app_icon.png ./assets/splash/splash.png
fi

# 2) deps
flutter pub get

# 3) icons & splash
dart run flutter_launcher_icons
dart run flutter_native_splash:create

# 4) build RELEASE APK
flutter build apk --release \
  -t lib/app/main_activity.dart \
  --dart-define=API_BASE_URL="$API_BASE_URL" \
  --dart-define=OWNER_PROJECT_LINK_ID=$OWNER_PROJECT_LINK_ID \
  --dart-define=OWNER_ATTACH_MODE="$OWNER_ATTACH_MODE" \
  --dart-define=APP_ROLE="$APP_ROLE" \
  --dart-define=WS_PATH="$WS_PATH" \
  --dart-define=PROJECT_ID=$PROJECT_ID \
  --dart-define=APP_NAME="$APP_NAME" \
  --dart-define=APP_LOGO_URL="$APP_LOGO_URL" \
  -- \
  -PAPP_NAME="$APP_NAME"

# 5) copy result to owner bucket
BUILT="$PROJECT_DIR/build/app/outputs/apk/release/app-release.apk"
TS=$(date +"%Y%m%d_%H%M%S")
# slug: keep letters/digits/dash only
SLUG=$(echo "$APP_NAME" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9\-]\+/-/g' | sed 's/^-//; s/-$//')

mkdir -p "$OWNER_BUCKET"
DEST="$OWNER_BUCKET/${SLUG}_${TS}.apk"
cp -f "$BUILT" "$DEST"

# IMPORTANT: backend will read LAST LINE as absolute apk path
echo "$DEST"
