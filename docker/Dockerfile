FROM ubuntu:22.04

WORKDIR /project

# Enable 'universe' repository for Qt6 packages on Ubuntu 22.04
RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends software-properties-common && \
    DEBIAN_FRONTEND=noninteractive add-apt-repository -y universe && \
    apt-get update

RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    software-properties-common \
    wget \
    file \
    pkg-config \
    git \
    curl \
    fuse \
    libfuse2 \
    patchelf \
    desktop-file-utils \
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
    libegl1-mesa-dev \
    libxcb-xfixes0-dev \
    libsm-dev \
    libice-dev \
    libxcb-glx0-dev \
    libdrm-dev \
    libx11-xcb-dev \
    libopengl-dev

RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    qt6-base-dev \
    qt6-base-dev-tools \
    qt6-declarative-dev \
    qt6-tools-dev \
    qt6-tools-dev-tools \
    qt6-wayland-dev \
    libqt6opengl6-dev \
    libqt6openglwidgets6 \
    libqt6serialport6-dev \
    libqt6svg6-dev \
    qml6-module-qtquick \
    qml6-module-qtquick-controls \
    qml6-module-qtquick-window \
    qml6-module-qtquick-layouts \
    libqt6core5compat6-dev \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN wget https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-x86_64.AppImage \
    -O /usr/bin/linuxdeploy && chmod +x /usr/bin/linuxdeploy

RUN wget https://github.com/linuxdeploy/linuxdeploy-plugin-qt/releases/download/continuous/linuxdeploy-plugin-qt-x86_64.AppImage \
    -O /usr/bin/linuxdeploy-plugin-qt && chmod +x /usr/bin/linuxdeploy-plugin-qt

RUN git config --global --replace-all safe.directory '*'

COPY init.sh /init.sh

ENTRYPOINT ["/init.sh"]