# Linux Pipes, Redirection and Standard Streams

## 1. Objective

My objective was to understand how Linux commands receive input, display normal output, and display error messages. I practiced redirection, pipes, `tee`, `/dev/null`, here documents, here strings, and `pipefail` in Ubuntu WSL2.

## 2. Lab Environment

I created a practice directory inside my existing `~/linux-fundamentals-lab` workspace:

```bash
mkdir streams-and-redirection-lab
```

I copied the simulated log and service-list files from my Lesson 04 workspace:

```bash
cp text-processing-lab/server.log streams-and-redirection-lab/
cp text-processing-lab/services.txt streams-and-redirection-lab/
```

I first typed the source file name incorrectly as `servic.log`. Linux returned an error, so I corrected the command and copied `services.txt`.

```output
cp: cannot stat 'text-processing-lab/servic.log': No such file or directory
```

I verified my current location and the copied files:

```bash
pwd
ls -lh streams-and-redirection-lab/
```

```output
/home/heinlinhtetzaw/linux-fundamentals-lab
total 8.0K
-rw-r--r-- 1 heinlinhtetzaw generaluser 470 Nov 24 10:52 server.log
-rw-r--r-- 1 heinlinhtetzaw generaluser  48 Nov 24 10:53 services.txt
```

The `server.log` file in this lab contains simulated events from Lesson 04. It is not a real production log.

## 3. Standard Streams

Linux programs normally use three standard streams.

| Stream | File descriptor | Normal terminal connection |
|---|---:|---|
| Standard input (`stdin`) | `0` | Keyboard |
| Standard output (`stdout`) | `1` | Terminal |
| Standard error (`stderr`) | `2` | Terminal |

### Standard Input (`stdin`)

Standard input is the data a command receives. It usually comes from my keyboard, but I can also send a file or a string to a command with input redirection.

Example from this lab:

```bash
wc -l < streams-and-redirection-lab/server.log
```

### Standard Output (`stdout`)

Standard output is the normal result of a command. By default, it appears in my terminal. I can redirect it into a file with `>` or `>>`.

### Standard Error (`stderr`)

Standard error is used for error and diagnostic messages. It also appears in my terminal by default, but I can redirect it separately with `2>`.

### File Descriptors

I inspected the file descriptors of my current Bash shell:

```bash
ls -l /proc/$$/fd
```

```output
total 0
lrwx------ 1 heinlinhtetzaw generaluser 64 Nov 24 10:48 0 -> /dev/pts/0
lrwx------ 1 heinlinhtetzaw generaluser 64 Nov 24 10:48 1 -> /dev/pts/0
lrwx------ 1 heinlinhtetzaw generaluser 64 Nov 24 10:48 2 -> /dev/pts/0
lrwx------ 1 heinlinhtetzaw generaluser 64 Nov 24 10:48 255 -> /dev/pts/0
```

This showed that my `stdin`, `stdout`, and `stderr` file descriptors were all connected to my terminal at `/dev/pts/0`. My shell also had file descriptor `255` open.

## 4. Redirection Operators

### Output Redirection

I used `>` to send normal command output to a file:

```bash
date > streams-and-redirection-lab/report.txt
cat streams-and-redirection-lab/report.txt
```

```output
Tue Nov 24 10:53:44 +0630 2026
```

The `>` operator creates a file if needed and replaces its previous content.

I tested overwriting the same file:

```bash
echo "First repot" > streams-and-redirection-lab/report.txt
cat streams-and-redirection-lab/report.txt

echo "Second report" > streams-and-redirection-lab/report.txt
cat streams-and-redirection-lab/report.txt
```

```output
First repot
Second report
```

The second command replaced the first file content. The first message contains my recorded spelling mistake, `repot`.

### Append Redirection

I used `>>` to add lines to the end of a file without replacing the existing content:

```bash
echo "First entry" > streams-and-redirection-lab/events.txt
echo "Second entry" >> streams-and-redirection-lab/events.txt
echo "Third entry" >> streams-and-redirection-lab/events.txt
cat streams-and-redirection-lab/events.txt
```

```output
First entry
Second entry
Third entry
```

### Error Redirection

I ran a command that produced both normal output and an error:

```bash
ls /etc/hostname /nonexistent-dir
```

```output
ls: cannot access '/nonexistent-dir': No such file or directory
/etc/hostname
```

I redirected only the error message to `errors.txt`:

```bash
ls /etc/hostname /nonexistent-dir 2> streams-and-redirection-lab/errors.txt
cat streams-and-redirection-lab/errors.txt
```

```output
/etc/hostname
ls: cannot access '/nonexistent-dir': No such file or directory
```

The file name remained visible in my terminal because it was normal output. The error was saved in `errors.txt`.

I then separated normal output and error output into two files:

```bash
ls /etc/hostname /nonexistent-dir > streams-and-redirection-lab/success.txt 2> streams-and-redirection-lab/errors.txt
cat streams-and-redirection-lab/success.txt
cat streams-and-redirection-lab/errors.txt
```

```output
/etc/hostname
ls: cannot access '/nonexistent-dir': No such file or directory
```

### Combining `stdout` and `stderr`

I combined normal output and error output in one file:

```bash
ls /etc/hostname /nonexistent-dir > streams-and-redirection-lab/combined.log 2>&1
cat streams-and-redirection-lab/combined.log
```

```output
ls: cannot access '/nonexistent-dir': No such file or directory
/etc/hostname
```

`2>&1` sends standard error to the same destination as standard output.

### Redirection Order

I tested two redirection orders:

```bash
ls /etc/hostname /nonexistent-dir > streams-and-redirection-lab/output.txt 2>&1
ls /etc/hostname /nonexistent-dir 2>&1 > streams-and-redirection-lab/output.txt
```

The error from the second command appeared in my terminal:

```output
ls: cannot access '/nonexistent-dir': No such file or directory
```

Bash processes redirections from left to right. In the first command, both streams go to the file. In the second command, standard error is connected to the terminal before standard output is redirected to the file.

### Input Redirection

I counted the lines in the simulated log in two ways:

```bash
wc -l < streams-and-redirection-lab/server.log
wc -l streams-and-redirection-lab/server.log
```

```output
10
10 streams-and-redirection-lab/server.log
```

The first command receives the file contents through standard input, so it prints only the count. The second command receives a file name as an argument, so it prints the count and file name.

I used input and output redirection together to sort my service list:

```bash
sort < streams-and-redirection-lab/services.txt > streams-and-redirection-lab/sorted-services.txt
cat streams-and-redirection-lab/sorted-services.txt
```

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
```

## 5. Pipes and Command Pipelines

### Basic Pipes

A pipe (`|`) sends the standard output of one command to the standard input of another command.

I used a pipe to pass my simulated log through `grep`:

```bash
cat streams-and-redirection-lab/server.log | grep "ERROR"
```

```output
2026-11-24 08:03:15 ERROR SSH authentication failed
2026-11-24 08:05:25 ERROR Database connection failed
2026-11-24 08:08:40 ERROR Permission denied
```

I also used the simpler command below. It produced the same three simulated error entries:

```bash
grep "ERROR" streams-and-redirection-lab/server.log
```

### Multiple Command Pipelines

I counted simulated error lines with a pipeline:

```bash
grep "ERROR" streams-and-redirection-lab/server.log | wc -l
```

```output
3
```

I counted service names and sorted the counts from highest to lowest:

```bash
sort streams-and-redirection-lab/services.txt | uniq -c | sort -nr
```

```output
      3 ssh
      2 nginx
      2 cron
      1 mysql
      1 apache2
```

I also saved sorted simulated errors into a report file:

```bash
grep "ERROR" streams-and-redirection-lab/server.log | sort > streams-and-redirection-lab/error-report.txt
cat streams-and-redirection-lab/error-report.txt
```

```output
2026-11-24 08:03:15 ERROR SSH authentication failed
2026-11-24 08:05:25 ERROR Database connection failed
2026-11-24 08:08:40 ERROR Permission denied
```


## 6. The `tee` Command

`tee` displays data in my terminal and saves the same data to a file.

I used `tee` to display and save simulated error entries:

```bash
grep "ERROR" streams-and-redirection-lab/server.log | tee streams-and-redirection-lab/server-errors.txt
```

```output
2026-11-24 08:03:15 ERROR SSH authentication failed
2026-11-24 08:05:25 ERROR Database connection failed
2026-11-24 08:08:40 ERROR Permission denied
```

I also used `tee` to display and save my service-frequency report:

```bash
sort streams-and-redirection-lab/services.txt | uniq -c | sort -nr | tee streams-and-redirection-lab/service-frequency.txt
```

```output
      3 ssh
      2 nginx
      2 cron
      1 mysql
      1 apache2
```


## 7. The `/dev/null` Device

`/dev/null` discards anything written to it. It is useful when I want to hide normal output, error output, or both.

I suppressed only the error message:

```bash
ls /etc/hostname /nonexistent-dir 2> /dev/null
```

```output
/etc/hostname
```

I then suppressed both normal output and error output:

```bash
ls /etc/hostname /nonexistent-dir > /dev/null 2>&1
echo $?
```

```output
2
```

The command displayed nothing, but its exit status was `2`. This showed me that hiding an error message does not fix the underlying error.

## 8. Here Documents and Here Strings

A here document (`<<`) provides multiple lines of text as command input. A here string (`<<<`) provides one string as input.

I first started an incomplete here-document command and cancelled it with `Ctrl + C`.

I then created a summary file with a here document:

```bash
cat << EOF > streams-and-redirection-lab/lab-summary.txt
Linux Administration Lab
Environment: Ubuntu WSL2
Topic: Standare Streams EOF

EOF
```

My recorded output from the file was:

```output
Linux Administration Lab
Environment: Ubuntu WSL2
Topic: Standare Streams EOF
```

The final line includes my recorded spelling mistake, `Standare`, and the text `EOF` because it was placed on the same line as the topic instead of being used only as the closing delimiter.

I used a here string to count words:

```bash
wc -w <<< "Linux System Administration"
```

```output
3
```

## 9. Pipeline Exit Status and `pipefail`

I first entered `ture` instead of `true`, which caused a command-not-found error. I then used the correct pipeline:

```bash
false | true
echo $?
```

```output
0
```

Without `pipefail`, Bash used the exit status of the last command in the pipeline. Although `false` failed, `true` succeeded, so the pipeline returned `0`.

I enabled `pipefail` and repeated the test:

```bash
set -o pipefail
false | true
echo $?
set +o pipefail
```

```output
1
```

With `pipefail` enabled, the pipeline returned a nonzero status because one command in the pipeline failed. I restored the default setting with `set +o pipefail`.

## 10. Practical System Administration Exercises

### System Health Reporting

I created a grouped system-health report command and redirected normal output and errors into separate files:

```bash
{
  echo "=== SYSTEM HEALTH REPORT ==="
  date
  echo "=== SYSTEM IDENTITY ==="
  hostnamectl
  ehco "=== SYSTEM UPDATE ==="
  uptime
  echo "=== DISK USAGE ==="
  free -h
  echo "=== NETWORK INTERFACES ==="
  ip -br addr
} > streams-and-redirection-lab/system-health-report.txt 2> streams-and-redirection-lab/report-errors.txt
```

I opened the report with `less` and counted its lines:

```bash
less streams-and-redirection-lab/system-health-report.txt
wc -l streams-and-redirection-lab/system-health-report.txt
```

```output
20 streams-and-redirection-lab/system-health-report.txt
```

I made a typing mistake by entering `ehco` instead of `echo`. The error was written to the separate error file:

```bash
cat streams-and-redirection-lab/report-errors.txt
```

```output
Command 'ehco' not found, did you mean:
  command 'ehlo' from snap ehlo (0.0.83)
  command 'echo' from deb coreutils (9.4-3ubuntu6.2)
See 'snap info <snapname>' for additional versions.
```

I did not capture the content of `system-health-report.txt`, so I did not document its individual system values.

### Server Log Investigation

I created a file containing simulated errors with `tee` and created a file for `ERROR` and `WARNING` entries:

```bash
grep "ERROR" streams-and-redirection-lab/server.log | tee streams-and-redirection-lab/server-errors.txt
grep -E "ERROR|WARNING" streams-and-redirection-lab/server.log > streams-and-redirection-lab/critical-events.txt
grep -c "ERROR" streams-and-redirection-lab/server.log
```

```output
2026-11-24 08:03:15 ERROR SSH authentication failed
2026-11-24 08:05:25 ERROR Database connection failed
2026-11-24 08:08:40 ERROR Permission denied
3
```

The log entries in this section are simulated events from my practice file, not actual server incidents.

### Process Monitoring

I listed the processes using the most memory:

```bash
ps -eo pid,user,comm,%cpu,%mem --sort=-%mem | head -n 11
```

```output
    PID USER     COMMAND         %CPU %MEM
    201 root     snapd            0.0  1.0
    345 root     unattended-upgr  0.0  0.5
    208 root     NetworkManager   0.0  0.4
     43 root     systemd-journal  0.0  0.4
    177 systemd+ systemd-resolve  0.0  0.3
   2918 root     wsl-pro-service  0.0  0.3
      1 root     systemd          0.0  0.3
    429 heinlin+ systemd          0.0  0.2
    202 root     systemd-logind   0.0  0.2
    198 polkitd  polkitd          0.0  0.2
```

I ran the following command to save the same report:

```bash
ps -eo pid,user,comm,%cpu,%mem --sort=-%mem | head -n 11 > streams-and-redirection-lab/top-memory-processes.txt
```

I did not separately display the saved file, so its contents were not verified in the transcript.

### System Warning Investigation

I viewed up to twenty warning-level or more severe messages from the current boot:

```bash
sudo journalctl -b -p warning --no-pager | tail -n 20
```

The command returned WSL, kernel, and system-service warnings. The output is real system information, not simulated log data.

I then saved the command output:

```bash
sudo journalctl -b -p warning --no-pager | tail -n 20 > streams-and-redirection-lab/system-warnings.txt
```

## 11. Verification Results

I completed and captured evidence for the following tasks:

- I inspected my shell file descriptors and confirmed that descriptors `0`, `1`, and `2` pointed to `/dev/pts/0`.
- I created my streams-and-redirection lab and copied the simulated practice files into it.
- I tested overwrite redirection with `>` and append redirection with `>>`.
- I redirected standard error with `2>` and separated normal output from error output.
- I combined standard output and standard error with `2>&1`.
- I tested that redirection order changes where error output appears.
- I used input redirection with `wc` and `sort`.
- I created basic and multi-stage pipelines.
- I used `tee` to display and save simulated log results.
- I used `/dev/null` to hide error output and both streams.
- I tested a here string and a here document.
- I tested default pipeline status and `pipefail`.
- I created system-report, simulated-log, process, and system-warning output files.

## 12. Errors and Troubleshooting

### Incorrect Source File Name

I entered `servic.log` instead of `services.txt` while copying the file. Linux could not find the incorrect path. I corrected the file name and copied the correct source file.

### Misspelled `hostname`

I entered `hotname` instead of `hostname` while building `system-report.txt`. The command did not run, so I corrected it and then added the hostname to the report.

### Misspelled `echo` in the Health Report

I entered `ehco` instead of `echo`. Because I redirected standard error to `report-errors.txt`, the error did not appear in the report. Reading the error file helped me identify the problem.

### Incomplete Health-Report Sections

My command group ran `free -h` after the `=== DISK USAGE ===` heading and did not run `df -h`. This means the recorded health report did not follow the planned memory-usage and disk-usage section layout. I also did not capture the report content after the command ran, so I should correct the headings and rerun the report before treating it as a complete health report.

### Incorrect Here-Document Delimiter Placement

I placed `EOF` on the same line as `Topic: Standare Streams`. A here-document closing delimiter must be on its own line. This is why `EOF` became part of the saved file content.

### Incorrect `true` Command

I first typed `ture` instead of `true` in a pipeline. I corrected the command before testing the effect of `pipefail`.

## 13. What I Learned

- I learned that `stdin`, `stdout`, and `stderr` use file descriptors `0`, `1`, and `2`.
- I learned that `>` overwrites a file, while `>>` adds content to the end of a file.
- I learned that `2>` redirects errors and `2>&1` combines errors with normal output.
- I learned that redirection order matters because Bash processes redirections from left to right.
- I learned that `<` sends file content to a command as standard input.
- I learned that pipes connect the output of one command to the input of another command.
- I learned that `tee` lets me view and save output at the same time.
- I learned that `/dev/null` hides output but does not solve the command error.
- I learned that a here-document delimiter must be on its own line.
- I learned that `pipefail` makes a pipeline report a failure when one of its commands fails.
- I learned that I can use redirection and pipelines to create administration reports from command output.

## 14. References

- My Ubuntu WSL2 terminal output.
- Locally available documentation: `man bash`, `man tee`, `man 4 null`, and `man 5 proc_pid_fd`.
