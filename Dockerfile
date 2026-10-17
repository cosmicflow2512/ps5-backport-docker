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
    RELEASE_TAG=early-testing-beta \
    OUTPUT_SUBDIR=ps5-backport

COPY rootfs/startapp.sh /startapp.sh

RUN chmod +x /startapp.sh && \
    set-cont-env APP_NAME "PS5 Backport"

LABEL org.opencontainers.image.source="https://github.com/cosmicflow2512/ps5-backport-docker" \
      org.opencontainers.image.description="Unraid container for PS5 Backport GUI (Wine + noVNC). The application itself is not included; it is downloaded from the official release at first start."
