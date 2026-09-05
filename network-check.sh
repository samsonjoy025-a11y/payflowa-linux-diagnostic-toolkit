#!/bin/bash

# Log file
LOG_FILE="logs/diagnostic.log"

# Logging function
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Capture arguments
host=$1
port=$2

# Check that hostname/IP was provided
if [ -z "$host" ]; then
    echo "Error: hostname or IP address is required."
    echo "Usage: $0 <hostname-or-ip> [port]"
    log "Network check failed: hostname or IP was not provided"
    exit 2
fi

# Validate hostname/IP format
if ! [[ "$host" =~ ^[a-zA-Z0-9.-]+$ ]]; then
    echo "Error: invalid hostname or IP address."
    log "Network check failed: invalid hostname or IP: $host"
    exit 2
fi

# Log start of network check
log "Network check started: host=$host port=${port:-none}"

# Resolve hostname/IP
resolved=$(getent hosts "$host" | awk '{print $1}' | head -1)

# Check whether resolution succeeded
if [ -z "$resolved" ]; then
    echo "Error: unable to resolve host: $host"
    log "Host resolution failed: $host"
    exit 1
fi

# Display resolved address
echo "Hostname/IP: $host"
echo "Resolved address: $resolved"

# Log successful resolution
log "Host resolved successfully: $host -> $resolved"

# Perform connectivity check
echo "Connectivity check:"

if ping -c 1 -W 2 "$host" >/dev/null 2>&1; then
    echo "Connectivity: reachable"
    log "Connectivity check: $host is reachable"
else
    echo "Connectivity: unreachable"
    log "Connectivity check: $host is unreachable"
fi

# Display network interfaces
echo
echo "Network interfaces:"
ip addr

log "Network interfaces displayed"

# Handle optional port
if [ -n "$port" ]; then

    # Validate that port is numeric
    if ! [[ "$port" =~ ^[0-9]+$ ]]; then
        echo "Error: port must be numeric."
        log "Network check failed: invalid port: $port"
        exit 2
    fi

    # Validate port range
    if [ "$port" -lt 1 ] || [ "$port" -gt 65535 ]; then
        echo "Error: port must be between 1 and 65535."
        log "Network check failed: port $port outside valid range"
        exit 2
    fi

    # Check TCP connectivity
    echo
    echo "TCP connectivity check: $host:$port"

    if timeout 5 bash -c "</dev/tcp/$host/$port" 2>/dev/null; then
        echo "TCP port $port: reachable"
        log "TCP port $port on $host is reachable"
    else
        echo "TCP port $port: unreachable"
        log "TCP port $port on $host is unreachable"
    fi
fi

# Log completion
log "Network check completed: host=$host port=${port:-none}"
