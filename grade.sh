#!/bin/bash

# Payflowa Linux Diagnostic Toolkit
# Project validation / grading script

PASS=0
FAIL=0

# Print a test result
pass() {
    echo "[PASS] $1"
    PASS=$((PASS + 1))
}

fail() {
    echo "[FAIL] $1"
    FAIL=$((FAIL + 1))
}

echo "========================================"
echo " Payflowa Linux Diagnostic Toolkit"
echo " Project Validation"
echo "========================================"
echo

# ----------------------------------------
# 1. Required files and directories
# ----------------------------------------

echo "Checking project structure..."

required_files=(
    "README.md"
    "system-info.sh"
    "disk-check.sh"
    "network-check.sh"
    "grade.sh"
    "logs/.gitkeep"
)

for file in "${required_files[@]}"; do
    if [ -f "$file" ]; then
        pass "Required file exists: $file"
    else
        fail "Missing required file: $file"
    fi
done

echo

# ----------------------------------------
# 2. Script permissions
# ----------------------------------------

echo "Checking script permissions..."

for script in system-info.sh disk-check.sh network-check.sh; do
    if [ -x "$script" ]; then
        pass "$script is executable"
    else
        fail "$script is not executable"
    fi
done

echo

# ----------------------------------------
# 3. Bash syntax checks
# ----------------------------------------

echo "Checking Bash syntax..."

for script in system-info.sh disk-check.sh network-check.sh grade.sh; do
    if bash -n "$script" 2>/dev/null; then
        pass "$script syntax is valid"
    else
        fail "$script contains Bash syntax errors"
    fi
done

echo

# ----------------------------------------
# 4. System information test
# ----------------------------------------

echo "Testing system-info.sh..."

system_output=$(./system-info.sh 2>/dev/null)

system_checks=(
    "Hostname:"
    "Current User:"
    "Date/Time:"
    "Operating System:"
    "Kernel Version:"
    "Uptime:"
    "CPU Information:"
    "Memory Information:"
    "Current Working Directory:"
)

for check in "${system_checks[@]}"; do
    if echo "$system_output" | grep -q "$check"; then
        pass "system-info.sh displays $check"
    else
        fail "system-info.sh missing: $check"
    fi
done

echo

# ----------------------------------------
# 5. Disk check validation
# ----------------------------------------

echo "Testing disk-check.sh..."

# Valid threshold
./disk-check.sh 80 / >/dev/null 2>&1
disk_status=$?

if [ "$disk_status" -eq 0 ] || [ "$disk_status" -eq 1 ]; then
    pass "disk-check.sh accepts valid threshold"
else
    fail "disk-check.sh rejected valid threshold"
fi

# Missing threshold
./disk-check.sh >/dev/null 2>&1
disk_status=$?

if [ "$disk_status" -eq 2 ]; then
    pass "disk-check.sh rejects missing threshold"
else
    fail "disk-check.sh missing-threshold validation failed"
fi

# Non-numeric threshold
./disk-check.sh abc / >/dev/null 2>&1
disk_status=$?

if [ "$disk_status" -eq 2 ]; then
    pass "disk-check.sh rejects non-numeric threshold"
else
    fail "disk-check.sh non-numeric threshold validation failed"
fi

# Threshold below 1
./disk-check.sh 0 / >/dev/null 2>&1
disk_status=$?

if [ "$disk_status" -eq 2 ]; then
    pass "disk-check.sh rejects threshold below 1"
else
    fail "disk-check.sh threshold minimum validation failed"
fi

# Threshold above 100
./disk-check.sh 101 / >/dev/null 2>&1
disk_status=$?

if [ "$disk_status" -eq 2 ]; then
    pass "disk-check.sh rejects threshold above 100"
else
    fail "disk-check.sh threshold maximum validation failed"
fi

echo

# ----------------------------------------
# 6. Network check validation
# ----------------------------------------

echo "Testing network-check.sh..."

# Missing host
./network-check.sh >/dev/null 2>&1
network_status=$?

if [ "$network_status" -eq 2 ]; then
    pass "network-check.sh rejects missing host"
else
    fail "network-check.sh missing-host validation failed"
fi

# Invalid port
./network-check.sh localhost abc >/dev/null 2>&1
network_status=$?

if [ "$network_status" -eq 2 ]; then
    pass "network-check.sh rejects non-numeric port"
else
    fail "network-check.sh non-numeric port validation failed"
fi

# Port below 1
./network-check.sh localhost 0 >/dev/null 2>&1
network_status=$?

if [ "$network_status" -eq 2 ]; then
    pass "network-check.sh rejects port 0"
else
    fail "network-check.sh port minimum validation failed"
fi

# Port above 65535
./network-check.sh localhost 65536 >/dev/null 2>&1
network_status=$?

if [ "$network_status" -eq 2 ]; then
    pass "network-check.sh rejects port above 65535"
else
    fail "network-check.sh port maximum validation failed"
fi

# Valid hostname
./network-check.sh localhost >/dev/null 2>&1
network_status=$?

if [ "$network_status" -eq 0 ] || [ "$network_status" -eq 1 ]; then
    pass "network-check.sh accepts valid hostname"
else
    fail "network-check.sh failed valid hostname test"
fi

echo

# ----------------------------------------
# 7. Logging test
# ----------------------------------------

echo "Checking diagnostic logging..."

if [ -f "logs/diagnostic.log" ]; then
    pass "Diagnostic log file exists"
else
    fail "Diagnostic log file does not exist"
fi

if [ -f "logs/diagnostic.log" ] &&
   grep -Eq '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}' logs/diagnostic.log; then
    pass "Diagnostic log contains timestamps"
else
    fail "Diagnostic log does not contain valid timestamps"
fi

echo

# ----------------------------------------
# 8. Git history
# ----------------------------------------

echo "Checking Git history..."

if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    pass "Project is a Git repository"

    commit_count=$(git rev-list --all --count)

    if [ "$commit_count" -ge 5 ]; then
        pass "Git history contains at least 5 commits"
    else
        fail "Git history contains fewer than 5 commits"
    fi

    if git branch -a | grep -q "docs/add-project-documentation"; then
        pass "Feature branch exists"
    else
        fail "Feature branch docs/add-project-documentation not found"
    fi

    if git log --all --oneline | grep -q "docs: add project documentation"; then
        pass "Documentation feature commit exists"
    else
        fail "Documentation feature commit not found"
    fi

else
    fail "Project is not a Git repository"
fi

echo

# ----------------------------------------
# 9. Final summary
# ----------------------------------------

TOTAL=$((PASS + FAIL))

echo "========================================"
echo " Validation Summary"
echo "========================================"
echo "Tests run : $TOTAL"
echo "Passed    : $PASS"
echo "Failed    : $FAIL"
echo "========================================"

if [ "$FAIL" -eq 0 ]; then
    echo "RESULT: ALL TESTS PASSED"
    exit 0
else
    echo "RESULT: SOME TESTS FAILED"
    exit 1
fi
