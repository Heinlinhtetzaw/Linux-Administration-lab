# Linux File Viewing and Text Processing

## 1. Objective

My objective was to practice viewing, searching, counting, sorting, and extracting text from files in Ubuntu WSL2. I created a simulated server log and service list so I could practice safely without modifying real system logs.

## 2. Lab Environment

I created my text-processing lab inside my existing `~/linux-fundamentals-lab` workspace:

```bash
mkdir text-processing-lab
```

My lab contained these sample files:

- `text-processing-lab/server.log` — a simulated server log with ten entries.
- `text-processing-lab/services.txt` — a sample list of service names, including duplicates.

The entries in `server.log` are simulated practice events. They are not evidence of real incidents on my system.

## 3. Commands Practiced

| Command | Purpose | Example |
|---|---|---|
| `cat` | Displays file contents. | `cat text-processing-lab/server.log` |
| `less` | Opens a file in a scrollable viewer. | `less /etc/services` |
| `head` | Displays the beginning of a file. | `head -n 3 server.log` |
| `tail` | Displays the end of a file or follows changes. | `tail -f text-processing-lab/server.log` |
| `grep` | Searches for matching text. | `grep "ERROR" text-processing-lab/server.log` |
| `wc` | Counts lines, words, or bytes. | `wc -l text-processing-lab/server.log` |
| `sort` | Sorts lines of text. | `sort text-processing-lab/services.txt` |
| `uniq` | Removes or counts adjacent duplicate lines. | `sort services.txt \| uniq -c` |
| `cut` | Extracts fields from each line. | `cut -d ':' -f 1 /etc/passwd` |
| `tr` | Translates or removes characters. | `echo "linux" \| tr '[:lower:]' '[:upper:]'` |
| `awk` | Processes text by fields. | `awk '{print $3}' server.log` |
| `sed` | Displays or edits text as a stream. | `sed 's/ERROR/CRITICAL/g' server.log` |


## 4. Practical Lab Setup

### Simulated Server Log

I created `text-processing-lab/server.log` and verified that it existed:

```output
-rw-r--r-- 1 heinlinhtetzaw generaluser 470 Nov 24 09:24 text-processing-lab/server.log
```

I displayed the file with `cat`:

```bash
cat text-processing-lab/server.log
```

```output
2026-11-24 08:00:01 INFO SSH service started
2026-11-24 08:01:05 INFO User alice logged in
2026-11-24 08:02:10 WARNING Disk usage reached 80%
2026-11-24 08:03:15 ERROR SSH authentication failed
2026-11-24 08:04:20 INFO User bob logged in
2026-11-24 08:05:25 ERROR Database connection failed
2026-11-24 08:06:30 WARNING High memory usage
2026-11-24 08:07:35 INFO Backup completed
2026-11-24 08:08:40 ERROR Permission denied
2026-11-24 08:09:45 INFO User alice logged out
```

I also numbered each entry with:

```bash
cat -n text-processing-lab/server.log
```

```output
     1  2026-11-24 08:00:01 INFO SSH service started
     2  2026-11-24 08:01:05 INFO User alice logged in
     3  2026-11-24 08:02:10 WARNING Disk usage reached 80%
     4  2026-11-24 08:03:15 ERROR SSH authentication failed
     5  2026-11-24 08:04:20 INFO User bob logged in
     6  2026-11-24 08:05:25 ERROR Database connection failed
     7  2026-11-24 08:06:30 WARNING High memory usage
     8  2026-11-24 08:07:35 INFO Backup completed
     9  2026-11-24 08:08:40 ERROR Permission denied
    10  2026-11-24 08:09:45 INFO User alice logged out
```

### Sample Service List

I created `text-processing-lab/services.txt` with these service names:

```text
ssh
nginx
cron
ssh
apache2
nginx
ssh
cron
mysql
```

This file let me practice sorting, removing duplicates, and counting repeated service names.

## 5. File Viewing Exercises

### `cat` and `less`

I used `cat` to display my simulated server log:

```bash
cat text-processing-lab/server.log
```

I used `cat -n` to display the same file with line numbers. I also used `cat -n /etc/passwd` to view local account entries with line numbers.

I displayed these system information files:

```bash
cat /etc/os-release
cat /etc/hostname
```

```output
PRETTY_NAME="Ubuntu 24.04.5 LTS"
NAME="Ubuntu"
VERSION_ID="24.04"
VERSION="24.04.5 LTS (Noble Numbat)"
VERSION_CODENAME=noble
ID=ubuntu
ID_LIKE=debian
HOME_URL="https://www.ubuntu.com/"
SUPPORT_URL="https://help.ubuntu.com/"
BUG_REPORT_URL="https://bugs.launchpad.net/ubuntu/"
PRIVACY_POLICY_URL="https://www.ubuntu.com/legal/terms-and-policies/privacy-policy"
UBUNTU_CODENAME=noble
LOGO=ubuntu-logo
heinhtet-sv
```

I opened both my simulated log and `/etc/services` using `less`:

```bash
less text-processing-lab/server.log
less /etc/services
```

### `head` and `tail`

`head` displays the beginning of a file and `tail` displays the end of a file. Both normally show ten lines when I do not provide an option.

```bash
head -n 3 server.log
tail -n 3 server.log
```

I did not record `head`, `tail`, or their `-n` options in my terminal output.

### Real-Time Log Monitoring

I tested both follow modes with my simulated log:

```bash
tail -f text-processing-lab/server.log
tail -F text-processing-lab/server.log
```

Both commands displayed the ten current simulated log entries. I stopped each command with `Ctrl + C`.

```output
2026-11-24 08:00:01 INFO SSH service started
2026-11-24 08:01:05 INFO User alice logged in
2026-11-24 08:02:10 WARNING Disk usage reached 80%
2026-11-24 08:03:15 ERROR SSH authentication failed
2026-11-24 08:04:20 INFO User bob logged in
2026-11-24 08:05:25 ERROR Database connection failed
2026-11-24 08:06:30 WARNING High memory usage
2026-11-24 08:07:35 INFO Backup completed
2026-11-24 08:08:40 ERROR Permission denied
2026-11-24 08:09:45 INFO User alice logged out
^C
```

`tail -f` follows the file that is currently open. `tail -F` follows the file name and can continue after a file is replaced, which is useful for logs that are rotated.


## 6. Text Processing Exercises

### Pattern Matching with `grep`

I searched my simulated log for error entries:

```bash
grep "ERROR" text-processing-lab/server.log
```

```output
2026-11-24 08:03:15 ERROR SSH authentication failed
2026-11-24 08:05:25 ERROR Database connection failed
2026-11-24 08:08:40 ERROR Permission denied
```

I used case-insensitive matching:

```bash
grep -i "error" text-processing-lab/server.log
```

```output
2026-11-24 08:03:15 ERROR SSH authentication failed
2026-11-24 08:05:25 ERROR Database connection failed
2026-11-24 08:08:40 ERROR Permission denied
```

I displayed line numbers with:

```bash
grep -n "ERROR" text-processing-lab/server.log
```

```output
4:2026-11-24 08:03:15 ERROR SSH authentication failed
6:2026-11-24 08:05:25 ERROR Database connection failed
9:2026-11-24 08:08:40 ERROR Permission denied
```

I used `grep -c` to count the simulated error entries:

```bash
grep -c "ERROR" text-processing-lab/server.log
```

```output
3
```

I tested inverted matching. My first command searched for lowercase `error`:

```bash
grep -v "error" text-processing-lab/server.log
```

Because my simulated log contains uppercase `ERROR`, this case-sensitive search did not match any line and printed all ten lines:

```output
2026-11-24 08:00:01 INFO SSH service started
2026-11-24 08:01:05 INFO User alice logged in
2026-11-24 08:02:10 WARNING Disk usage reached 80%
2026-11-24 08:03:15 ERROR SSH authentication failed
2026-11-24 08:04:20 INFO User bob logged in
2026-11-24 08:05:25 ERROR Database connection failed
2026-11-24 08:06:30 WARNING High memory usage
2026-11-24 08:07:35 INFO Backup completed
2026-11-24 08:08:40 ERROR Permission denied
2026-11-24 08:09:45 INFO User alice logged out
```

I then used the correct uppercase pattern:

```bash
grep -v "ERROR" text-processing-lab/server.log
```

```output
2026-11-24 08:00:01 INFO SSH service started
2026-11-24 08:01:05 INFO User alice logged in
2026-11-24 08:02:10 WARNING Disk usage reached 80%
2026-11-24 08:04:20 INFO User bob logged in
2026-11-24 08:06:30 WARNING High memory usage
2026-11-24 08:07:35 INFO Backup completed
2026-11-24 08:09:45 INFO User alice logged out
```

I also used fixed-string matching:

```bash
grep -F "ERROR" text-processing-lab/server.log
```

```output
2026-11-24 08:03:15 ERROR SSH authentication failed
2026-11-24 08:05:25 ERROR Database connection failed
2026-11-24 08:08:40 ERROR Permission denied
```

I searched the real `/etc/passwd` file with these commands:

```bash
grep "^root:" /etc/passwd
grep "/bin/bash$" /etc/passwd
```

```output
root:x:0:0:root:/root:/bin/bash
root:/bin/bash
heinlinhtetzaw:/bin/bash
jone:/bin/bash
alice:/bin/bash
bob:/bin/bash
```

### Counting with `wc`

I counted local account, group, and simulated-log entries:

```bash
wc -l /etc/passwd
wc -l /etc/group
wc -l text-processing-lab/server.log
wc -w text-processing-lab/server.log
```

```output
32 /etc/passwd
63 /etc/group
10 text-processing-lab/server.log
62 text-processing-lab/server.log
```

The line count in `/etc/passwd` represents local account entries, including system accounts. It does not mean there are 32 human users.

### Sorting and Duplicate Processing

I sorted my sample service list:

```bash
sort text-processing-lab/services.txt
sort -r text-processing-lab/services.txt
sort -u text-processing-lab/services.txt
```

The recorded output below is in the same order as the three commands above: normal sort, reverse sort, and unique sort.

```output
apache2
cron
cron
mysql
nginx
nginx
ssh
ssh
ssh

ssh
ssh
ssh
nginx
nginx
mysql
cron
cron
apache2

apache2
cron
mysql
nginx
ssh
```

I used `uniq` on the original file:

```bash
uniq text-processing-lab/services.txt
```

```output
ssh
nginx
cron
ssh
apache2
nginx
ssh
cron
mysql
```

Duplicates remained because `uniq` only removes duplicate lines that are next to each other.

I sorted the list before using `uniq`:

```bash
sort text-processing-lab/services.txt | uniq
sort text-processing-lab/services.txt | uniq -c
```

```output
apache2
cron
mysql
nginx
ssh

      1 apache2
      2 cron
      1 mysql
      2 nginx
      3 ssh
```

### Field Extraction with `cut`

I used `cut` with `:` as the delimiter to read fields from `/etc/passwd`:

```bash
cut -d ':' -f 1 /etc/passwd
cut -d ':' -f 1,3 /etc/passwd
cut -d ':' -f 1,7 /etc/passwd
```

These commands displayed:

- usernames
- usernames with user IDs (UIDs)
- usernames with login shells

`-d ':'` tells `cut` to use a colon as the field separator. `-f` chooses the field numbers that I want to display.

### Introduction to `tr`, `awk`, and `sed`

I converted lowercase text to uppercase with `tr`:

```bash
echo "linux administration" | tr '[:lower:]' '[:upper:]'
```

My output was:

```output
LINUX ADMINISTRATION
```

I used `awk` to print the third whitespace-separated field from my simulated log:

```bash
awk '{print $3}' text-processing-lab/server.log
```

```output
INFO
INFO
WARNING
ERROR
INFO
ERROR
WARNING
INFO
ERROR
INFO
```

I also used `awk` with `:` as the separator for `/etc/passwd`:

```bash
awk -F ':' '{print $1, $3}' /etc/passwd
```

This displayed each username and UID.

I used `sed` to display the simulated log with `ERROR` replaced by `CRITICAL`:

```bash
sed 's/ERROR/CRITICAL/g' text-processing-lab/server.log
```

```output
2026-11-24 08:00:01 INFO SSH service started
2026-11-24 08:01:05 INFO User alice logged in
2026-11-24 08:02:10 WARNING Disk usage reached 80%
2026-11-24 08:03:15 CRITICAL SSH authentication failed
2026-11-24 08:04:20 INFO User bob logged in
2026-11-24 08:05:25 CRITICAL Database connection failed
2026-11-24 08:06:30 WARNING High memory usage
2026-11-24 08:07:35 INFO Backup completed
2026-11-24 08:08:40 CRITICAL Permission denied
2026-11-24 08:09:45 INFO User alice logged out
```

I confirmed afterward that the original file still contained `ERROR`, so the command did not modify my source file.

## 7. Real System Investigation

I investigated authentication failures in my real system log with:

```bash
sudo grep -i "failure" /var/log/auth.log
```

```output
2026-11-22T14:45:14.943330+06:30 heinhtet-sv sudo: pam_unix(sudo:auth): authentication failure; logname= uid=1000 euid=0 tty=/dev/pts/0 ruser=heinlinhtetzaw rhost=  user=heinlinhtetzaw
2026-11-24T09:37:57.323264+06:30 heinhtet-sv sudo: pam_unix(sudo:auth): authentication failure; logname= uid=1000 euid=0 tty=/dev/pts/0 ruser=heinlinhtetzaw rhost=  user=heinlinhtetzaw
2026-11-24T09:38:04.867970+06:30 heinhtet-sv sudo: heinlinhtetzaw : TTY=pts/0 ; PWD=/home/heinlinhtetzaw/linux-fundamentals-lab ; USER=root ; COMMAND=/usr/bin/grep -i failure /var/log/auth.log
```

Unlike `server.log`, `/var/log/auth.log` is a real system log. I treated its contents as actual system information and did not describe it as simulated data.

## 8. Practical Assessment and Verification

I completed and captured evidence for the following tasks:

- I created the `text-processing-lab` directory.
- I created and verified a ten-line simulated server log.
- I used `cat` and `cat -n` to view files and line numbers.
- I viewed `/etc/passwd`, `/etc/os-release`, and `/etc/hostname`.
- I opened my simulated log and `/etc/services` with `less`.
- I used `tail -f` and `tail -F` on the simulated log.
- I used `grep` to search, count, invert, and number simulated log matches.
- I used `grep` to check entries in `/etc/passwd` and a real authentication log.
- I used `wc` to count lines and words.
- I used `sort` and `uniq` to sort and count duplicate service names.
- I used `cut` and `awk` to extract account fields from `/etc/passwd`.
- I used `tr` to change text to uppercase.
- I used `sed` to replace text in displayed output without modifying the simulated log file.

## 9. Errors and Troubleshooting

### Incorrect Path for `server.log`

I first ran:

```bash
ls -lh server.log
```

Linux returned an error because I was in `~/linux-fundamentals-lab`, while the file was inside `text-processing-lab`.

```output
ls: cannot access 'server.log': No such file or directory
```

I corrected the path:

```bash
ls -lh text-processing-lab/server.log
```

```output
-rw-r--r-- 1 heinlinhtetzaw generaluser 470 Nov 24 09:24 text-processing-lab/server.log
```

### Case-Sensitive `grep -v`

I first used:

```bash
grep -v "error" text-processing-lab/server.log
```

My log entries use uppercase `ERROR`, so lowercase `error` did not match. I corrected the command by using uppercase `ERROR`.


## 10. What I Learned

- I learned that `cat` is useful for quickly viewing small files.
- I learned that `less` is better for navigating larger files.
- I learned that `tail -f` and `tail -F` can monitor log files, while `tail -F` is better when a log file might be replaced.
- I learned that `grep` can search, count, and exclude matching lines.
- I learned that `wc` can count lines and words.
- I learned that I should sort text before using `uniq` when I want to remove or count all duplicate values.
- I learned that `cut` and `awk` can extract fields from structured text such as `/etc/passwd`.
- I learned that `sed` can change displayed output without changing the original file when I do not use `-i`.
- I learned to pay attention to my current directory and use the correct relative path.
- I learned that simulated logs and real system logs must be documented different location  in order to learn safely.

## References
- My Ubuntu WSL2 terminal output.
- Local Ubuntu files used for practice: `/etc/passwd`, `/etc/os-release`, `/etc/hostname`, `/etc/services`, and `/var/log/auth.log`.
