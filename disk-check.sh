#!/bin/bash

threshold=$1
path=$2

# Check that threshold was provided
if [ -z "$threshold" ]; then
    echo "Error: threshold is required."
    echo "Usage: $0 <threshold> [path]"
    exit 2
fi

# Check that threshold is an integer
if ! [[ "$threshold" =~ ^[0-9]+$ ]]; then
    echo "Error: threshold must be an integer."
    exit 2
fi

# Check that threshold is between 1 and 100
if [ "$threshold" -lt 1 ] || [ "$threshold" -gt 100 ]; then
    echo "Error: threshold must be between 1 and 100."
    exit 2
fi

# Default path
if [ -z "$path" ]; then
    path="/"
fi

# Check that the path exists
if [ ! -d "$path" ]; then
    echo "Error: path does not exist: $path"
    exit 2
fi

# Get disk usage percentage
usage=$(df -P "$path" | awk 'NR==2 {print $5}' | tr -d '%')

echo "Disk usage for $path: ${usage}%"
echo "Threshold: ${threshold}%"

if [ "$usage" -lt "$threshold" ]; then
    echo "Disk usage is below the threshold."
    exit 0
else
    echo "Disk usage has reached or exceeded the threshold."
    exit 1
fi
