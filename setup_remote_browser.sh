#!/bin/bash

# Minimal Ubuntu Server Setup for Headless Browser/Kiosk
# This script installs only essential components to run Chromium-based apps

set -e

echo "🚀 Setting up minimal headless browser environment..."

# Update package index
echo "📦 Updating package index..."
sudo apt update

# Install minimal X11 components (no desktop environment)
echo "🖥️  Installing minimal X11 server..."
sudo apt install -y \
    xserver-xorg-core \
    xserver-xorg-input-all \
    xserver-xorg-video-all \
    xinit \
    x11-utils \
    x11-xserver-utils

# Install essential libraries for Chromium (minimal set)
echo "📚 Installing essential browser libraries..."
sudo apt install -y \
    libgtk-3-0 \
    libnss3 \
    libxss1 \
    libgconf-2-4 \
    libxrandr2 \
    libasound2 \
    libpangocairo-1.0-0 \
    libatk1.0-0 \
    libcairo-gobject2 \
    libgtk-3-0 \
    libgdk-pixbuf2.0-0 \
    libxcomposite1 \
    libxcursor1 \
    libxi6 \
    libxtst6

# Install minimal fonts
echo "� Installing basic fonts..."
sudo apt install -y \
    fonts-liberation \
    fontconfig

# Create headless browser startup script
echo "📝 Creating headless browser script..."
sudo tee /usr/local/bin/start-headless-browser.sh > /dev/null << 'EOF'
#!/bin/bash

# Set display and other environment variables
export DISPLAY=:0
export XAUTHORITY=/tmp/.X0-auth

# Function to start X server properly
start_x_server() {
    echo "Starting X server..."
    
    # Kill any existing X server on display :0
    sudo pkill -f "X.*:0" || true
    sleep 2
    
    # Remove any existing lock files
    sudo rm -f /tmp/.X0-lock /tmp/.X11-unix/X0
    
    # Start X server with proper options for headless operation
    sudo X :0 -ac -nolisten tcp -noreset +extension GLX +extension RANDR +extension RENDER -logfile /var/log/Xorg.0.log &
    
    # Wait for X server to be ready
    local count=0
    while [ $count -lt 30 ]; do
        if xdpyinfo -display :0 >/dev/null 2>&1; then
            echo "X server is ready"
            return 0
        fi
        echo "Waiting for X server... ($count/30)"
        sleep 1
        count=$((count + 1))
    done
    
    echo "Failed to start X server"
    return 1
}

# Check if X server is running, if not start it
if ! xdpyinfo -display :0 >/dev/null 2>&1; then
    if ! start_x_server; then
        echo "Cannot start X server, exiting"
        exit 1
    fi
else
    echo "X server already running"
fi

# Get the URL from argument or use default
URL=${1:-"http://localhost:3000"}

# Wait a bit more for X server to stabilize
sleep 2

# Start your kiosk application
if command -v turniket-kiosk &> /dev/null; then
    echo "Starting turniket-kiosk on $URL"
    turniket-kiosk --kiosk --no-sandbox --disable-dev-shm-usage --disable-gpu --disable-software-rasterizer "$URL"
else
    echo "turniket-kiosk not found. Please install it or use alternative browser."
    echo "You can try: chromium-browser --kiosk --no-sandbox --disable-dev-shm-usage --disable-gpu '$URL'"
fi
EOF

sudo chmod +x /usr/local/bin/start-headless-browser.sh

# Create systemd service for headless browser
echo "🔧 Creating minimal systemd service..."
sudo tee /etc/systemd/system/headless-browser.service > /dev/null << 'EOF'
[Unit]
Description=Headless Browser Service
After=multi-user.target
Wants=multi-user.target

[Service]
Type=simple
User=icecity
Environment=DISPLAY=:0
ExecStartPre=/bin/sleep 10
ExecStart=/usr/local/bin/start-headless-browser.sh
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

echo "✅ Minimal headless browser setup completed!"
echo ""
echo "📖 Usage instructions:"
echo "1. Manual start: sudo /usr/local/bin/start-headless-browser.sh [URL]"
echo "2. Enable auto-start: sudo systemctl enable headless-browser.service"
echo "3. Start service now: sudo systemctl start headless-browser.service"
echo ""
echo "🔧 Notes:"
echo "- No desktop environment installed - server stays headless"
echo "- Install turniket-kiosk separately for full functionality"
echo "- X server runs only when browser is active"
echo "- Service runs as user 'icecity' - adjust if needed"
echo "- Edit /usr/local/bin/start-headless-browser.sh to customize"