param(
  [Parameter(Mandatory=$true)][string]$APP_NAME,
  [Parameter(Mandatory=$true)][string]$API_BASE_URL,
  [Parameter(Mandatory=$true)][string]$OWNER_PROJECT_LINK_ID,
  [Parameter(Mandatory=$true)][string]$PROJECT_ID,
  [Parameter(Mandatory=$false)][string]$WS_PATH = "/api/ws",
  [Parameter(Mandatory=$false)][string]$APP_ROLE = "both",
  [Parameter(Mandatory=$false)][string]$OWNER_ATTACH_MODE = "header",
  [Parameter(Mandatory=$false)][string]$APP_LOGO_URL = "",
  [Parameter(Mandatory=$true)][string]$OWNER_BUCKET,
  [Parameter(Mandatory=$true)][string]$PROJECT_DIR,

  # Optional overrides if PATH is not set
  [Parameter(Mandatory=$false)][string]$FLUTTER_BIN = "",     # e.g. C:\src\flutter\bin\flutter.bat
  [Parameter(Mandatory=$false)][string]$ANDROID_HOME = ""     # e.g. C:\Android\sdk
)

$ErrorActionPreference = 'Stop'

function Resolve-Flutter {
  param([string]$Override)
  if ($Override -and (Test-Path $Override)) { return (Resolve-Path $Override).Path }

  $candidates = @(
    "$env:FLUTTER_HOME\bin\flutter.bat",
    "C:\src\flutter\bin\flutter.bat",
    "$env:USERPROFILE\scoop\apps\flutter\current\bin\flutter.bat",
    "$env:USERPROFILE\flutter\bin\flutter.bat"
  ) | Where-Object { $_ -and (Test-Path $_) }

  if ($candidates.Count -gt 0) { return (Resolve-Path $candidates[0]).Path }

  $cmd = (Get-Command flutter -ErrorAction SilentlyContinue)
  if ($cmd) { return $cmd.Source }

  throw "Flutter not found. Set FLUTTER_HOME or pass -FLUTTER_BIN 'C:\path\to\flutter\bin\flutter.bat'."
}

function Resolve-Dart {
  param([string]$FlutterBat)
  # Dart usually lives under flutter\bin\cache\dart-sdk\bin\dart.exe
  $flutterBin = Split-Path -Parent $FlutterBat
  $dart = Join-Path $flutterBin "cache\dart-sdk\bin\dart.exe"
  if (Test-Path $dart) { return (Resolve-Path $dart).Path }

  $cmd = (Get-Command dart -ErrorAction SilentlyContinue)
  if ($cmd) { return $cmd.Source }

  throw "Dart not found near Flutter or on PATH."
}

function Maybe-Add-ToPath {
  param([string[]]$paths)
  foreach ($p in $paths) {
    if ($p -and (Test-Path $p)) {
      $abs = (Resolve-Path $p).Path
      if (-not ($env:PATH -split ';' | Where-Object { $_ -ieq $abs })) {
        $env:PATH = "$abs;$env:PATH"
      }
    }
  }
}

# === Resolve tools ===
$FlutterBat = Resolve-Flutter -Override $FLUTTER_BIN
$DartExe    = Resolve-Dart -FlutterBat $FlutterBat

# (optional) add Android tools to PATH if provided or already set
if (-not $ANDROID_HOME) { $ANDROID_HOME = $env:ANDROID_HOME }
Maybe-Add-ToPath @(
  (Split-Path -Parent $FlutterBat),                     # ...\flutter\bin
  (Split-Path -Parent $DartExe),                        # ...\dart-sdk\bin
  "$ANDROID_HOME\platform-tools", "$ANDROID_HOME\tools", "$ANDROID_HOME\cmdline-tools\latest\bin"
)

# === Workdir ===
Set-Location $PROJECT_DIR

# === Assets ===
New-Item -ItemType Directory -Force -Path assets\icons | Out-Null
New-Item -ItemType Directory -Force -Path assets\splash | Out-Null

if ($APP_LOGO_URL) {
  Invoke-WebRequest -Uri $APP_LOGO_URL -OutFile .\assets\icons\app_icon.png
  Copy-Item .\assets\icons\app_icon.png .\assets\splash\splash.png -Force
}

# === Deps ===
& $FlutterBat pub get

# === Icons & splash ===
& $DartExe run flutter_launcher_icons
& $DartExe run flutter_native_splash:create

# === Build RELEASE APK ===
& $FlutterBat build apk --release `
  -t lib/app/main_activity.dart `
  --dart-define="API_BASE_URL=$API_BASE_URL" `
  --dart-define="OWNER_PROJECT_LINK_ID=$OWNER_PROJECT_LINK_ID" `
  --dart-define="OWNER_ATTACH_MODE=$OWNER_ATTACH_MODE" `
  --dart-define="APP_ROLE=$APP_ROLE" `
  --dart-define="WS_PATH=$WS_PATH" `
  --dart-define="PROJECT_ID=$PROJECT_ID" `
  --dart-define="APP_NAME=$APP_NAME" `
  --dart-define="APP_LOGO_URL=$APP_LOGO_URL" `
  -- `
  -PAPP_NAME="$APP_NAME"

# === Copy result to owner bucket ===
$built = Join-Path $PROJECT_DIR "build\app\outputs\apk\release\app-release.apk"
if (-not (Test-Path $built)) { throw "Release APK not found at $built" }

$ts = Get-Date -Format "yyyyMMdd_HHmmss"
$slug = ($APP_NAME -replace '[^a-zA-Z0-9\-]+','-').ToLower()
New-Item -ItemType Directory -Force -Path $OWNER_BUCKET | Out-Null
$dest = Join-Path $OWNER_BUCKET "$($slug)_$($ts).apk"
Copy-Item $built $dest -Force

# Backend reads the LAST LINE as the absolute APK path
Write-Output $dest
