#!/bin/bash

# Simple Working Browser Script
# This just starts a browser, no fancy X server management

echo "Starting simple browser..."

# Kill any existing browsers
pkill -f chromium-browser || true
pkill -f turniket-kiosk || true
sleep 2

# Set display
export DISPLAY=:0

# Get URL
URL=${1:-"http://localhost:3000"}

echo "Starting Chromium on $URL"

# Just start Chromium simply
chromium-browser \
    --kiosk \
    --no-sandbox \
    --disable-dev-shm-usage \
    --disable-gpu \
    --no-first-run \
    --disable-infobars \
    --disable-default-apps \
    --disable-extensions \
    --disable-web-security \
    --no-default-browser-check \
    --disable-popup-blocking \
    "$URL" &

echo "Browser started"

# Keep script running
while true; do
    sleep 10
    # Check if browser is still running
    if ! pgrep -f chromium-browser > /dev/null; then
        echo "Browser died, restarting..."
        chromium-browser \
            --kiosk \
            --no-sandbox \
            --disable-dev-shm-usage \
            --disable-gpu \
            --no-first-run \
            --disable-infobars \
            --disable-default-apps \
            --disable-extensions \
            --disable-web-security \
            --no-default-browser-check \
            --disable-popup-blocking \
            "$URL" &
    fi
done