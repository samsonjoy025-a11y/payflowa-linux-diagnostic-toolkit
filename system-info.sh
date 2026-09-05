#!/bin/bash

echo "===== SYSTEM INFORMATION ====="

echo "Hostname: $(hostname)"
echo "Current User: $(whoami)"
echo "Date/Time: $(date)"

if [ -f /etc/os-release ]; then
    . /etc/os-release
    echo "Operating System: $PRETTY_NAME"
else
    echo "Operating System: Unknown"
fi

echo "Kernel Version: $(uname -r)"
echo "Uptime: $(uptime -p)"

echo "CPU Information:"
lscpu | grep -E '^Model name|^CPU\(s\):' | head -2

echo "Memory Information:"
free -h

echo "Current Working Directory: $(pwd)"

echo "=============================="
