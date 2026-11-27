# Linux Process and Service Management

## 1. Objective

My objective was to investigate Linux processes and system resources, practice controlling harmless jobs, manage a service, inspect its logs, and create a basic system health report.

## 2. Lab Environment

I worked in Ubuntu on WSL2. I saved my report under `~/linux-fundamentals-lab/process-management-lab/`. My process and service results describe the system at the time of the exercise; process IDs and resource usage can change.

I checked the process with PID 1:

```bash
ps -p 1 -o pid,comm,args
```

```output
    PID COMMAND         COMMAND
      1 systemd         /sbin/init
```

This showed that systemd was running as PID 1 in my environment.

## 3. Process and Service Fundamentals

A process is a running instance of a program. A PID identifies a process, and a PPID identifies its parent. Process states include `R` for running or runnable, `S` for interruptible sleep, `D` for uninterruptible sleep, `T` for stopped, and `Z` for a terminated process waiting to be collected by its parent.

A service provides a managed system function and may use one or more processes. Some services complete a task and exit. On my system, systemd manages services such as `cron`, which runs scheduled jobs.

## 4. Commands Practiced

| Command | Purpose |
|---|---|
| `ps`, `pgrep`, `top` | Inspect or monitor processes. |
| `free`, `uptime` | Inspect memory, uptime, and load averages. |
| `jobs`, `bg`, `fg` | Inspect and control jobs in my current shell. |
| `kill` | Send a signal to a process. |
| `systemctl` | Inspect and manage systemd services. |
| `journalctl` | Inspect system and service logs. |

## 5. Practical Exercises

### Process Investigation

I used `ps aux` for a broad snapshot and `ps -ef` to view process information including parent PIDs. I searched for Bash processes and investigated my current shell:

```bash
pgrep -a bash
echo $$
ps -fp $$
```

My shell's PID was `490`. The `ps` result showed its parent PID as `488`:

```output
UID          PID    PPID  C STIME TTY          TIME CMD
heinlin+     490     488  0 11:03 pts/2    00:00:02 -bash
```

In this Bash session, `$$` expanded to the current shell's PID.

### CPU and Memory Monitoring

I ran `top`, `free -h`, and `uptime`, and used `ps` to sort processes by CPU usage. At one point my memory and uptime checks returned:

```output
               total        used        free      shared  buff/cache   available
Mem:           3.6Gi       429Mi       3.1Gi       3.8Mi       265Mi       3.2Gi
Swap:          1.0Gi          0B       1.0Gi
```

```output
 13:29:53 up  2:25,  1 user,  load average: 0.00, 0.00, 0.00
```

My CPU-sorted snapshot showed the `ps` process at 100% at that moment. `ps` CPU percentages are lifetime-based; `top` normally shows usage over a sampling interval, so the values are not directly equivalent.

My initial attempts at a memory-sorted process list contained a typo. I later used the correct command inside my health report and captured the resulting list.

### Foreground and Background Jobs

I started `sleep 300`, suspended it with Ctrl+Z, resumed it with `bg %1`, and checked the job:

```output
[1]+  3492 Running                 sleep 300 &
```

I returned it to the foreground with `fg %1` and interrupted it with Ctrl+C. Ctrl+Z stops a foreground job; `bg` resumes it in the background; `fg` returns it to the foreground. `jobs` shows jobs managed by the current shell.

### Process Termination

I started a separate `sleep 600` in the background and stored its PID in `TEST_PID` using `$!`. I checked the process before sending the default signal:

```bash
sleep 600 &
TEST_PID=$!
echo "$TEST_PID"
ps -fp "$TEST_PID"
kill "$TEST_PID"
ps -p "$TEST_PID"
```

My PID was `3493`. After `kill`, the check showed no process row and the shell reported termination:

```output
    PID TTY          TIME CMD
[1]+  Terminated              sleep 600
```

I repeated the test with PID `3496` using `kill -15`; `jobs -l` also reported it terminated. `kill` sends a signal: the default is SIGTERM, which requests termination. SIGKILL (`kill -9`) forcibly terminates a process without allowing normal cleanup, so I should first consider a graceful signal and verify the target PID.

### System Service Investigation

I listed loaded services and running services with `systemctl list-units`. The running list included `cron.service`. I also checked failed units:

```bash
systemctl --failed
```

```output
  UNIT LOAD ACTIVE SUB DESCRIPTION

0 loaded units listed.
```

This is a snapshot of failed loaded units, not a guarantee that every service is healthy. I did not capture a `systemctl list-unit-files --type=service` listing.

### Service Lifecycle Management

Before making changes, I checked `cron`: `systemctl is-active cron` returned `active`, and `systemctl is-enabled cron` returned `enabled`. I stopped the service and checked that it was `inactive`; then I started it and confirmed it was `active`.

I restarted it with `sudo systemctl restart cron`. The following is an excerpt from `systemctl status cron --no-pager`:

```output
● cron.service - Regular background program processing daemon
     Loaded: loaded (/usr/lib/systemd/system/cron.service; enabled; preset: enabled)
     Active: active (running) since Wed 2026-11-25 13:38:34 +0630; 11s ago
       Docs: man:cron(8)
   Main PID: 3526 (cron)
```

My subsequent `systemctl is-enabled cron` returned:

```output
enabled
```

`active` describes the current runtime state, while `enabled` describes startup configuration. Cron was already enabled. In WSL2, service enablement applies when the distribution starts with systemd; it does not itself start the distribution when Windows boots.

### Service Log Investigation

I inspected recent and current-boot logs with `journalctl -u cron -n 20 --no-pager` and `journalctl -u cron -b --no-pager`. I also followed the journal with `journalctl -u cron -f` and exited with Ctrl+C. The log included these stop and start events:

```output
Nov 25 13:37:31 heinhtet-sv systemd[1]: Stopping cron.service - Regular background program processing daemon...
Nov 25 13:37:31 heinhtet-sv systemd[1]: cron.service: Deactivated successfully.
Nov 25 13:37:31 heinhtet-sv systemd[1]: Stopped cron.service - Regular background program processing daemon.
Nov 25 13:38:03 heinhtet-sv systemd[1]: Started cron.service - Regular background program processing daemon.
```

The journal also reported an unset `EXTRA_OPTS` variable, described in troubleshooting below.

### System Health Reporting

I created `process-management-lab/system-health-report.txt` by grouping commands and redirecting standard output to the report and standard error to `errors.txt`. The report included the date, hostname, uptime, memory, five highest-memory processes, cron state, and failed units. I displayed both files.

This excerpt shows the recorded memory and service checks:

```output
=== MEMORY USAGE ===
               total        used        free      shared  buff/cache   available
Mem:           3.6Gi       433Mi       3.0Gi       3.8Mi       354Mi       3.2Gi
Swap:          1.0Gi          0B       1.0Gi
=== TOP MEMORY PROCESSES ===
    PID USER     COMMAND         %MEM
    226 root     snapd            1.0
    441 root     unattended-upgr  0.5
     50 root     systemd-journal  0.4
    265 root     NetworkManager   0.4
      1 root     systemd          0.3
=== CRON SERVICE STATUS ===
active
enabled
=== FAILED SYSTEMD UNITS ===
  UNIT LOAD ACTIVE SUB DESCRIPTION

0 loaded units listed.
```

`process-management-lab/errors.txt` was empty, and the report contained the expected sections and results. An empty error file alone does not prove every check succeeded.

## 6. Verification Results

| Exercise | Result |
|---|---|
| Process investigation | Identified systemd as PID 1 and inspected Bash and its parent PID. |
| Resource monitoring | Observed `top`, CPU, memory, and uptime; the report captured a memory-sorted process list. |
| Shell jobs | Stopped, resumed, foregrounded, and interrupted a `sleep` job. |
| Process termination | Sent SIGTERM to test processes and observed termination. |
| Service management | Stopped, started, and restarted cron; final report showed it active and enabled. |
| Journal and report | Viewed recent, current-boot, and followed cron logs; created and read the health report and error file. |

## 7. Errors and Troubleshooting

- My first memory-list attempts used `&mem` rather than `%mem`; the first also used `%men` in the sort option. The shell treated `&` as a background operator and tried to run `mem` as a command. The correct command appeared later in my report:

  ```bash
  ps -eo pid,user,comm,%mem --sort=-%mem | head -n 6
  ```

- I typed `jobs -1` with the digit `1`; Bash reported an invalid option. I corrected it to `jobs -l` with a lowercase letter `l`.
- I typed `systemtctl` when restarting cron after the stop. The command was not found. I corrected it to `sudo systemctl start cron` and confirmed `active`.
- Cron's journal reported:

  ```output
  Nov 25 13:38:03 heinhtet-sv (cron)[3519]: cron.service: Referenced but unset environment variable evaluates to an empty string: EXTRA_OPTS
  ```

  The service subsequently ran and was reported active. Whether the unset optional variable requires a configuration change remains unverified.

## 8. What I Learned

I learned to identify processes and their parents, inspect resource usage, and manage test jobs without touching unfamiliar system processes. I practiced checking a service's runtime state separately from its startup configuration. The journal and health report helped me verify the recorded service changes and review errors.

## 9. References

- Local documentation: `man ps`, `man top`, `man kill`, `man systemctl`, `man journalctl`, `help jobs`, `help bg`, and `help fg`.
