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
    x11-utils

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

# Set display
export DISPLAY=:0

# Start X server in background if not running
if ! pgrep -x "Xorg" > /dev/null; then
    sudo X :0 -ac -nolisten tcp vt7 &
    sleep 3
fi

# Get the URL from argument or use default
URL=${1:-"http://localhost:3000"}

# Start your kiosk application
if command -v turniket-kiosk &> /dev/null; then
    echo "Starting turniket-kiosk on $URL"
    turniket-kiosk --kiosk --no-sandbox --disable-dev-shm-usage "$URL"
else
    echo "turniket-kiosk not found. Please install it or use alternative browser."
    echo "Example: chromium-browser --kiosk --no-sandbox --disable-dev-shm-usage '$URL'"
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