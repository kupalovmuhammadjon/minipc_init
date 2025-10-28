#!/bin/bash

# Browser Control Script
# Usage: ./browser-control.sh [start|stop|restart|status]

SERVICE_NAME="simple-browser.service"

case "$1" in
    start)
        echo "Starting browser service..."
        sudo systemctl start $SERVICE_NAME
        sudo systemctl status $SERVICE_NAME --no-pager -l
        ;;
    stop)
        echo "Stopping browser service..."
        sudo systemctl stop $SERVICE_NAME
        # Also kill any remaining processes
        pkill -f chromium-browser || true
        pkill -f turniket-kiosk || true
        pkill -f openbox || true
        # Keep X server running but kill browsers
        echo "Browser stopped. Monitor will show desktop/terminal."
        ;;
    restart)
        echo "Restarting browser service..."
        sudo systemctl restart $SERVICE_NAME
        sleep 2
        sudo systemctl status $SERVICE_NAME --no-pager -l
        ;;
    status)
        echo "Browser service status:"
        sudo systemctl status $SERVICE_NAME --no-pager -l
        echo ""
        echo "Running processes:"
        ps aux | grep -E "(chromium|turniket|openbox|X)" | grep -v grep
        ;;
    kill-all)
        echo "Killing everything (browser, X server, service)..."
        sudo systemctl stop $SERVICE_NAME
        pkill -f chromium-browser || true
        pkill -f turniket-kiosk || true
        pkill -f openbox || true
        pkill -f "X.*:0" || true
        pkill -f "Xorg.*:0" || true
        echo "Everything stopped. Monitor should show login prompt."
        ;;
    enable)
        echo "Enabling auto-start on boot..."
        sudo systemctl enable $SERVICE_NAME
        echo "Browser will start automatically on boot."
        ;;
    disable)
        echo "Disabling auto-start on boot..."
        sudo systemctl disable $SERVICE_NAME
        echo "Browser will NOT start automatically on boot."
        ;;
    *)
        echo "Usage: $0 {start|stop|restart|status|kill-all|enable|disable}"
        echo ""
        echo "Commands:"
        echo "  start     - Start the browser service"
        echo "  stop      - Stop browser but keep X server (shows terminal)"
        echo "  restart   - Restart the browser"
        echo "  status    - Show current status"
        echo "  kill-all  - Stop everything including X server"
        echo "  enable    - Enable auto-start on boot"
        echo "  disable   - Disable auto-start on boot"
        exit 1
        ;;
esac