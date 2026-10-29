FROM jlesage/baseimage-gui:debian-13-v4

# Wine (64-bit) + Tools fuer Download und Hash-Pruefung
RUN add-pkg wine wine64 ca-certificates curl fonts-liberation fonts-wqy-zenhei locales && \
    sed-patch 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen && \
    wine --version

# UTF-8-Locale, sonst kann Wine Dateinamen mit Nicht-ASCII-Zeichen nicht anlegen
ENV LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8

ENV WINEPREFIX=/config/wine \
    WINEARCH=win64 \
    WINEDEBUG=-all \
    WINEDLLOVERRIDES="mscoree,mshtml=" \
    AUTO_UPDATE=1 \
    RELEASE_TAG= \
    OUTPUT_SUBDIR=ps5-backport

# Stand des Upstream-Releases zum Build-Zeitpunkt (nur Tag + Hash, keine EXE).
# Aendert sich das, entsteht ein neues Image -> Unraid zeigt ein Update an.
ARG UPSTREAM_TAG=early-testing-beta
ARG UPSTREAM_SHA256=unknown
ARG UPSTREAM_EXE=PS5BackportGUI.exe
RUN mkdir -p /etc/ps5backport && \
    echo "$UPSTREAM_EXE" > /etc/ps5backport/upstream_exe && \
    echo "$UPSTREAM_TAG" > /etc/ps5backport/upstream_tag && \
    echo "$UPSTREAM_SHA256" > /etc/ps5backport/upstream_sha256

COPY rootfs/startapp.sh /startapp.sh

RUN chmod +x /startapp.sh && \
    set-cont-env APP_NAME "PS5 Backport"

LABEL ps5backport.upstream.tag="${UPSTREAM_TAG}" \
      ps5backport.upstream.sha256="${UPSTREAM_SHA256}" \
      ps5backport.upstream.exe="${UPSTREAM_EXE}" \
      org.opencontainers.image.source="https://github.com/cosmicflow2512/ps5-backport-docker" \
      org.opencontainers.image.description="Unraid container for PS5 Backport GUI (Wine + noVNC). The application itself is not included; it is downloaded from the official release at first start."
