
A chronological record of the development process, problems encountered, troubleshooting steps, commands used, and solutions implemented while building the Payflowa Linux Diagnostic Toolkit.

1. Project Overview
The Payflowa Linux Diagnostic Toolkit is a Bash-based Linux automation project designed to automate common server diagnostic tasks.
The project was developed in a Vagrant Linux environment and version-controlled using Git and GitHub.
The toolkit contains:
payflowa-linux-diagnostic-toolkit/
├── README.md
├── system-info.sh
├── disk-check.sh
├── network-check.sh
├── grade.sh
└── logs/
    └── .gitkeep
The main objectives were to automate:
System information collection
Disk usage monitoring
Network diagnostics
TCP port checks
Input validation
Logging
Meaningful exit codes
Git version control
Feature branching
Merge conflict resolution

2. Development Environment
The project was developed inside a Vagrant Linux virtual machine.
The project directory was:
/home/vagrant/payflowa-linux-diagnostic-toolkit
The shell prompt showed:
vagrant@ubuntu-jammy:~/payflowa-linux-diagnostic-toolkit$
This confirmed that the work was being performed inside the Linux development environment.

3. Git Installation Problem
Problem
When Git was first checked, the system returned:
-bash: git: command not found
The command used was:
git --version
This meant Git was not available in the environment at that point.
Troubleshooting
Git was installed in the Linux environment.
After installation, Git was verified using:
git --version
The result was:
git version 2.52.0
Result
Git was successfully installed and available for repository management.

4. GitHub SSH Authentication
Problem
When connecting to GitHub for the first time using SSH, the terminal displayed:
The authenticity of host 'github.com' can't be established.
The message also displayed GitHub's SSH fingerprint.
Diagnosis
This is expected when an SSH client connects to a server for the first time.
SSH does not yet have the server recorded in the local known-hosts file.
Troubleshooting
The GitHub host fingerprint was reviewed and the connection was accepted.
The SSH connection was then tested with:
ssh -T git@github.com
Result
GitHub SSH authentication was successfully configured.
This allowed Git operations to use an SSH remote instead of repeatedly entering credentials.

5. Configuring the GitHub Remote
The GitHub repository was configured as the origin remote.
The remote was checked using:
git remote -v
The result was:
origin  git@github.com:samsonjoy025-a11y/payflowa-linux-diagnostic-toolkit.git (fetch)
origin  git@github.com:samsonjoy025-a11y/payflowa-linux-diagnostic-toolkit.git (push)
Result
The local repository was correctly connected to GitHub using SSH.

6. Creating the Project Repository
The project was created as:
payflowa-linux-diagnostic-toolkit
The repository eventually contained:
README.md
system-info.sh
disk-check.sh
network-check.sh
grade.sh
logs/
A .gitkeep file was placed inside logs/ so Git could track the directory even before runtime logs were generated.

7. System Information Script
The first diagnostic script implemented was:
system-info.sh
The script was designed to collect:
Hostname
Current user
Date/time
Operating system
Kernel version
Uptime
CPU information
Memory information
Current working directory
Important Linux commands used included:
hostname
whoami
date
uname -r
uptime -p
lscpu
free -h
pwd
Testing
The script was executed using:
./system-info.sh
The output successfully showed information including:
Hostname: ubuntu-jammy
Current User: vagrant
Operating System: Ubuntu 22.04.5 LTS
Kernel Version: 5.15.0-173-generic
It also displayed CPU, memory, uptime, and working-directory information.
Result
The system information requirement was successfully implemented and tested.

8. Disk Check Script
The next script implemented was:
disk-check.sh
The required usage was:
./disk-check.sh <threshold> [path]
The default path was:
/
The threshold needed to be an integer from:
1 to 100

9. Disk Threshold Input Problem
A diagnostic script should not blindly trust user input.
The script therefore needed to reject:
Missing thresholds
Non-numeric thresholds
Values below 1
Values above 100
Missing threshold
The script checks:
if [ -z "$threshold" ]; then
If no threshold is supplied, it displays an error and exits with:
2
Usage:
./disk-check.sh

10. Invalid Disk Threshold
The script validates that the threshold contains only digits.
The validation uses:
if ! [[ "$threshold" =~ ^[0-9]+$ ]]; then
For example:
./disk-check.sh abc /
is rejected.
The script exits with:
2
This represents invalid input.

11. Disk Threshold Range Validation
The threshold is also checked against the required range.
The command logic is:
if [ "$threshold" -lt 1 ] || [ "$threshold" -gt 100 ]; then
This prevents values such as:
0
101
from being accepted.
Example:
./disk-check.sh 101 /
returns an error and exit code 2.

12. Disk Usage Calculation
The script uses:
df -P "$path"
to obtain filesystem information.
awk extracts the usage percentage:
awk 'NR==2 {print $5}'
The % character is removed using:
tr -d '%'
The resulting value is stored in:
usage

13. Disk Check Testing
The script was tested with:
./disk-check.sh 80 /
The result was:
Disk usage for /: 6%
Threshold: 80%
Disk usage is below the threshold.
The script correctly returned success because:
6% < 80%

14. Disk Exit Codes
Meaningful exit codes were implemented.
0 = Disk usage is below threshold
1 = Disk usage reached or exceeded threshold
2 = Invalid input
This is important for automation.
Another script, monitoring system, or CI/CD pipeline can use:
echo $?
to determine whether the diagnostic passed or failed.

15. Default Disk Path
The assignment allowed the path to be optional.
The script therefore checks:
if [ -z "$path" ]; then
    path="/"
fi
This means:
./disk-check.sh 80
automatically checks:
/
instead of requiring the user to type the path.

16. Invalid Disk Path
The script also checks whether the specified path exists.
The validation uses:
if [ ! -d "$path" ]; then
If the path does not exist, the script reports the problem and exits with:
2
This prevents the script from continuing with an invalid filesystem location.

17. Network Diagnostic Script
The third major diagnostic script was:
network-check.sh
Required usage:
./network-check.sh <hostname-or-ip> [port]
The script performs:
Host validation
Host resolution
Connectivity testing
Network interface display
Optional TCP port testing

18. Missing Network Host
The script checks whether a hostname or IP address was provided.
If the user runs:
./network-check.sh
the script returns an error instead of continuing.
It displays the expected usage:
Usage: ./network-check.sh <hostname-or-ip> [port]
and exits with:
2

19. Network Host Validation
The script validates the host using:
if ! [[ "$host" =~ ^[a-zA-Z0-9.-]+$ ]]; then
This prevents obviously malformed hostname/IP input from being passed into the diagnostic operations.

20. Host Resolution
The script uses:
getent hosts "$host"
to resolve the target.
The resolved address is extracted using:
awk '{print $1}'
and:
head -1
is used to select the first result.
Example:
./network-check.sh google.com
can return a resolved address.

21. Network Connectivity Testing
The script performs a basic connectivity check using:
ping -c 1 -W 2 "$host"
The options mean:
-c 1
send one ping.
-W 2
wait up to two seconds for the response.
The script then reports either:
Connectivity: reachable
or:
Connectivity: unreachable

22. Network Interface Diagnostics
The script displays the system's network interfaces using:
ip addr
This provides information such as:
Interface names
IP addresses
MAC addresses
Interface state
This is useful during Linux network troubleshooting.

23. TCP Port Testing
The script supports an optional port.
Example:
./network-check.sh google.com 443
The script checks TCP connectivity using:
timeout 5 bash -c "</dev/tcp/$host/$port"
This allows the diagnostic tool to determine whether a TCP service is reachable.

24. Invalid Network Port
A problem that needed to be handled was invalid port input.
For example:
./network-check.sh google.com abc
The script correctly returned:
Error: port must be numeric.
The port validation uses:
if ! [[ "$port" =~ ^[0-9]+$ ]]; then
Invalid ports return:
2

25. TCP Port Range Validation
TCP ports must be between:
1
and:
65535
The script validates this using:
if [ "$port" -lt 1 ] || [ "$port" -gt 65535 ]; then
This prevents invalid values such as:
0
65536
from being accepted.

26. Network Script Testing
The network diagnostic was tested with:
./network-check.sh google.com 443
The script successfully returned:
Hostname/IP: google.com
Resolved address: ...
Connectivity: reachable
It also displayed network interfaces.
The TCP test reported:
TCP port 443: reachable
This confirmed that DNS resolution, connectivity testing, interface inspection, and TCP port checking were functioning.

27. Logging Requirement
The project required diagnostic operations to be logged.
A logging function was added to the scripts:
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}
The log file is:
logs/diagnostic.log
Each entry contains:
timestamp - operation description
Example:
2026-09-05 22:17:14 - Disk check started: threshold=80 path=/
2026-09-05 22:17:14 - Disk usage for /: 6%
2026-09-05 22:17:14 - Disk usage is below threshold: usage=6 threshold=80

28. Runtime Log Management
Runtime logs should not be committed to Git because they are generated by the scripts.
A .gitignore rule was added:
logs/*.log
This means:
logs/diagnostic.log
remains local while:
logs/.gitkeep
allows Git to track the directory.

29. Temporary Logging File
During development, a temporary file was created:
logs/logger.sh
After determining that logging functionality could be embedded directly inside the diagnostic scripts, the temporary file was removed.
Command used:
rm logs/logger.sh
This kept the project structure clean and avoided unnecessary files.

30. Executable Permission Problem
Bash scripts need executable permissions when they are intended to be run as:
./script-name.sh
The permissions were corrected using:
chmod +x system-info.sh disk-check.sh network-check.sh
After this, the scripts could be executed directly.

31. Git Commit History
The project was developed using multiple meaningful Git commits rather than one large commit.
The history included:
feat: add system information diagnostic
feat: add disk usage threshold check
feat: add diagnostic logging
This made it easier to identify what functionality was added at each stage.

32. Feature Branch Requirement
The assignment required at least one feature branch.
A documentation branch was created:
docs/add-project-documentation
The README work was committed on that branch.
The commit message was:
docs: add project documentation
This demonstrated a feature-branch workflow.

33. Git Branch Merge
After the documentation work, the feature branch was merged into main.
The branch history showed:
docs/add-project-documentation
containing the documentation commit.
The feature branch was then merged into:
main

34. Git Unrelated Histories Problem
A significant Git problem occurred when the local repository and the remote GitHub repository had different histories.
A normal merge was not sufficient because Git considered the histories unrelated.
The solution was:
git merge origin/main --allow-unrelated-histories
The --allow-unrelated-histories option tells Git that the two repository histories should be combined even though they do not share a common ancestor.

35. README Merge Conflict
After allowing the unrelated histories to merge, Git reported a conflict involving:
README.md
The conflict happened because both the local repository and the remote repository contained a README.
Git could not automatically decide which version should be kept.

36. Resolving the README Conflict
The local version of the README was selected using:
git checkout --ours README.md
The resolved file was then staged:
git add README.md
The merge was completed with:
git commit -m "merge: integrate remote GitHub history"
This created the merge commit:
19db852

37. Pushing the Merge to GitHub
After resolving the conflict, the changes were pushed:
git push
The push completed successfully.
The remote branch was updated:
main -> main
The local main branch was also configured to track:
origin/main

38. Verifying the Git Repository
The repository status was checked with:
git status
At one point, the repository correctly reported:
On branch main
Your branch is up to date with 'origin/main'.

nothing to commit, working tree clean
This confirmed that there were no uncommitted changes at that point.

39. README Filename Problem
While updating the portfolio documentation, the wrong filename was accidentally opened:
vim Readme.md
The correct project filename is:
README.md
Linux is case-sensitive.
Therefore:
README.md
and:
Readme.md
are different files.

40. Fixing the Incorrect README Filename
Because Readme.md was accidentally created and saved, it was removed with:
rm Readme.md
The correct file was then opened with:
vim README.md
This ensured that the project continued using the standard:
README.md
filename.

41. README Portfolio Upgrade
The original README was intended primarily to satisfy the project requirements.
It was then redesigned as a portfolio-quality README.
The new documentation explains:
What the project does
The problem being solved
The solution
The architecture
Individual scripts
Engineering decisions
Input validation
Exit codes
Logging
Testing
Git workflow
Project structure
Technologies
DevOps concepts
Future improvements
The purpose was to make the repository understandable to a recruiter or hiring manager.

42. Staging the README
After updating the README, Git status showed:
Changes to be committed:

modified: README.md
This meant the README had already been staged.
The command used to stage it was:
git add README.md
The next step was to commit the updated documentation.
The planned commit message was:
git commit -m "docs: improve project portfolio documentation"
followed by:
git push

43. Git Commands Used Throughout the Project
The following Git commands were used during development.
Check Git installation
git --version
Check repository status
git status
View remote repositories
git remote -v
Create a branch
git checkout -b docs/add-project-documentation
Switch branches
git checkout main
Stage a file
git add README.md
Stage all changes
git add .
Commit changes
git commit -m "commit message"
Merge remote history
git merge origin/main --allow-unrelated-histories
Resolve using the local version
git checkout --ours README.md
Push changes
git push
View commit history
git log --oneline --graph --all

44. Linux Commands Used
Several standard Linux commands were used during development.
File listing
ls
Detailed file listing
ls -l
Display file contents
cat README.md
Edit a file
vim README.md
Delete a file
rm Readme.md
Make scripts executable
chmod +x system-info.sh disk-check.sh network-check.sh
Check disk usage
df -h
Extract information
awk
Check network interfaces
ip addr
Test connectivity
ping
Resolve hosts
getent hosts

45. Troubleshooting Method Used
The project followed a basic troubleshooting process:
Problem
   ↓
Read the error
   ↓
Identify the likely cause
   ↓
Run a diagnostic command
   ↓
Apply the smallest appropriate fix
   ↓
Run the command again
   ↓
Verify the result
For example:
git: command not found
        ↓
Git unavailable
        ↓
Install Git
        ↓
git --version
        ↓
git version 2.52.0
        ↓
Problem solved
Another example:
README merge conflict
        ↓
Both repositories contained README.md
        ↓
Choose correct README
        ↓
git checkout --ours README.md
        ↓
git add README.md
        ↓
git commit
        ↓
Merge completed

46. Key Problems and Solutions
Problem
Diagnostic/Fix Command
Solution
Git not found
git --version
Installed Git
GitHub first SSH connection warning
ssh -T git@github.com
Verified/accepted SSH host
Wrong GitHub remote/history
git remote -v
Configured SSH remote
Unrelated Git histories
git merge origin/main --allow-unrelated-histories
Combined histories
README merge conflict
git checkout --ours README.md
Kept correct README
Scripts not executable
chmod +x ...
Added executable permissions
Invalid disk threshold
Script validation
Added numeric/range validation
Invalid disk path
Script validation
Added path existence check
Invalid network port
Script validation
Added numeric/range validation
Runtime logs tracked by Git
.gitignore
Added logs/*.log
Temporary logger unnecessary
rm logs/logger.sh
Removed unnecessary file
Wrong README capitalization
rm Readme.md
Restored correct README.md


47. Current Git Workflow
The project follows:
Local Development
       │
       ▼
Feature Branch
       │
       ▼
Test Changes
       │
       ▼
Commit
       │
       ▼
Merge into main
       │
       ▼
Push to GitHub
       │
       ▼
Verify git status
This is a basic but practical Git workflow for DevOps projects.

48. Current Project Status
Completed:
Git installed
GitHub SSH configured
Git remote configured
Repository created
system-info.sh
disk-check.sh
network-check.sh
Input validation
Exit codes
Logging
.gitignore
Executable permissions
Feature branch
Git merge
Merge conflict resolution
GitHub push
Portfolio README
Remaining:
Complete grade.sh
Run final end-to-end tests
Verify all required permissions
Verify Git history requirements
Commit final changes
Push final version to GitHub

49. Final Engineering Lessons
The most important lessons from this project were not just the Bash commands.
The project provided practical experience with:
Linux
Understanding how to inspect:
CPU
Memory
Disk
Network
Processes and system information
Bash
Learning how to:
Accept arguments
Validate input
Use conditions
Capture command output
Return exit codes
Create reusable functions
Log operations
Git
Learning how to:
Create commits
Use branches
Merge branches
Resolve conflicts
Configure remotes
Push to GitHub
Understand repository history
Troubleshooting
Learning to:
Read error messages
Identify root causes
Test assumptions
Apply fixes
Verify the result
DevOps
The project demonstrated the principle of turning manual operational work into repeatable automation.

50. Conclusion
The Payflowa Linux Diagnostic Toolkit began as a Bash scripting assignment but evolved into a practical DevOps learning project.
During development, several real-world problems were encountered, including:
Missing software
SSH host verification
Git history conflicts
Merge conflicts
File permission issues
Invalid user input
Runtime log management
Linux filename case sensitivity
Each issue was investigated, corrected, and verified using Linux and Git commands.
The result is a reusable diagnostic toolkit that demonstrates practical skills in:
Linux
  +
Bash
  +
Automation
  +
Networking
  +
Monitoring
  +
Logging
  +
Git
  +
GitHub
  +
Troubleshooting

