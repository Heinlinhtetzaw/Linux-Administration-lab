# Linux Scheduled Tasks and Basic Automation

## 1. Objective

My objective was to schedule recurring tasks with cron, automate a basic system health report, inspect task logs, and remove or reduce the frequency of my temporary test schedules.

## 2. Lab Environment

I worked in Ubuntu on WSL2. My practice directory was `~/linux-fundamentals-lab/scheduled-tasks-lab/`. I used my existing user crontab and preserved its previous backup entry. The service states and times in this document describe my recorded session.

## 3. Cron and Crontab Fundamentals

Cron is a background service that runs scheduled tasks. A crontab is a scheduling table, and the `crontab` command lets me manage my user's table. A cron job is an individual scheduled command.

Other scheduling tools include systemd timers and `at` for one-time tasks. In this exercise, I focused on cron. I should use `crontab -e` to edit my user crontab and take care with `crontab -r`, which removes the entire user crontab.

## 4. Cron Scheduling Syntax

A user crontab entry has five time fields followed by a command:

```text
minute hour day-of-month month day-of-week command
```

| Schedule | Meaning |
|---|---|
| `* * * * *` | Every minute. |
| `*/2 * * * *` | Every two minutes. |
| `0 8 * * *` | Every day at 8:00 AM, according to cron's configured time and timezone. |
| `0 15 * * *` | Every day at 3:00 PM. |

An asterisk matches every allowed value. A slash can specify a step, such as `*/2` for every two minutes. A system-wide crontab includes an additional username field; a user's crontab does not. I inspected `/etc/crontab` to see its system-wide entries.

## 5. Commands Practiced

| Command | Purpose |
|---|---|
| `systemctl status`, `is-active`, `is-enabled` | Inspect the cron service. |
| `crontab -l`, `crontab -e` | List and edit my scheduled tasks. |
| `chmod +x` | Make my practice script executable. |
| `cat`, `tail -f` | Inspect generated reports and follow their output. |
| `journalctl`, `grep` | Investigate cron activity in logs. |

## 6. Practical Exercises

### Cron Service Investigation

I checked the cron service and its runtime and startup states:

```bash
systemctl is-active cron
systemctl is-enabled cron
```

```output
active
enabled
```

The status output also showed cron running. My initial `crontab -l` showed an existing daily backup entry at 3:00 PM. I kept that entry when I added my lab tasks. Its presence is evidence of configuration, not proof that the backup itself succeeded.

### Recurring Task Configuration

I created `scheduled-tasks-lab` inside my existing fundamentals lab, edited my crontab, and scheduled `/usr/bin/date` to append to `cron-text.log` every minute. My first version had path errors, which I corrected as described below.

After correction, the log contained the original error followed by actual timestamps:

```output
/bin/sh: 1: /user/bin/date: not found
Thu Nov 26 09:39:01 +0630 2026
Thu Nov 26 09:40:02 +0630 2026
Thu Nov 26 09:41:01 +0630 2026
Thu Nov 26 09:42:03 +0630 2026
Thu Nov 26 09:43:01 +0630 2026
Thu Nov 26 09:44:02 +0630 2026
```

The later cron journal also recorded `/usr/bin/date` running with the correct lab path. The timestamps show the corrected recurring task produced output; the earlier error remains in the file because `>>` appends instead of replacing existing content.

### Automated System Health Monitoring

I created `system-monitor.sh`, made it executable, and ran it manually before scheduling it. My recorded script was:

```bash
#!/bin/bash
echo "=== SYSTEM HEALTH REPORT ==="

date
hostname

echo "=== SYSTEM UPTIME ==="
uptime

echo "=== MEMORY USAGE ==="
free -h

echo "=== DISK USAGE ==="
df -h /

echo "============================"
```

The script prints the time and hostname, then reports uptime, memory, and root filesystem usage. My manual test produced:

```output
=== SYSTEM HEALTH REPORT ===
Thu Nov 26 09:46:42 +0630 2026
heinhtet-sv
=== SYSTEM UPTIME ===
 09:46:42 up  1:06,  1 user,  load average: 0.00, 0.00, 0.00
=== MEMORY USAGE ===
               total        used        free      shared  buff/cache   available
Mem:           3.6Gi       448Mi       3.0Gi       3.8Mi       285Mi       3.2Gi
Swap:          1.0Gi          0B       1.0Gi
=== DISK USAGE ===
Filesystem      Size  Used Avail Use% Mounted on
/dev/sdd       1007G  5.6G  951G   1% /
============================
```

I then scheduled the script every two minutes. My first entry pointed to the wrong script location; after I edited the crontab, `system-health.log` contained successful reports at 09:56, 09:58, 10:00, and later two-minute intervals. One recorded report was:

```output
=== SYSTEM HEALTH REPORT ===
Thu Nov 26 09:58:01 +0630 2026
heinhtet-sv
=== SYSTEM UPTIME ===
 09:58:01 up  1:17,  1 user,  load average: 0.00, 0.00, 0.00
=== MEMORY USAGE ===
               total        used        free      shared  buff/cache   available
Mem:           3.6Gi       448Mi       3.0Gi       3.8Mi       304Mi       3.2Gi
Swap:          1.0Gi          0B       1.0Gi
=== DISK USAGE ===
Filesystem      Size  Used Avail Use% Mounted on
/dev/sdd       1007G  5.6G  951G   1% /
============================
```

In my crontab, `>>` appends output to the log and `2>&1` sends standard error to the same destination. Cron can use a more limited environment than an interactive shell, so I used explicit paths for the interpreter and script.

### Cron Log Investigation

I inspected recent cron journal entries and searched `/var/log/syslog`. My journal showed both the date task and the corrected monitoring command. This is an excerpt:

```output
Nov 26 10:06:04 heinhtet-sv CRON[2790]: (heinlinhtetzaw) CMD (/usr/bin/date >> "$HOME/linux-fundamentals-lab/scheduled-tasks-lab/cron-text.log" 2>&1)
Nov 26 10:06:04 heinhtet-sv CRON[2791]: (heinlinhtetzaw) CMD (/bin/bash "$HOME/linux-fundamentals-lab/scheduled-tasks-lab/system-monitor.sh" >> "$HOME/linux-fundamentals-lab/scheduled-tasks-lab/system-health.log" 2>&1)
```

The journal records that cron started these commands; the generated logs provide additional evidence of their output. I also ran `tail -f scheduled-tasks-lab/system-health.log` and exited with Ctrl+C. My syslog search reported `binary file matches`, so its displayed results may be incomplete.

### Schedule Modification and Cleanup

I edited my crontab after the test. The final `crontab -l` showed these active entries:

```output
0 15 * * * /home/heinlinhtetzaw/admin-lab/script/backup.sh
0 8 * * * /bin/bash "$HOME/linux-fundamentals-lab/scheduled-tasks-lab/system-monitor.sh" >> "$HOME/linux-fundamentals-lab/scheduled-tasks-lab/system-health.log" 2>&1
```

The every-minute date entry was no longer present, and the monitoring job was configured for 8:00 AM daily. The transcript does not show a later 8:00 AM run, so I verified the daily configuration but not its execution. My existing backup entry remained.

## 7. Verification Results

| Exercise | Result |
|---|---|
| Cron service | Active and enabled during the recorded session. |
| Date task | Timestamps and journal entries showed the corrected task running every minute. |
| Monitoring script | Tested manually; multiple scheduled reports appeared after the path was corrected. |
| Log investigation | Cron journal showed both commands; syslog search reported binary-file detection. |
| Cleanup | Final crontab retained the existing backup job, removed the minute test, and configured the monitor for 8:00 AM daily. A daily run was not captured. |
| Portfolio script | The tested script is reproduced above and copied to `wsl2-ubuntu-lab/scripts/system-monitor.sh`; the copy was verified against the original. |

## 8. Errors and Troubleshooting

- I typed `crontabl` and `mdkir` instead of `crontab` and `mkdir`. The shell reported the commands were not found; I corrected them.
- My first date entry used `/user/bin/date` and an incorrect lab directory. The log recorded `/bin/sh: 1: /user/bin/date: not found`. I corrected the command and path; later timestamps and cron journal entries verified the working test. I also initially looked for `crontest.log`, while the recorded log was named `cron-text.log`.
- My first monitoring entry pointed to `~/scheduled-tasks-lab/system-monitor.sh`, while the script was under `~/linux-fundamentals-lab/scheduled-tasks-lab/`. The log recorded `No such file or directory`. After correction, later reports appeared and the journal showed the corrected path.
- `grep` identified `/var/log/syslog` as a binary file, so the displayed syslog matches may not be exhaustive. I used the journal and generated reports as additional evidence.
- The cron status output warned that its unit file or related configuration had changed on disk. Cron was active, but the cause and whether a reload has since occurred were not established by this transcript.

## 9. WSL2 Scheduling Limitations

Cron cannot run a job while my WSL2 distribution is stopped. Having cron enabled does not by itself guarantee that the distribution stays running or starts when Windows starts. An Ubuntu Server VM provides a more persistent environment for practicing server scheduling.

## 10. What I Learned

I learned to inspect and preserve an existing crontab, understand the five scheduling fields, test a script manually, and verify scheduled output through both a report and the cron journal. I also learned that an incorrect path can prevent a job from running even when cron is active, and that temporary frequent jobs should be removed or rescheduled after testing.

## 11. References

- Local manual pages: `man cron`, `man crontab`, `man 5 crontab`, and `man bash`.
- My exercise specification and recorded terminal output.
