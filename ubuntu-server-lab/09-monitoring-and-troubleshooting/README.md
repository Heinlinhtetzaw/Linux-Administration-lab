# Ubuntu Server Monitoring and Troubleshooting

## 1. Objective

My objective was to monitor my server's resources and services, investigate its logs, troubleshoot a simulated website outage, and generate a system health report.

## 2. Lab Environment

I worked on my Ubuntu Server virtual machine, `jane-sv`, through an SSH connection from PowerShell. My server had two available CPUs, an Nginx website, and a separate filesystem mounted at `/mnt/data`.

Monitoring helps me observe resource use and availability. Troubleshooting means investigating a problem, identifying its cause, applying a suitable solution, and checking that the service has recovered. My results below describe a point in time, so they may change as the server's workload changes.

## 3. Commands Practiced

| Command | Purpose |
|---|---|
| `uptime`, `nproc`, `top`, `ps`, `vmstat` | Check system load, CPUs, processes, and activity. |
| `free`, `swapon` | Inspect memory and swap. |
| `df`, `du`, `findmnt` | Check filesystem space, inode use, directory size, and mounts. |
| `systemctl`, `journalctl` | Inspect service states and system logs. |
| `ss`, `ufw`, `curl` | Inspect listening ports, firewall rules, and website availability. |
| `nginx -t` | Test Nginx configuration. |
| `mkdir`, `cat`, `ls` | Create a directory and inspect my report. |

## 4. Practical Exercises

### CPU and System Load Monitoring

I checked the system load and the number of available CPUs:

```bash
uptime
nproc
```

```output
 03:45:12 up 6 min,  1 user,  load average: 0.05, 0.03, 0.00
2
```

The three load averages represent the past 1, 5, and 15 minutes. They count runnable tasks and tasks in uninterruptible sleep, so load is not simply CPU usage. I also used `top` to observe processes and per-CPU activity, and listed the processes with the highest reported CPU usage:

```bash
ps -eo pid,user,comm,%cpu,%mem --sort=-%cpu | head -n 6
vmstat 1 5
```

My `vmstat` output showed these five samples:

```output
procs -----------memory---------- ---swap-- -----io---- -system-- -------cpu-------
 r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa st gu
 2  0      0 1595508  18772 224992    0    0   391    30  213    0  0  2 98  0  0  0
 1  0      0 1595512  18772 225032    0    0     0     0  536  171  0  5 95  0  0  0
 0  0      0 1595512  18772 225032    0    0     0     0  273  124  0  2 98  0  0  0
 0  0      0 1595512  18772 225032    0    0     0     0  148   38  0  1 99  0  0  0
 0  0      0 1595512  18772 225032    0    0     0     0  179   49  0  0 99  1  0  0
```

The first `vmstat` report generally covers averages since boot; later rows represent the sampling intervals. The low load and high CPU idle values did not indicate significant contention during these checks. The `ps` snapshot briefly reported high CPU percentages for `ps` and `head` themselves, so I considered the other samples as well rather than treating one snapshot as sustained load.

### Memory and Storage Monitoring

I checked memory and swap:

```bash
free -h
swapon --show
```

```output
               total        used        free      shared  buff/cache   available
Mem:           1.9Gi       317Mi       1.5Gi       1.1Mi       238Mi       1.6Gi
Swap:          2.0Gi          0B       2.0Gi
```

```output
NAME      TYPE SIZE USED PRIO
/swap.img file   2G   0B   -2
```

Available memory estimates how much memory can be used by new applications; free memory is only the part currently unused. I also listed processes by memory use with `ps -eo pid,user,comm,%mem,rss --sort=-%mem | head -n 6`. RSS is the resident physical memory used by a process.

I inspected filesystem capacity and inode usage with `df -hT` and `df -i`. My root filesystem was 40% full and used 11% of its inodes. I checked the backup mount and directory size:

```bash
findmnt /mnt/data
du -sh /mnt/data/backups/
```

```output
TARGET    SOURCE    FSTYPE OPTIONS
/mnt/data /dev/sdb1 ext4   rw,relatime
```

```output
52K     /mnt/data/backups/
```

I also checked log storage:

```bash
sudo du -sh /var/log
sudo journalctl --disk-usage
```

```output
241M    /var/log
Archived and active journals take up 236.2M in the file system.
```

Inodes track filesystem objects; a filesystem can run out of inodes even when it still has free space.

### Service and System Log Monitoring

I checked failed units and the state of SSH, Nginx, and cron:

```bash
systemctl --failed
systemctl is-active ssh nginx cron
systemctl is-enabled ssh nginx cron
```

```output
  UNIT LOAD ACTIVE SUB DESCRIPTION

0 loaded units listed.
```

```output
active
active
active
```

```output
enabled
enabled
enabled
```

In the order requested, all three services were active and enabled. Active describes the current state; enabled means configured to start automatically. I checked current-boot errors, recent warnings, and the Nginx and SSH journals:

```bash
sudo journalctl -b -p err --no-pager
sudo journalctl -p warning --since "1 hour ago" --no-pager
sudo journalctl -u nginx -n 10 --no-pager
sudo journalctl -u ssh -n 10 --no-pager
```

The current-boot log included an invalid DMI header and `vmwgfx` graphics-driver errors. The warning log also included timing, workqueue, and cron environment-variable messages. These logs are useful leads for investigation; a running service does not mean every warning has been resolved.

I used `sudo ss -tulnp` to inspect listening services and `sudo ufw status verbose` to inspect my firewall. UFW was active, denied incoming traffic by default, and allowed TCP ports 22 and 80. My local website returned:

```bash
curl -I http://localhost/server-lab.html
```

```output
HTTP/1.1 200 OK
Server: nginx/1.24.0 (Ubuntu)
Date: Fri, 27 Nov 2026 03:57:58 GMT
Content-Type: text/html
Content-Length: 251
Last-Modified: Thu, 26 Nov 2026 16:29:16 GMT
Connection: keep-alive
ETag: "6b085e5c-fb"
Accept-Ranges: bytes
```

`curl -I` requests HTTP headers. A successful local request verifies the page from the server itself; it does not test access from another machine.

### Simulated Incident and Recovery

I simulated an outage by stopping Nginx and attempting to reach the website:

```bash
sudo systemctl stop nginx
curl --max-time 5 http://localhost/server-lab.html
```

```output
curl: (7) Failed to connect to localhost port 80 after 3 ms: Couldn't connect to server
```

I inspected the service, port, configuration, and logs:

```bash
systemctl status nginx --no-pager
sudo ss -tlnp 'sport = :80'
sudo nginx -t
sudo journalctl -u nginx -n 15 --no-pager
```

The service status showed `inactive (dead)`, the port query showed no listeners, and the configuration test reported:

```output
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
```

The Nginx journal recorded the service stopping. I started it and checked its state and port:

```bash
sudo systemctl start nginx
systemctl is-active nginx
sudo ss -tlnp 'sport = :80'
```

```output
active
```

The port check showed Nginx listening on port 80 again. My first follow-up HTTP request used a misspelled path and returned 404; the correct page later returned HTTP 200 in my health report.

### System Health Report Generation

I generated a point-in-time report using a command group and redirection:

```bash
mkdir -p ~/monitoring-lab
{
    echo "===== SYSTEM HEALTH REPORT ====="
    date
    hostname
    echo
    echo "===== SYSTEM LOAD ====="
    uptime
    echo
    echo "===== MEMORY ====="
    free -h
    echo
    echo "===== STORAGE ====="
    df -hT
    echo
    echo "===== NETWORK ====="
    ip -br addr
    ip route
    echo
    echo "===== SERVICE STATUS ====="
    systemctl is-active ssh nginx cron
    echo
    echo "===== FAILED UNITS ====="
    systemctl --failed --no-pager
    echo
    echo "===== FIREWALL ====="
    sudo ufw status verbose
    echo
    echo "===== WEBSITE AVAILABILITY ====="
    curl -I --max-time 5 http://localhost/server-lab.html
} > ~/monitoring-lab/system-health-report.txt 2>&1
```

The `>` operator writes standard output to the report, and `2>&1` sends standard error to the same place. I inspected the report with `cat` and checked that the file existed:

```bash
ls -lh ~/monitoring-lab/
```

```output
total 4.0K
-rw-rw-r-- 1 jane jane 2.6K Nov 27 04:03 system-health-report.txt
```

The report recorded all three services as active, zero failed units, and the correct website returning `HTTP/1.1 200 OK` after recovery. It is a snapshot, not continuous or automated monitoring. I have omitted its network details from this public documentation.

## 5. Incident Report

| Field | My observation |
|---|---|
| Incident | Simulated internal website outage. |
| Impact | The local website request could not connect while Nginx was stopped. |
| Symptoms | `curl` reported a connection failure on port 80. |
| Investigation | Nginx was inactive, port 80 had no listener, the configuration test succeeded, and the journal showed the service stopping. |
| Root cause | I intentionally stopped Nginx for the exercise. |
| Resolution | I started Nginx. |
| Verification | Nginx became active and listened on port 80; the later health report showed HTTP 200 for the correct page. |

## 6. Verification Results

| Area | Recorded result |
|---|---|
| CPU and load | Two CPUs, low load, and high idle CPU in the observed samples. |
| Memory and storage | 1.6 GiB available memory, no swap in use, and the backup filesystem mounted. |
| Services | SSH, Nginx, and cron were active and enabled; no failed units were listed. |
| Logs | I inspected system and service logs and observed warnings and errors. |
| Incident recovery | Nginx returned to active status, listened on port 80, and the correct page returned HTTP 200 in the subsequent report. |
| Health report | The report was created and inspected. |

## 7. Errors and Troubleshooting

- I entered `df -ht`, which produced `df: option requires an argument -- 't'`. I corrected it to `df -hT`; uppercase `-T` displays filesystem types, while lowercase `-t` expects a type argument.
- I misspelled `--disk-usage` as `--disk-uage`. After checking `journalctl --help`, I reran the command with the correct option and saw the journal disk usage.
- After starting Nginx, I requested `server-lab.hmtl` and received `HTTP/1.1 404 Not Found`. The health report later requested the correct `server-lab.html` path and received HTTP 200.
- The system journal recorded `Invalid DMI field header` and errors saying `vmwgfx` was running on an unsupported hypervisor. I observed these messages during log inspection; the output does not show a configuration change addressing them.

## 8. What I Learned

I learned to look at load, CPU activity, available memory, storage, service status, and logs together rather than relying on one number. I practiced tracing a simulated outage from a failed request to service status, listening ports, configuration, and logs, then checking recovery. I also learned that command spelling and file paths matter, and that a health report captures only the moment when it runs.

## 9. References

- Local manual pages: `man uptime`, `man top`, `man vmstat`, `man free`, `man df`, `man systemctl`, `man journalctl`, `man ss`, and `man curl`.
- My exercise specification and recorded terminal output.
