# Ubuntu Server System Health Monitoring Script

## 1. Objective

My objective was to create a Bash script that writes a system health report, test it while my Nginx service was running and stopped, and practice scheduling it with cron.

## 2. Lab Environment

I worked on my Ubuntu Server virtual machine, `jane-sv`, through SSH. I created my script and reports under `~/automation-lab/`:

```text
automation-lab/
├── scripts/
│   └── system-health.sh
└── reports/
    └── health-<timestamp>.txt
```

The reports are snapshots of the server at the time the script runs. They contain system and network information, so I should review them before sharing.

## 3. Commands Practiced

| Command | Purpose |
|---|---|
| `mkdir`, `cd`, `nano` | Prepare the workspace and edit the script. |
| `bash -n`, `chmod`, `./system-health.sh` | Check syntax, allow execution, and run the script. |
| `ls`, `cat`, `du` | Inspect reports and their storage use. |
| `systemctl` | Check cron and stop or start Nginx for the lab test. |
| `crontab` | Configure and inspect my user schedule. |
| `journalctl` | Inspect cron activity. |

## 4. Practical Exercises

### Preparing and Validating the Script

I created the script and report directories, opened the script in `nano`, checked its Bash syntax, and made it executable:

```bash
mkdir -p ~/automation-lab/{scripts,reports}
cd ~/automation-lab/scripts/
nano system-health.sh
bash -n system-health.sh
chmod +x system-health.sh
```

My first syntax check reported an error. I edited the script and ran `bash -n` again; the second check printed no error. A syntax check can find Bash parsing errors, but it does not prove that every command will work when the script runs.

### Bash Concepts

The exercise uses these scripting concepts:

| Concept | Purpose |
|---|---|
| `#!/bin/bash` | Select Bash as the script interpreter when executed directly. |
| Variables and `$(...)` | Store values and capture command output, such as a timestamp. |
| Function and `$1` | Reuse a service check with a service name as its first argument. |
| `if` and exit status | Choose a result based on whether a check succeeds. |
| `for` loop | Repeat a service check for SSH, Nginx, and cron. |
| Redirection | Write command output and errors to a report. |

In Bash, exit status `0` normally means success; a nonzero status means failure or another condition reported by the command. A service check that does not succeed may indicate that the service is inactive or that the check itself failed.

The exercise's grouped output uses `> "$REPORT_FILE" 2>&1` to write standard output and standard error into the report. Its final group status reflects the last command in that group, so a report-generation success message alone does not prove every check succeeded. Timestamped filenames help keep reports from overwriting one another; multiple runs within the same timestamp could still use the same filename.

### Running the Health Check

I ran my script from its directory and inspected the generated report:

```bash
./system-health.sh
ls -lh ~/automation-lab/reports/
cat ~/automation-lab/reports/health-2026-11-27_04-39-31.txt
```

The report included load, memory, disk, network, service, website, and failed-unit sections. These are excerpts from my actual report:

```output
===== SERVICE STATUS =====
ssh: RUNNING
nginx: RUNNING
cron: RUNNING

=== WEBSITE STATUS ===
Webiste: AVAILABLE
```

```output
===== FAILED SYSTEMD UNITS =====
  UNIT LOAD ACTIVE SUB DESCRIPTION

0 loaded units listed.
```

I retained the spelling shown in the report. The network section is omitted here because it contains details specific to my environment.

### Testing a Service Outage and Recovery

I stopped the disposable Nginx service, ran the script, and inspected the new report:

```bash
sudo systemctl stop nginx
./system-health.sh
cat ~/automation-lab/reports/health-2026-11-27_04-40-40.txt
```

The report showed:

```output
===== SERVICE STATUS =====
ssh: RUNNING
nginx: NOT RUNNING
cron: RUNNING

=== WEBSITE STATUS ===
curl: (7) Failed to connect to localhost port 80 after 1 ms: Couldn't connect to server
Website: UNAVAILABLE
```

I then started Nginx, ran the script again, and inspected the recovery report:

```bash
sudo systemctl start nginx
./system-health.sh
cat ~/automation-lab/reports/health-2026-11-27_04-41-43.txt
```

```output
===== SERVICE STATUS =====
ssh: RUNNING
nginx: RUNNING
cron: RUNNING

=== WEBSITE STATUS ===
Webiste: AVAILABLE
```

The simulated outage confirmed that the reports distinguished the stopped-service and recovered states. The website check is a local test; it does not demonstrate access from a remote client.

### Scheduling with Cron

I confirmed that cron was active, edited my user crontab, and inspected it:

```bash
systemctl is-active cron
crontab -e
crontab -l
```

```output
active
```

I initially configured a two-minute schedule and then edited its script path. The second listing contained:

```output
*/2 * * * * /bin/bash /home/jean/automation-lab/scripts/system-health.sh
```

The five schedule fields represent minute, hour, day of month, month, and day of week. `*/2` in the minute field runs the command every two minutes. Later report listings showed new timestamped files at 04:44, 04:46, and 04:48, and the cron journal recorded scheduled commands at 04:46 and 04:48.

I inspected the report directory size and cron logs:

```bash
du -sh ~/automation-lab/reports/
sudo journalctl -u cron -n 15 --no-pager
```

```output
28K     /home/jean/automation-lab/reports/
```

After the test, I edited my crontab again. My final `crontab -l` listing contained the comments but no active scheduled entry. Timestamped reports can accumulate over time when a scheduled job has no retention policy.

## 5. Verification Results

| Check | Recorded result |
|---|---|
| Bash syntax | The second `bash -n` check printed no syntax error. |
| Normal report | The report showed SSH, Nginx, and cron running, with the website available. |
| Simulated outage | After I stopped Nginx, the report showed it was not running and the website was unavailable. |
| Recovery | After I started Nginx, the next report showed it running and the website available. |
| Cron test | New reports appeared at two-minute intervals, and cron logged scheduled executions. |
| Final schedule | My last crontab listing showed no active job. |

## 6. Errors and Troubleshooting

- My first syntax check reported:

  ```output
  system-health.sh: line 42: syntax error near unexpected token `check_service'
  system-health.sh: line 42: `            check_service "$SERVICE"'
  ```

  I reopened the script in `nano` and reran `bash -n`; it printed no error. I then ran the script successfully. The terminal record does not show the edit itself.

- I mistyped `crontab` as `cronatb` and later as `cronatab`. The shell reported that each command was not found. I used the correct `crontab` spelling to list or edit my schedule.
- The report printed `Webiste: AVAILABLE` in its available state. I kept that actual spelling in my output excerpts. The outage report used `Website: UNAVAILABLE`.
- The cron journal reported `No MTA installed, discarding output`. Cron attempted to handle job output, but no mail transfer agent was available to deliver it. The reports were still created during the test.

## 7. What I Learned

I practiced using a script to combine several health checks into a report. I learned that syntax checks and actual execution serve different purposes, and that testing both a service failure and recovery gives me more useful evidence than testing only a healthy system. I also practiced using cron and its logs, and saw why scheduled reports need a plan for storage and output handling.

## 8. References

- Local manual pages: `man bash`, `man systemctl`, `man crontab`, `man 5 crontab`, `man journalctl`, and `man curl`.

---

# Ubuntu Server Automated Backup and Integrity Verification

## 1. Objective

My objective was to practice creating a reusable backup script, validate its inputs, create and verify compressed archives, and test whether I could restore my sample business files.

## 2. Lab Environment

I worked on my Ubuntu Server virtual machine through SSH. I used the sample files under `~/backup-lab/source/` and the backup destination `/mnt/data/backups/automated/`. The backup storage is part of my local lab environment, so it is not an off-site backup.

Before running the script, I checked that the backup filesystem was mounted:

```bash
findmnt --mountpoint /mnt/data
```

```output
TARGET    SOURCE    FSTYPE OPTIONS
/mnt/data /dev/sdb1 ext4   rw,relatime
```

I listed the source files and checked the backup directory permissions. The source contained `config.txt`, `employees.txt`, and `report.txt`; the existing `/mnt/data/backups/` directory was shown with permissions `drwx------`.

## 3. Commands Practiced

| Command | Purpose |
|---|---|
| `findmnt`, `ls` | Check the backup mount, source files, and archive permissions. |
| `nano`, `bash -n`, `chmod` | Edit the script, check its syntax, and make it executable. |
| `./backup.sh`, `echo $?` | Run the script with different inputs and inspect its exit status. |
| `sha256sum` | Check an archive against its recorded SHA256 checksum. |
| `mktemp`, `tar`, `diff` | Create a temporary restore directory, extract an archive, and compare files. |
| `crontab` | Configure and inspect a backup schedule. |

## 4. Practical Exercises

### Script Purpose and Bash Concepts

The exercise uses a script that accepts one source directory, checks the source and backup mount, creates a compressed archive, and generates and checks a SHA256 checksum. The intended usage is:

```bash
./backup.sh <source_directory>
```

The source must be a valid directory, and the backup filesystem must be mounted at `/mnt/data`. I used `~/backup-lab/source/` as my source in this lab.

| Concept | Purpose |
|---|---|
| `$#`, `$1` | Represent the number of arguments and the first argument. |
| `if`, `case` | Make decisions based on conditions and path patterns. |
| `realpath`, `basename`, `dirname` | Resolve a path and separate its directory and final name. |
| `mountpoint -q` | Check whether a path is a mount point without normal output. |
| `umask 077` | Restrict permissions on newly created files and directories. |
| `tar` and `sha256sum` | Create a compressed archive and check its checksum. |
| Exit status | Report success or failure to the calling shell. |

An exit status of `0` normally means success; a nonzero value indicates an error or another condition. A checksum verifies that an archive matches the checksum recorded for it. It does not by itself prove that the correct files were included or that recovery will succeed, so I also tested restoration.

### Syntax Check and Backup Creation

I created my script in `~/automation-lab/scripts/`, checked its syntax, and made it executable:

```bash
nano backup.sh
bash -n backup.sh
chmod +x backup.sh
```

The syntax check printed no error. I then ran the script and checked its exit status:

```bash
./backup.sh ~/backup-lab/source/
echo $?
```

My recorded backup output included:

```output
Backup created successfully.
source-2026-11-27_05-52-42.tar.gz: OK
Integrity verification successful.
Backup operation completed successfully.
```

```output
0
```

I listed the destination and saw both the archive and its checksum file:

```output
total 8.0K
-rw------- 1 jane jane 279 Nov 27 05:52 source-2026-11-27_05-52-42.tar.gz
-rw------- 1 jane jane 100 Nov 27 05:52 source-2026-11-27_05-52-42.tar.gz.sha256
```

The displayed `-rw-------` permissions allow the owner to read and write these files. I ran another successful backup later, producing a second timestamped archive and checksum.

### Testing Input Validation

I checked how the script responded when I omitted the source argument:

```bash
./backup.sh
echo $?
```

```output
Usage: ./backup.sh <source_directory>
1
```

I then tested a directory that did not exist:

```bash
./backup.sh /nonexistent-lab-directory
echo $?
```

```output
Error: Source directory does not exist.
1
```

Finally, I repeated the valid-directory test; the backup and integrity checks reported success and the exit status was `0`.

### Checksum and Restore Test

I selected the second archive, verified its checksum, and extracted it into a temporary directory:

```bash
cd /mnt/data/backups/automated/
ARCHIVE="source-2026-11-27_05-55-12.tar.gz"
sha256sum -c "$ARCHIVE.sha256"
RESTORE_DIR=$(mktemp -d)
tar -xzf "$ARCHIVE" -C "$RESTORE_DIR"
```

```output
source-2026-11-27_05-55-12.tar.gz: OK
```

I compared the restored directory with my source. After correcting an initial variable-quoting error, my comparison printed no differences and returned exit status `0`:

```bash
diff -r ~/backup-lab/source/ "$RESTORE_DIR/source"
echo $?
```

```output
0
```
This comparison checks the restored directory against the source as it existed at the time of the test. Testing a restore is an important part of verifying a backup.

### Scheduling the Backup

I edited my user crontab and listed it with `crontab -l`. The listed entry schedules the backup script for 02:00 each day according to the server's local time, and appends command output and errors to a backup log. My listing showed the entry as active.

The five cron fields describe minute, hour, day of month, month, and day of week. The schedule `0 2 * * *` means 02:00 daily. The server must be running for cron to start the job at that time.

## 5. Verification Results

| Check | Recorded result |
|---|---|
| Backup storage | `/dev/sdb1` was mounted read/write at `/mnt/data`. |
| Syntax | `bash -n backup.sh` printed no error. |
| Valid source | Two runs reported successful backups and checksum verification; each returned `0`. |
| Invalid inputs | A missing argument and a nonexistent directory each returned `1`. |
| Archive permissions | The displayed archive and checksum file had mode `600`. |
| Recovery | The selected checksum matched, extraction was attempted, and the corrected directory comparison returned `0`. |
| Schedule | The user crontab listed an active daily 02:00 entry. |

## 6. Errors and Troubleshooting

- I first wrote the restore comparison with an escaped dollar sign before `RESTORE_DIR`. The shell treated it as a literal name and `diff` reported:

  ```output
  diff: $RESTORE_DIR/source: No such file or directory
  ```

  I corrected the variable reference and reran the comparison; it printed no differences and returned `0`.
- I deliberately ran the script without an argument and with a nonexistent directory to test error handling. It displayed a usage message or directory error and returned status `1` for each test.

## 7. What I Learned

I practiced checking a backup destination, validating inputs, reading exit codes, verifying a checksum, and comparing restored data with the original files. I learned that a backup is more useful when I test recovery, and that scheduled backups need a retention plan so old archives do not accumulate indefinitely. A local backup should also be complemented by an appropriate off-site copy for disaster recovery.

## 8. References

- Local manual pages: `man bash`, `man tar`, `man sha256sum`, `man diff`, `man mktemp`, `man mountpoint`, and `man 5 crontab`.

---

# Ubuntu Server User Management Automation

## 1. Objective

My objective was to practice automating employee account creation, testing input and privilege checks, and verifying account and password settings with disposable lab users.

## 2. Lab Environment

I worked on my Ubuntu Server virtual machine through SSH. I used two disposable accounts, `labemployee01` and `labemployee02`, and a dedicated department group named `labengineering`. Creating accounts and groups requires administrator privileges, so I used `sudo` for the provisioning commands.

## 3. Commands Practiced

| Command | Purpose |
|---|---|
| `nano`, `bash -n`, `chmod` | Edit the script, check its syntax, and make it executable. |
| `sudo ./user-management.sh` | Run the account-provisioning script with administrator privileges. |
| `id`, `getent`, `ls` | Inspect account details, group membership, and the home directory. |
| `passwd -S`, `chage -l` | Inspect password status and aging information. |
| `su`, `whoami`, `pwd`, `groups` | Test an account login and inspect the resulting session. |
| `echo $?` | Inspect the exit status of the immediately preceding command. |

## 4. Practical Exercises

### Script Purpose and Bash Concepts

The exercise describes a script that accepts a username and department, checks administrator privileges and input, and provisions an employee account with an interactive initial password. Its intended usage is:

```text
sudo ./user-management.sh <username> <department>
```

| Concept | Purpose |
|---|---|
| `$EUID` | Identifies the effective user ID used for permission checks; root has ID `0`. |
| `$#`, `$1`, `$2` | Represent the argument count, username, and department. |
| `if`, exit status | Allow the script to choose what to do when checks succeed or fail. |
| Regular expression | Restricts the input to the exercise's naming format. |
| `id`, `getent` | Check whether an account or group exists. |
| `useradd`, `passwd` | Create the account and set an initial password interactively. |

The exercise's naming rule starts with a lowercase letter and permits lowercase letters, digits, underscores, and hyphens in the remaining positions, up to 32 characters in total. Interactive password entry avoids putting a password directly in a command argument or script. I used a dedicated lab group; accepting an existing privileged group would grant its associated privileges, so department names must be chosen carefully.

### Preparing and Running the Script

I opened `user-management.sh` in my automation scripts directory and checked the syntax:

```bash
cd ~/automation-lab/scripts/
nano user-management.sh
bash -n user-management.sh
chmod +x user-management.sh
```

The syntax check printed no error. I created my first lab account:

```bash
sudo ./user-management.sh labemployee01 labengineering
```

The recorded output included:

```output
Department group created: labengineering
Set the initial password for labemployee01
passwd: password updated successfully
passwd: password changed.
Employee account created successfully.
Username: labemployee01
Department: labengineering
uid=1011(labemployee01) gid=1013(labemployee01) groups=1013(labemployee01),1012(labengineering)
```

The password was entered interactively and is not included in my documentation.

### Verifying the First Account

I checked the account, group, home directory, and password status:

```bash
id labemployee01
getent passwd labemployee01
getent group labengineering
sudo ls -ld /home/labemployee01/
sudo passwd -S labemployee01
sudo chage -l labemployee01
```

The account database showed the home directory and Bash login shell:

```output
labemployee01:x:1011:1013::/home/labemployee01:/bin/bash
```

The `x` is a password-field marker; it is not the user's password. The home directory listing showed `drwxr-x---`. My password-aging check showed:

```output
Last password change                                    : password must be changed
Password expires                                        : password must be changed
Password inactive                                       : password must be changed
Account expires                                         : never
Minimum number of days between password change          : 0
Maximum number of days between password change          : 99999
Number of days of warning before password expires       : 7
```

### Testing Input and Privilege Checks

I ran the script without `sudo` and checked the status immediately:

```bash
./user-management.sh labemployee02 labengineering
echo $?
```

```output
Error: Run this script with sudo.
1
```

I also tested missing arguments:

```bash
sudo ./user-management.sh
echo $?
```

```output
Usage: sudo ./user-management.sh <username> <department>
1
```

The script reported that `labemployee01` already existed when I attempted to create it again. It also rejected the invalid username `Invalide User` with:

```output
Error: Invalid username or department.
```

### Reusing the Department Group

I created a second lab account using the existing department group:

```bash
sudo ./user-management.sh labemployee02 labengineering
echo $?
```

The output included:

```output
Department group already exists.
Set the initial password for labemployee02
passwd: password updated successfully
passwd: password changed.
Employee account created successfully.
Username: labemployee02
Department: labengineering
uid=1012(labemployee02) gid=1014(labemployee02) groups=1014(labemployee02),1012(labengineering)
```

```output
0
```

I checked both accounts with `id` and confirmed the department membership:

```bash
getent group labengineering
```

```output
labengineering:x:1012:labemployee01,labemployee02
```

### Testing an Employee Login

I attempted to switch to both accounts. The attempts for `labemployee01` failed authentication. My first attempt for `labemployee02` reached the required password-change prompt but failed with an authentication token manipulation error. On the next attempt I completed the prompts and entered the second account's session. I then checked my identity, home directory, and groups:

```bash
whoami
pwd
id
groups
```

```output
labemployee02
```

```output
/home/labemployee02
```

```output
uid=1012(labemployee02) gid=1014(labemployee02) groups=1014(labemployee02),1012(labengineering)
```

```output
labemployee02 labengineering
```

I used `exit` to return to my administrator session.

## 5. Verification Results

| Check | Recorded result |
|---|---|
| Syntax | `bash -n user-management.sh` printed no error. |
| First account | Account, Bash shell, home directory, and department membership appeared in the account checks. |
| Password policy | `chage` showed that the first account's password had to be changed. |
| Privileges and arguments | The no-sudo and missing-argument tests each displayed an error and returned `1`. |
| Duplicate and invalid input | The script displayed the corresponding error messages. |
| Existing group | The second account was created in `labengineering`; the recorded exit status was `0`. |
| Login | The second account changed its password and entered a shell session. |

## 6. Errors and Troubleshooting

- I mistyped `chmod` as `cdmod`; the shell reported that the command was not found. I then used `chmod +x user-management.sh`.
- After the duplicate-user test, I mistyped `echo $?` as `exho $?`. The following `echo $?` printed `127`, the status of the failed `exho` command. Exit status must be checked immediately after the command I want to evaluate.
- Three `su - labemployee01` attempts returned `su: Authentication failure` becaude i forgot the inital password for `labemployee01`. I solved this problem by creating new initial password for `labemployee01` with `sudo passwd labemployee01`.
- My first `labemployee02` password-change attempt returned `su: Authentication token manipulation error`. A later attempt completed the password prompts and opened the account session; the cause of the earlier error was not established.

## 7. What I Learned

I practiced combining administrator checks, argument validation, group membership, and interactive password setup in an account-provisioning workflow. I learned to check account records and password aging separately from testing an actual login, and to capture an exit status immediately after the command being tested.

## 8. References

- Local manual pages: `man bash`, `man useradd`, `man passwd`, `man chage`, `man id`, `man getent`, and `man su`.
