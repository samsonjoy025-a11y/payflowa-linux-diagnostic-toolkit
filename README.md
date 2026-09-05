# Payflowa Linux Diagnostic Toolkit

> A Bash-based Linux diagnostic automation toolkit designed to quickly identify common server health, disk, and network issues.

## ��� Project Overview

Linux servers can experience problems that are difficult to identify quickly when system information, disk usage, and network connectivity have to be checked manually.

For this project, I built a lightweight **Linux Diagnostic Toolkit using Bash** to automate these first-level diagnostic checks.

The goal was to turn several manual troubleshooting steps into reusable command-line tools that provide clear output, meaningful exit codes, and operational logs.

---

# ��� The Problem

When troubleshooting a Linux server, an engineer may need to manually run several commands to answer basic questions:

* What server am I connected to?
* Which user am I running as?
* What operating system and kernel is being used?
* How long has the server been running?
* How much CPU and memory is available?
* How much disk space is being used?
* Is a particular host reachable?
* Can the server connect to a specific TCP port?
* What network interfaces are configured?
* What happened during the diagnostic check?

Performing these checks manually is:

* Time-consuming
* Repetitive
* Easy to forget
* Difficult to standardize
* Difficult to integrate into automation

For a DevOps environment, these basic diagnostics should be **repeatable and scriptable**.

---

# ��� The Solution

I built the **Payflowa Linux Diagnostic Toolkit**, a collection of Bash scripts that automate common Linux troubleshooting tasks.

The toolkit contains three diagnostic utilities:

```text
                    Linux Server
                         │
                         ▼
              ┌─────────────────────┐
              │ Diagnostic Toolkit  │
              └─────────────────────┘
                    │     │     │
          ┌─────────┘     │     └─────────┐
          ▼               ▼               ▼
   System Information  Disk Check    Network Check
          │               │               │
          ▼               ▼               ▼
     CPU / Memory      Usage %       DNS / Ping / TCP
     OS / Kernel       Threshold     Interfaces
     Uptime            Exit Codes    Connectivity
                    │
                    ▼
              Diagnostic Logs
```

The toolkit provides:

### 1. System Diagnostics

`system-info.sh`

Collects:

* Hostname
* Current user
* Date and time
* Operating system
* Kernel version
* System uptime
* CPU information
* Memory information
* Current working directory

Example:

```bash
./system-info.sh
```

---

### 2. Disk Monitoring

`disk-check.sh`

Checks filesystem usage against a configurable threshold.

Usage:

```bash
./disk-check.sh <threshold> [path]
```

Example:

```bash
./disk-check.sh 80 /
```

If disk usage is below the threshold:

```text
Disk usage for /: 6%
Threshold: 80%
Disk usage is below the threshold.
```

The script uses exit codes to make the result useful for automation:

| Exit Code | Meaning                               |
| --------- | ------------------------------------- |
| `0`       | Disk usage is below threshold         |
| `1`       | Disk usage reached/exceeded threshold |
| `2`       | Invalid input                         |

This means the script can later be integrated into CI/CD pipelines, monitoring systems, or automation tools.

---

### 3. Network Diagnostics

`network-check.sh`

Checks:

* Hostname/IP validation
* DNS/host resolution
* Basic connectivity
* Network interfaces
* Optional TCP port connectivity

Example:

```bash
./network-check.sh google.com 443
```

Example result:

```text
Hostname/IP: google.com
Resolved address: 2a00:1450:4007:81a::200e

Connectivity check:
Connectivity: reachable

Network interfaces:
...

TCP connectivity check: google.com:443
TCP port 443: reachable
```

The script also validates TCP ports and rejects invalid values such as:

```text
abc
0
65536
```

---

# ���️ Engineering Approach

I designed the toolkit around several principles commonly used in production automation.

### Input Validation

Scripts validate user input before attempting operations.

For example:

```bash
if [ "$threshold" -lt 1 ] || [ "$threshold" -gt 100 ]; then
    exit 2
fi
```

This prevents invalid thresholds from being passed into the diagnostic logic.

### Meaningful Exit Codes

The scripts don't only print information—they return meaningful exit statuses.

This allows other automation tools to determine whether a check passed or failed.

For example:

```bash
./disk-check.sh 80 /
echo $?
```

A monitoring or automation system can use that exit code to make decisions.

### Operational Logging

The toolkit records diagnostic operations in:

```text
logs/diagnostic.log
```

Each entry contains a timestamp and description.

Example:

```text
2026-09-05 22:21:31 - Network check started: host=google.com port=443
2026-09-05 22:21:32 - Host resolved successfully
2026-09-05 22:21:34 - Connectivity check: google.com is reachable
2026-09-05 22:21:34 - TCP port 443 on google.com is reachable
```

Runtime logs are excluded from Git using:

```text
logs/*.log
```

in `.gitignore`.

---

# ��� Testing & Validation

I tested the toolkit against both valid and invalid inputs.

### System information

```bash
./system-info.sh
```

Successfully returned system information including:

* Ubuntu 22.04.5 LTS
* Linux kernel version
* CPU information
* Memory usage
* System uptime
* Current user
* Working directory

### Disk check

Valid:

```bash
./disk-check.sh 80 /
```

Invalid threshold:

```bash
./disk-check.sh 101 /
```

Invalid input correctly returns exit code `2`.

### Network check

Valid:

```bash
./network-check.sh google.com 443
```

Invalid port:

```bash
./network-check.sh google.com abc
```

The script correctly rejects non-numeric ports.

---

# ��� Outcome

The project transformed several manual Linux troubleshooting tasks into a reusable command-line diagnostic toolkit.

### Before

An engineer would manually run commands such as:

```bash
hostname
whoami
uname -r
uptime
free -h
df -h
ip addr
ping
```

and then interpret the results individually.

### After

The engineer can run:

```bash
./system-info.sh
```

```bash
./disk-check.sh 80 /
```

```bash
./network-check.sh google.com 443
```

The toolkit provides standardized output, validation, exit codes, and operational logging.

### Engineering outcomes

* ✅ Reduced repetitive manual diagnostic work
* ✅ Standardized common Linux health checks
* ✅ Added input validation
* ✅ Added meaningful exit codes
* ✅ Added operational logging
* ✅ Created reusable Bash automation
* ✅ Designed scripts with future monitoring/CI integration in mind

---

# ��� Git & Version Control

The project was developed using Git with incremental commits.

Development included a dedicated feature branch:

```text
docs/add-project-documentation
```

The feature branch was subsequently merged into `main`.

Example development history:

```text
feat: add system information diagnostic
feat: add disk usage threshold check
feat: add diagnostic logging
docs: add project documentation
merge: integrate remote GitHub history
```

This demonstrates a basic feature-branch workflow rather than committing all changes directly to the main branch.

---

# ��� Project Structure

```text
payflowa-linux-diagnostic-toolkit/
├── README.md
├── system-info.sh
├── disk-check.sh
├── network-check.sh
├── grade.sh
└── logs/
    └── .gitkeep
```

---

# ��� Technologies Used

* Bash
* Linux
* Git
* GitHub
* Vagrant
* SSH
* Standard Linux CLI utilities

---

# ��� DevOps Concepts Demonstrated

This project demonstrates practical experience with:

* Linux administration
* Bash scripting
* Automation
* Input validation
* Exit codes
* System diagnostics
* Disk monitoring
* Network troubleshooting
* TCP connectivity testing
* Logging
* Git version control
* Feature branching
* Git merging
* Remote repository management

---

# ��� Future Improvements

The current implementation is intentionally lightweight, but it provides a foundation for a larger monitoring system.

Potential next versions could include:

### Version 2 — Python

Rewrite the diagnostic engine in Python for more advanced error handling and structured output.

### Version 3 — Docker

Containerize the diagnostic application.

### Version 4 — Prometheus

Expose diagnostic metrics for monitoring.

### Version 5 — Grafana

Build dashboards for visualizing server health.

### Version 6 — Alerting

Integrate alerts through Slack, email, or other notification systems when thresholds are exceeded.

---

# ���‍��� Author

**Joy Samson**

DevOps / Cloud Engineering Portfolio Project

GitHub:

`https://github.com/samsonjoy025-a11y`

