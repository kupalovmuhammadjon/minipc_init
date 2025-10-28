#!/bin/bash

echo "🚀 Creating stable browser service..."

# Stop the problematic service
sudo systemctl stop simple-browser.service
sudo systemctl disable simple-browser.service

# Create new stable service
sudo tee /etc/systemd/system/stable-browser.service > /dev/null << 'EOF'
[Unit]
Description=Stable Browser Service for Ubuntu Server
After=multi-user.target
Wants=multi-user.target

[Service]
Type=simple
User=icecity
Environment=DISPLAY=:0
ExecStartPre=/bin/sleep 5
ExecStart=/home/icecity/minipc_init/start-stable-browser.sh
Restart=always
RestartSec=10
# Allow access to X server
SupplementaryGroups=tty video input render

[Install]
WantedBy=multi-user.target
EOF

# Update browser control script
sudo systemctl daemon-reload

echo "✅ Stable service created!"
echo ""
echo "Now try:"
echo "  sudo systemctl enable stable-browser.service"
echo "  sudo systemctl start stable-browser.service"
echo "  sudo systemctl status stable-browser.service"