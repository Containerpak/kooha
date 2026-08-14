FROM ghcr.io/containerpak/gtk4-sdk:main AS build

ARG DEBIAN_FRONTEND=noninteractive
ARG KOOHA_URL=https://github.com/SeaDve/Kooha/releases/download/v2.3.2/kooha-2.3.2.tar.xz
ARG KOOHA_SHA256=a8f7d0d6fc1418264639a42833d66866475ed0d30b6f1f50b0b430c7d35b3969

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    cargo curl desktop-file-utils gettext libgstreamer-plugins-base1.0-dev \
    libgstreamer1.0-dev meson ninja-build rustc && \
    curl -fL "$KOOHA_URL" -o /tmp/kooha.tar.xz && \
    echo "$KOOHA_SHA256  /tmp/kooha.tar.xz" | sha256sum -c - && \
    mkdir -p /tmp/kooha && \
    tar -xJf /tmp/kooha.tar.xz -C /tmp/kooha --strip-components=1 && \
    meson setup /tmp/kooha/build /tmp/kooha --prefix=/usr --buildtype=release && \
    meson compile -C /tmp/kooha/build && \
    DESTDIR=/out meson install -C /tmp/kooha/build

FROM ghcr.io/containerpak/adwaita:main

ARG DEBIAN_FRONTEND=noninteractive

COPY --from=build /out/usr/ /usr/

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    gstreamer1.0-libav gstreamer1.0-plugins-bad \
    gstreamer1.0-plugins-good gstreamer1.0-pulseaudio libglib2.0-bin && \
    glib-compile-schemas /usr/share/glib-2.0/schemas && \
    cpak-clean-junk
