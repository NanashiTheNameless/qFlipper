#!/bin/bash

set -euxo pipefail

# Ubuntu 22.04 friendly build script for qFlipper AppImage
# - Installs dependencies via apt (override with SKIP_APT=1)
# - Uses system qmake6 if present, otherwise installs Qt6 dev packages
# - Downloads linuxdeploy and its Qt plugin automatically if not found

TARGET="qFlipper"
BUILDDIR="build"
APPDIR_PREFIX="$PWD/$BUILDDIR/AppDir/usr"

# Detect Ubuntu version (best-effort, script still runs on other distros)
UBUNTU_VERSION="$(. /etc/os-release && echo "${VERSION_ID:-}")" || true
if [[ "${UBUNTU_VERSION}" != "22.04" ]]; then
    echo "[info] This script is optimized for Ubuntu 22.04 (detected: ${UBUNTU_VERSION:-unknown}). Proceeding anyway."
fi

# Optionally install required packages on Ubuntu 22.04
if [[ "${SKIP_APT:-0}" != "1" ]]; then
    if command -v apt-get >/dev/null 2>&1; then
        echo "[info] Ensuring required build packages are installed via apt-get"
            APT_PKGS=(
            build-essential
            cmake
            git
                curl
            pkg-config
            patchelf
            desktop-file-utils
            libfuse2
            libusb-1.0-0-dev
            zlib1g-dev
            # Qt6 (qmake6, tools, declarative/QML, serialport, wayland, 5compat)
            qt6-base-dev
            qt6-base-dev-tools
            qt6-tools-dev
            qt6-tools-dev-tools
            qt6-declarative-dev
            qt6-quickcontrols2-dev
            qt6-shadertools-dev
            qt6-serialport-dev
            qt6-wayland-dev
            qt6-5compat-dev
        )
        if [[ $EUID -ne 0 ]]; then SUDO="sudo"; else SUDO=""; fi
        ${SUDO} apt-get update -y
        # Avoid failing on unavailable packages on other distros by using best-effort install
        ${SUDO} apt-get install -y --no-install-recommends "${APT_PKGS[@]}" || true
    else
        echo "[info] apt-get not found; skipping package installation"
    fi
else
    echo "[info] SKIP_APT=1 set; skipping package installation"
fi

# Prefer system qmake6, fail fast if missing
if ! command -v qmake6 >/dev/null 2>&1; then
    echo "[error] qmake6 not found. Ensure Qt6 is installed (qt6-base-dev and qt6-base-dev-tools)."
    exit 1
fi

# Locate libssl3 (Ubuntu 22.04 ships OpenSSL 3); optional override for linuxdeploy bundling
LIBSSL3_OVERRIDE="$(ldconfig -p | grep -F x86-64 | grep -oP '/[^\s]+/libssl.so.3' | head -n1 || true)"
if [[ -n "${LIBSSL3_OVERRIDE}" ]]; then
    echo "[info] libssl3 found at: ${LIBSSL3_OVERRIDE}"
else
    echo "[warn] libssl3 not found via ldconfig - skipping explicit override"
fi

export OUTPUT="$TARGET-x86_64.AppImage"
export QML_SOURCES_PATHS="$PWD/application"
export EXTRA_QT_PLUGINS="waylandcompositor"
export EXTRA_PLATFORM_PLUGINS="libqwayland-egl.so;libqwayland-generic.so"

mkdir -p "$BUILDDIR" && cd "$BUILDDIR"

# Configure & build
qmake6 "../$TARGET.pro" -spec linux-g++ "CONFIG+=release qtquickcompiler" PREFIX="$APPDIR_PREFIX"
make qmake_all
make -j"$(nproc)"
make install

# Ensure linuxdeploy (and its Qt plugin) is available
LINUXDEPLOY_BIN="linuxdeploy"
if ! command -v linuxdeploy >/dev/null 2>&1; then
    echo "[info] linuxdeploy not found in PATH; downloading portable AppImages"
    TOOLS_DIR="$PWD/tools"
    mkdir -p "$TOOLS_DIR"
    LINUXDEPLOY_DL="$TOOLS_DIR/linuxdeploy-x86_64.AppImage"
    LINUXDEPLOY_QT_DL="$TOOLS_DIR/linuxdeploy-plugin-qt-x86_64.AppImage"
    # Download if missing
    if [[ ! -f "$LINUXDEPLOY_DL" ]]; then
        curl -fsSL -o "$LINUXDEPLOY_DL" "https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-x86_64.AppImage"
        chmod +x "$LINUXDEPLOY_DL"
    fi
    if [[ ! -f "$LINUXDEPLOY_QT_DL" ]]; then
        curl -fsSL -o "$LINUXDEPLOY_QT_DL" "https://github.com/linuxdeploy/linuxdeploy-plugin-qt/releases/download/continuous/linuxdeploy-plugin-qt-x86_64.AppImage"
        chmod +x "$LINUXDEPLOY_QT_DL"
    fi
    LINUXDEPLOY_BIN="$LINUXDEPLOY_DL"
    # Make plugin discoverable by linuxdeploy when using --plugin qt
    export PATH="$TOOLS_DIR:$PATH"
fi

# Build AppImage with linuxdeploy
LINUXDEPLOY_ARGS=(
    --appdir=AppDir
    -o appimage
    --custom-apprun="../installer-assets/appimage/AppRun"
    --plugin qt
)
if [[ -n "${LIBSSL3_OVERRIDE}" ]]; then
    LINUXDEPLOY_ARGS+=(--library="${LIBSSL3_OVERRIDE}")
fi

"$LINUXDEPLOY_BIN" "${LINUXDEPLOY_ARGS[@]}"