#!/bin/bash

REPORT_DIR="$HOME/automation-lab/reports"
TIMESTAMP=$(date +%Y-%m-%d_%H-%M-%S)
REPORT_FILE="$REPORT_DIR/health-$TIMESTAMP.txt"

mkdir -p "$REPORT_DIR" || exit 1

check_service() {
        if systemctl is-active --quiet "$1"; then
                echo "$1: RUNNING"
        else
                echo "$1: NOT RUNNING"
        fi
}

{
        echo "===== SYSTEM HEALTH REPORT ====="
    echo "Date: $(date)"
    echo "Hostname: $(hostname)"

    echo
    echo "===== SYSTEM LOAD ====="
    uptime

    echo
    echo "===== MEMORY ====="
    free -h

    echo
    echo "===== DISK USAGE ====="
    df -hT

    echo
    echo "===== NETWORK ====="
    ip -br addr

    echo
    echo "===== SERVICE STATUS ====="

        for SERVICE in ssh nginx cron; do
                check_service "$SERVICE"
        done

        echo
        echo "=== WEBSITE STATUS ==="

        if curl -fsS --max-time 5 http://localhost/server-lab.html > /dev/null; then
                echo "Webiste: AVAILABLE"
        else
                echo "Website: UNAVAILABLE"
        fi

        echo
    echo "===== FAILED SYSTEMD UNITS ====="
    systemctl --failed --no-pager

} > "$REPORT_FILE" 2>&1

        if [ $? -eq 0 ]; then
                echo "Report generated: $REPORT_FILE"
        else
                echo "Report generation encountered an error." >&2
                exit 1
        fi
