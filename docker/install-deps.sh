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

apt-get update
apt-get install -y --no-install-recommends \
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
    qt6-wayland-dev \
    qt6-declarative-dev \
    qt6-serialport-dev \
    qt6-shadertools-dev \
    qt6-svg-dev \
    qt6-tools-dev \
    qt6-5compat-dev \
    'qml6-module-*'

LINUXDEPLOY_URL="https://github.com/linuxdeploy/linuxdeploy/releases/download/1-alpha-20250213-2/linuxdeploy-x86_64.AppImage"
LINUXDEPLOY_QT_URL="https://github.com/linuxdeploy/linuxdeploy-plugin-qt/releases/download/1-alpha-20250213-1/linuxdeploy-plugin-qt-x86_64.AppImage"

wget -q "$LINUXDEPLOY_URL" -O /usr/local/bin/linuxdeploy
wget -q "$LINUXDEPLOY_QT_URL" -O /usr/local/bin/linuxdeploy-plugin-qt
chmod +x /usr/local/bin/linuxdeploy /usr/local/bin/linuxdeploy-plugin-qt
