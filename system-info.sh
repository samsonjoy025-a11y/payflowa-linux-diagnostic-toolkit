#!/bin/bash

# Log file
LOG_FILE="logs/diagnostic.log"

# Logging function
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Start logging
log "System information check started"

echo "===== SYSTEM INFORMATION ====="

echo "Hostname: $(hostname)"
log "Hostname information collected"

echo "Current User: $(whoami)"
log "Current user information collected"

echo "Date/Time: $(date)"
log "Date and time collected"

if [ -f /etc/os-release ]; then
    . /etc/os-release
    echo "Operating System: $PRETTY_NAME"
    log "Operating system information collected"
else
    echo "Operating System: Unknown"
    log "Operating system information unavailable"
fi

echo "Kernel Version: $(uname -r)"
log "Kernel version information collected"

echo "Uptime: $(uptime -p)"
log "System uptime information collected"

echo "CPU Information:"
lscpu | grep -E '^Model name|^CPU\(s\):' | head -2
log "CPU information collected"

echo "Memory Information:"
free -h
log "Memory information collected"

echo "Current Working Directory: $(pwd)"
log "Current working directory collected"

echo "=============================="

# Finish logging
log "System information check completed"
