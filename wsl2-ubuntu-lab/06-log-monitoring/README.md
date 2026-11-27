# Linux Log Monitoring

## 1. Objective

My objective was to investigate Linux logs, filter journal messages, create and monitor simulated events, review authentication and service activity, and prepare a log monitoring report.

## 2. Lab Environment

I worked in Ubuntu on WSL2. I saved my report and error file in `~/linux-fundamentals-lab/log-monitoring-lab/` and used a second terminal for a live logging test. My results describe the recorded session; logs and service states change over time.

## 3. Linux Logging Fundamentals

A log records events from the system, services, and applications. `systemd-journald` collects journal entries, which I can inspect with `journalctl`. `rsyslog` processes and routes messages, often to traditional files such as `/var/log/syslog` and `/var/log/auth.log`.

Messages can have different severity levels. An error indicates an error condition, a warning may point to a potential issue, and an informational message records ordinary activity. A severity label helps me filter events, but I still need context to understand their impact.

## 4. Commands Practiced

| Command | Purpose |
|---|---|
| `systemctl status` | Inspect service state and recent messages. |
| `tail`, `grep` | Read or search traditional text logs. |
| `journalctl` | Filter and follow entries in the systemd journal. |
| `logger` | Submit a message to the logging system. |
| `who`, `w`, `last`, `lastb` | Inspect recorded sessions and login history. |
| `cat`, `ls` | Inspect report files and log rotation configuration. |

## 5. Practical Exercises

### Logging Environment Investigation

I listed `/var/log/` and found files including `syslog`, `auth.log`, `kern.log`, `dpkg.log`, `wtmp`, and `btmp`, as well as rotated files such as `syslog.1` and `syslog.2.gz`. I checked `systemd-journald` and `rsyslog` with `systemctl status`; both were reported `active (running)` at the time.

I checked the disk space used by active and archived journals:

```bash
journalctl --disk-usage
```

```output
Archived and active journals take up 559.8M in the file system.
```

### Traditional Log File Investigation

I used `sudo tail -n 10 /var/log/syslog` and searched for `error` and `warning` with `grep -i`. I also followed new entries with `sudo tail -f /var/log/syslog` and stopped it with Ctrl+C. The observed messages included WSL and service warnings. A text match alone is not always an actual failure: for example, a line can mention the word `error` while describing an error-reporting service.

Both searches reported `grep: /var/log/syslog: binary file matches`. Their displayed lines may therefore be incomplete; I should not treat them as a complete list of matches.

### Systemd Journal Investigation

I viewed recent entries, entries from the last hour, and messages filtered by severity. My current-boot warning query used:

```bash
sudo journalctl -p warning -b --no-pager
```

The current boot included kernel and WSL messages, a warning about the journal being replaced after it was detected as corrupted or uncleanly shut down, and a missing `pam_lastlog.so` message. These are real recorded messages, not the simulated events I generated below. Their causes and effects were not established by this exercise.

`-p warning` includes warning-level and more severe entries; `-b` limits the query to the current boot. My earlier `journalctl -p err -n --no-pager` output included entries from more than one boot. The later report used `-p err -b -n 10` to capture up to ten current-boot error-level and more severe entries.

### Custom Log Message Generation

I generated three test messages:

```bash
logger -t linux-lab -p user.warning "System monitoring test started"
logger -t linux-lab -p user.warning "Simulated high disk usage warning"
logger -t linux-lab -p user.err "Simulated application failure"
sudo journalctl -t linux-lab --since "10 minute ago" --no-pager
```

```output
Nov 26 08:54:47 heinhtet-sv linux-lab[1402]: System monitoring test started
Nov 26 08:55:21 heinhtet-sv linux-lab[1405]: Simulated high disk usage warning
Nov 26 08:55:26 heinhtet-sv linux-lab[1407]: Simulated application failure
```

The disk warning and application failure were **simulated**, not evidence of an actual disk or application incident. I used `user.warning` for the first message as well, although the exercise specified `user.info`.

For a live test, I followed the tag with `sudo journalctl -t linux-lab -f` and submitted a message from another terminal. The following line appeared in the first terminal:

```output
Nov 26 08:56:45 heinhtet-sv linux-lab[1453]: Real-time monitoring test successful
```

I stopped the follow view with Ctrl+C.

### Authentication Log Investigation

I verified `labalice` with `id`, ran `sudo whoami`, and inspected `/var/log/auth.log` and the journal's `sudo` entries. My `sudo whoami` output was:

```output
root
```

My search for `authentication failure` found earlier `pam_unix(sudo:auth)` failure entries. It also matched the later sudo log entry that recorded the search command itself. I should read the full event before classifying a text match as an authentication failure.

I attempted `su - labalice`; the terminal returned `su: Authentication failure`. The subsequent journal query showed:

```output
Nov 26 08:59:10 heinhtet-sv su[1490]: pam_unix(su-l:auth): authentication failure; logname= uid=1000 euid=0 tty=/dev/pts/2 ruser=heinlinhtetzaw rhost=  user=labalice
Nov 26 08:59:11 heinhtet-sv su[1490]: FAILED SU (to labalice) heinlinhtetzaw on pts/2
```

This records a failed local `su` attempt involving the lab account. The transcript does not establish the password entered or the reason authentication failed.

### Login History Investigation

I ran `who`, `w`, `last -n 10`, and `sudo lastb -n 10`. `who` showed my recorded session. The `lastb` output included the `labalice` attempt and an older `alice` record; it does not by itself explain why either attempt failed. Several historical WSL boot records in `last` were displayed as `still running`, so I should interpret these records in the context of WSL rather than assume they all represent active systems.

### Service Log Monitoring

I checked `systemctl status cron --no-pager`; cron was shown active and running. I reviewed recent cron entries and today's entries using `journalctl -u cron`. The current-day log included:

```output
Nov 26 08:38:46 heinhtet-sv systemd[1]: Started cron.service - Regular background program processing daemon.
Nov 26 08:38:46 heinhtet-sv (cron)[209]: cron.service: Referenced but unset environment variable evaluates to an empty string: EXTRA_OPTS
Nov 26 08:38:46 heinhtet-sv cron[209]: (CRON) INFO (pidfile fd = 3)
Nov 26 08:38:46 heinhtet-sv cron[209]: (CRON) INFO (Running @reboot jobs)
```

The broader history also showed hourly scheduled-task entries. The unset `EXTRA_OPTS` message appeared while cron was running; the captured output does not establish whether any configuration change is needed.

### Log Monitoring Report

I grouped journal and service queries and redirected their output to `log-monitoring-report.txt`, with standard error going to `errors.txt`. I displayed both files. The report included journal disk usage, recent current-boot errors, sudo activity, cron logs, and the four custom messages. My simulated error appeared among real error-level entries because I submitted it with `user.err`.

The report's error file printed no visible content. That does not establish that all logged system events were healthy; it only shows no visible standard-error output in that file.

### Log Rotation

I inspected `/etc/logrotate.conf` and listed `/etc/logrotate.d/`. The global configuration included:

```output
weekly
```

```output
rotate 4
```

These are global settings in the displayed configuration; individual included rules may specify their own settings. Log rotation helps limit the growth of traditional logs by managing older files. I did not change the rotation configuration.

## 6. Verification Results

| Exercise | Result |
|---|---|
| Logging environment | Both logging services were running; journal usage and available log files were inspected. |
| Traditional logs | Read, searched, and followed syslog; binary-file detection limits the completeness of the searches. |
| Journal | Inspected recent, time-filtered, priority-filtered, and current-boot warning entries; current-boot errors also appeared in the report. |
| Custom messages | Three simulated messages and a live second-terminal message appeared in the journal. |
| Authentication and logins | Reviewed sudo and login records and observed a failed `su` attempt for `labalice`. |
| Cron and report | Inspected cron status and logs, and displayed the report and error file. |
| Rotation | Read global settings and listed included configuration files. |

## 7. Errors and Troubleshooting

- I mistyped `sudo` as `sudp` and `suod`. The shell reported the commands were not found; I corrected them before reading and following syslog.
- `grep` reported that syslog matched as a binary file, so its displayed search output may omit matches. Further investigation of the file would be needed for a complete search.
- I used `user.warning` instead of the requested `user.info` for `System monitoring test started`. The message was recorded, but the intended informational severity was not demonstrated.
- The service status output warned that unit files or drop-ins for `systemd-journald`, `rsyslog`, and `cron` had changed on disk. The transcript does not establish what changed or whether a reload has since occurred. I did not perform a reload during this exercise.
- The journal recorded `PAM unable to dlopen(pam_lastlog.so)` and `PAM adding faulty module`, along with the journal replacement warning and WSL/kernel messages. Their present impact and root causes remain unverified; they merit contextual investigation rather than an assumed fix.
- My recorded commands do not show separate unfiltered `journalctl -b --no-pager` or `journalctl --since today --no-pager` system-wide queries. I did run current-boot priority filters and a today's filter for cron.


## 8. What I Learned

I learned to investigate both traditional log files and the systemd journal, filter by time, unit, tag, and priority, and follow messages as they arrive. I saw why simulated messages must be labeled and why a search result needs context before I call it a real failure. I also learned to inspect report errors and understand that log rotation manages older log files.

## 9. References

- Local manual pages: `man journalctl`, `man logger`, `man rsyslog`, `man logrotate`, `man last`, and `man tail`.
- My exercise specification and recorded terminal output.
