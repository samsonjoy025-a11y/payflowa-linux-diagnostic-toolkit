 #!/bin/bash

# ==========================================
# PayFlowa Linux System Diagnostic Toolkit
# ==========================================

# Get hostname
echo "hostname: $(hostname)"

# Get current user
echo "whoami: $(whoami)"

# Get date and time
echo "date: $(date)"

# Get operating system
echo "Operating System:"
cat /etc/os-release

# Get kernel version
echo "Kernel Version:"
uname -r

# Get system uptime
echo "System Uptime:"
uptime

# Get CPU information
echo "CPU Information:"
lscpu

# Get memory information
echo "Memory Information:"
free -h

# Get current working directory
echo "Current Working Directory:"
pwd

# ==========================================
# End of system diagnostics
# ==========================================
