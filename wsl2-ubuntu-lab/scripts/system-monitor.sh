#!/bin/bash
echo "=== SYSTEM HEALTH REPORT ==="

date
hostname

echo "=== SYSTEM UPTIME ==="
uptime

echo "=== MEMORY USAGE ==="
free -h

echo "=== DISK USAGE ==="
df -h /

echo "============================"
