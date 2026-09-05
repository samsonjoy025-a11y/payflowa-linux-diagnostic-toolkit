

#!/bin/bash

# Log file
LOG_FILE="logs/diagnostic.log"

# Logging function
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Capture arguments
threshold=$1
path=$2

# Check that threshold was provided
if [ -z "$threshold" ]; then
    echo "Error: threshold is required."
    echo "Usage: $0 <threshold> [path]"
    log "Disk check failed: threshold was not provided"
    exit 2
fi

# Check that threshold is an integer
if ! [[ "$threshold" =~ ^[0-9]+$ ]]; then
    echo "Error: threshold must be an integer."
    log "Disk check failed: invalid threshold: $threshold"
    exit 2
fi

# Check that threshold is between 1 and 100
if [ "$threshold" -lt 1 ] || [ "$threshold" -gt 100 ]; then
    echo "Error: threshold must be between 1 and 100."
    log "Disk check failed: threshold $threshold is outside valid range"
    exit 2
fi

# Default path
if [ -z "$path" ]; then
    path="/"
fi

# Log the start of the disk check
log "Disk check started: threshold=$threshold path=$path"

# Check that the path exists
if [ ! -d "$path" ]; then
    echo "Error: path does not exist: $path"
    log "Disk check failed: path does not exist: $path"
    exit 2
fi

# Get disk usage percentage
usage=$(df -P "$path" | awk 'NR==2 {print $5}' | tr -d '%')

# Display disk usage
echo "Disk usage for $path: ${usage}%"
echo "Threshold: ${threshold}%"

# Log disk usage
log "Disk usage for $path: ${usage}%"

# Compare usage with threshold
if [ "$usage" -lt "$threshold" ]; then
    echo "Disk usage is below the threshold."
    log "Disk usage is below threshold: usage=$usage threshold=$threshold"
    exit 0
else
    echo "Disk usage has reached or exceeded the threshold."
    log "Disk usage reached or exceeded threshold: usage=$usage threshold=$threshold"
    exit 1
fi
