#!/bin/bash

# Simple headless browser starter - NO D-Bus, NO turniket-kiosk
# This script ONLY uses Chromium to avoid all D-Bus issues

# Set display
export DISPLAY=:0
export QT_QPA_PLATFORM=xcb
export GDK_BACKEND=x11

# Function to start Xvfb
start_x_server() {
    echo "Starting Xvfb (Virtual X server)..."
    
    # Kill any existing X server
    pkill -f "Xvfb.*:0" || true
    pkill -f "X.*:0" || true
    sleep 2
    
    # Remove lock files
    rm -f /tmp/.X0-lock /tmp/.X11-unix/X0 2>/dev/null || true
    
    # Create socket directory
    mkdir -p /tmp/.X11-unix 2>/dev/null || true
    chmod 1777 /tmp/.X11-unix 2>/dev/null || true
    
    # Start Xvfb
    Xvfb :0 -screen 0 1920x1080x24 -ac -nolisten tcp -dpi 96 >/dev/null 2>&1 &
    
    # Wait for X server
    local count=0
    while [ $count -lt 10 ]; do
        if xdpyinfo -display :0 >/dev/null 2>&1; then
            echo "Xvfb is ready"
            return 0
        fi
        echo "Waiting for Xvfb... ($count/10)"
        sleep 1
        count=$((count + 1))
    done
    
    echo "Failed to start Xvfb"
    return 1
}

# Start X server if not running
if ! xdpyinfo -display :0 >/dev/null 2>&1; then
    if ! start_x_server; then
        echo "Cannot start X server, exiting"
        exit 1
    fi
else
    echo "X server already running"
fi

# Get URL
URL=${1:-"http://localhost:3000"}
sleep 2

# ONLY use Chromium - never turniket-kiosk
echo "Starting Chromium browser in kiosk mode on $URL"

# Kill any existing chromium processes
pkill -f chromium-browser || true
sleep 2

# Start Chromium with minimal flags
DISPLAY=:0 chromium-browser \
    --kiosk \
    --no-sandbox \
    --disable-dev-shm-usage \
    --disable-gpu \
    --no-first-run \
    --disable-infobars \
    --disable-default-apps \
    --disable-extensions \
    --disable-plugins \
    --disable-web-security \
    --disable-features=VizDisplayCompositor,TranslateUI \
    --no-default-browser-check \
    --disable-popup-blocking \
    --disable-translate \
    --disable-background-timer-throttling \
    --disable-backgrounding-occluded-windows \
    --disable-renderer-backgrounding \
    --disable-field-trial-config \
    --disable-back-forward-cache \
    --disable-ipc-flooding-protection \
    "$URL" >/dev/null 2>&1 &

echo "Simple Chromium browser started"

# Keep the script running
wait