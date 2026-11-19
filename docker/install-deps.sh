#!/bin/bash
# Installs everything needed to build the qFlipper AppImage on Ubuntu 24.04.
# Shared by docker/Dockerfile and the CI workflow so the two cannot drift apart.
# Must be run as root.

set -euo pipefail

. /etc/os-release
if [ "${ID:-}" != "ubuntu" ] || [ "${VERSION_ID:-}" != "24.04" ]; then
    echo "error: only Ubuntu 24.04 is supported (found ${PRETTY_NAME:-unknown})" >&2
    exit 1
fi

export DEBIAN_FRONTEND=noninteractive

# Retry and time out instead of stalling for the whole job on a slow mirror.
APT_OPTS=(-o Acquire::Retries=5 -o Acquire::http::Timeout=30 -o Acquire::https::Timeout=30)

# Optional: download packages into (and reuse them from) APT_ARCHIVES_DIR, so CI can
# cache the .debs between runs instead of depending on the mirror's speed every time.
if [ -n "${APT_ARCHIVES_DIR:-}" ]; then
    mkdir -p "${APT_ARCHIVES_DIR}/partial"
    APT_OPTS+=(-o "Dir::Cache::archives=${APT_ARCHIVES_DIR}" -o APT::Keep-Downloaded-Packages=true)
fi

apt-get "${APT_OPTS[@]}" update
# No Recommends: they pull in hundreds of MB (ffmpeg, LLVM, ...) that the AppImage never uses.
# The Qt plugins it bundles (xcb, xcbglintegrations, tls, imageformats) come from hard
# dependencies of qt6-base-dev / qt6-svg-dev. linuxdeploy bundles every installed QML module,
# so only the ones qFlipper actually loads at runtime are listed.
apt-get "${APT_OPTS[@]}" install -y --no-install-recommends \
    wget \
    file \
    pkg-config \
    git \
    curl \
    fuse \
    libfuse2t64 \
    zlib1g-dev \
    libusb-1.0-0-dev \
    ca-certificates \
    build-essential \
    libgl-dev \
    libxkbcommon-x11-dev \
    libxcb-icccm4-dev \
    libxcb-image0-dev \
    libxcb-keysyms1-dev \
    libxcb-randr0-dev \
    libxcb-render-util0-dev \
    libxcb-sync-dev \
    libdbus-1-dev \
    libmd4c-dev \
    libegl-dev \
    libxcb-xfixes0-dev \
    libsm-dev \
    libice-dev \
    libxcb-glx0-dev \
    libdrm-dev \
    libx11-xcb-dev \
    libopengl-dev \
    qt6-base-dev \
    qt6-declarative-dev \
    qt6-serialport-dev \
    qt6-shadertools-dev \
    qt6-svg-dev \
    qt6-tools-dev \
    qt6-5compat-dev \
    qml6-module-qt-labs-platform \
    qml6-module-qtqml \
    qml6-module-qtqml-models \
    qml6-module-qtqml-workerscript \
    qml6-module-qtquick \
    qml6-module-qtquick-controls \
    qml6-module-qtquick-layouts \
    qml6-module-qtquick-templates \
    qml6-module-qtquick-window

if [ -n "${APT_ARCHIVES_DIR:-}" ]; then
    # apt leaves partial/ owned by _apt with mode 700; make the cache readable for saving.
    chmod -R a+rX "${APT_ARCHIVES_DIR}"
fi

LINUXDEPLOY_URL="https://github.com/linuxdeploy/linuxdeploy/releases/download/1-alpha-20250213-2/linuxdeploy-x86_64.AppImage"
LINUXDEPLOY_QT_URL="https://github.com/linuxdeploy/linuxdeploy-plugin-qt/releases/download/1-alpha-20250213-1/linuxdeploy-plugin-qt-x86_64.AppImage"

wget -q --tries=5 --timeout=60 "$LINUXDEPLOY_URL" -O /usr/local/bin/linuxdeploy
wget -q --tries=5 --timeout=60 "$LINUXDEPLOY_QT_URL" -O /usr/local/bin/linuxdeploy-plugin-qt
chmod +x /usr/local/bin/linuxdeploy /usr/local/bin/linuxdeploy-plugin-qt
