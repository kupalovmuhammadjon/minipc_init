# Simple Chromium kiosk image for X11 on host
FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

# Install Chromium and minimal fonts/deps
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       chromium \
       fonts-liberation \
       ca-certificates \
       wget \
       dumb-init \
       libnss3 \
       libgtk-3-0 \
       libx11-xcb1 \
       libxcomposite1 \
       libxdamage1 \
       libxrandr2 \
       libasound2 \
       libatspi2.0-0 \
       libdbus-1-3 \
       libxkbcommon0 \
    && rm -rf /var/lib/apt/lists/*

ENV LAUNCH_URL="about:blank" \
    CHROMIUM_FLAGS="--kiosk --no-first-run --no-default-browser-check"

# Create non-root user for running chrome
RUN useradd -m -s /bin/bash kiosk
USER kiosk
WORKDIR /home/kiosk

COPY entrypoint.sh /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["/usr/local/bin/entrypoint.sh"]
