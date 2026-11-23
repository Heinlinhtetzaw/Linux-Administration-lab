### Linux Directory Hierarhcy and Filesystem Concepts

## Objective
To learn how the Linux directory tree is organized in my Ubuntu WSL2 setup, see how static and dynamic files differ, check virtual filesystem (`/proc`, `/sys`, `/dev`), and practice basic filesystem commands.

## Linux Filesystem Hierarchy
In Linux, everything starts from one top-level folder called *root* (`/`).
Unlink Windows, which uses separate drive letters like `C:\` and `D:\`, Linux puts everything under `/`.
In my WSL2 setup, my Linux system site on `/dev/sdd` (`ext4`), and my Windows drives are mounted under `/mnt/c` and `/mnt/d`.

## Important Directories

`/` - The top-level root directory where the whold Linux tree starts.
Example - The main `/` mount on `/dev/sdd/`.

`/etc` - Stores system and program configuration files.
Example - `/etc/ssh/ssh_config`, `/etc/apt/sources.list`,and `/etc/systemd`.

`/var` - Holds changing files like logs, caches, and program data that grow over time.
Example - `var/log/syslog`, `/var/log/auth.log`, and `/var/log/dpkg.log`.

`/home` - Holds personal folders for reguler users. 
Example - `/home/heinlinhtetzaw/` where my files and project folders live.

`/usr` - Holds installed user programs, libraries, and documentation.
Example - `/usr/share/doc` and `/usr/lib/modules/6.6.87.2-microsoft-standard-WSO2`.

`/tmp` - Stores temprary files, oftern cleaned up on reboot.

`/proc` - Shows live info about running processes and the kernal from memory.
Example - `/proc/cupinfo` and `/proc/meminfo`.

`/sys` - Shows kernel settings, hardware info, and drivers from memory.

`/dev` - Represents hardware and virtual devices as files.
Example - `/dev/sdd`(virtual disk).

## Static vs Dynamic Data
*Static Data*: Files that stya mostly the same unless I install, update or change settings.
Example - `/usr` (programs and libraries) and `/etc` (config files).
*Dynamic Data*: Files that change often while the system runs.
Example - `/var/log` (log files keep growing), `/tmp` (temporary files), and `/home/heinlinhtetzaw` (my active work folders).

## Virtual Filesystem
Virtual filesystems do not take up real space on hard drive.
Instead, the linux kernal create them in memory.
So I can check or interact with the system using normal file commands.
*`/proc`*- Show live kernel and process details, such as uptime (`uptime`) and system stats.
*`/sys`*- Show kernel and hardware/driver detials in a folder layout.
*`/dev`*- Holds device files for hardare and virtual devices ( like `/dev/sdd` for storage).

## Filesystem Investigation Commands
`ls` - Lists files and folders (`-l` for details, `-a` for hidden files, `-h` for readable sizes, `-d` for folder info).
`findmnt` - Shows how filesystems are mounted.
`df` - Shows free and used disk space (`-h` for readable sizes, `-T` for filesystem type).
`stat` - Shows detailed file or folder info like permissions, owner, size, and date.
`du` - Shows how much space and file use.

## Practical Exercise
# Checking My Home Folder and Main Directories
*Objective* - See hidden files in my home folder and check permissions on main Linux folders.
```bash
ls -lah
ls -ld /etc /var/ /home/ /usr/ /tmp/ /opt/ /root ```

```output
heinlinhtetzaw@heinhtet-sv:~$ ls -lah
total 124K
drwxr-x--- 16 heinlinhtetzaw generaluser 4.0K Nov 23 07:59 .
drwxr-xr-x  6 root           root        4.0K Nov  1 15:12 ..
-rw-------  1 heinlinhtetzaw generaluser  20K Nov 22 17:37 .bash_history
-rw-r--r--  1 heinlinhtetzaw generaluser 3.7K Nov  8  2025 .bashrc
-rw-r--r--  1 heinlinhtetzaw generaluser   64 Dec  6  2025 .gitconfig
drwxr-xr-x  5 heinlinhtetzaw generaluser 4.0K Nov 23 08:10 linux-fundamentals-lab
drwxr-xr-x  8 heinlinhtetzaw generaluser 4.0K Nov 22 14:36 linux-system-administration
-rw-r--r--  1 heinlinhtetzaw generaluser    0 Nov 23 07:59 notes.txt

heinlinhtetzaw@heinhtet-sv:~$ ls -ld /etc /var/ /home/ /usr/ /tmp/ /opt/ /root
drwxr-xr-x 98 root root 4096 Nov 23 08:42 /etc
drwxr-xr-x  6 root root 4096 Nov  1 15:12 /home/
drwxr-xr-x  3 root root 4096 Nov  1 15:41 /opt/
drwx------  5 root root 4096 Nov 12 14:04 /root
drwxrwxrwt  9 root root 4096 Nov 23 09:21 /tmp/
drwxr-xr-x 12 root root 4096 Aug  5  2025 /usr/
drwxr-xr-x 13 root root 4096 Nov  8  2025 /var/```

*Explanation*- Files starting with a dot (like `.bash_history` and `.bashrc`) are hidden files shown by `-a`.
All main system folders are owned by `root`. `/root` is private ( `drwx------` ) , while `/tmp` has `drwxrwxrwt`, meaning anyone can add tmep files ,but users cannot delte files owned by someone else.
*Conculusion*- Linux uses permissions to keep user files separate from system files and protect shared folders like `/tmp`.

## Checking Configs ( /et c) and Logs (/var/log)
*Object* - See example config folders in `/etc` and check files in `/var/log`.

```bash
ls /etc/ssh /etc/apt /etc/systemd
ls -lh /var/log ```

```output
heinlinhtetzaw@heinhtet-sv:~$ ls /etc/ssh
ssh_config  ssh_config.d
heinlinhtetzaw@heinhtet-sv:~$ ls /etc/apt
apt.conf.d   keyrings       sources.list    trusted.gpg.d
auth.conf.d  preferences.d  sources.list.d
heinlinhtetzaw@heinhtet-sv:~$ ls /etc/systemd
journald.conf  networkd.conf  sleep.conf         system.conf     user.conf
logind.conf    pstore.conf    system             timesyncd.conf
network        resolved.conf  system-generators  user

heinlinhtetzaw@heinhtet-sv:~$ ls -lh /var/log
total 2.4M
-rw-r-----  1 syslog    adm             7.8K Nov 23 09:17 auth.log
-rw-r-----  1 syslog    adm             2.0K Nov 22 08:17 auth.log.1
-rw-r-----  1 syslog    adm             2.9K Nov 15 20:39 auth.log.2.gz
-rw-r--r--  1 root      root            258K Nov 23 08:42 dpkg.log
-rw-r-----  1 syslog    adm              93K Nov 23 09:05 kern.log
-rw-r-----  1 syslog    adm             291K Nov 23 09:21 syslog ```

*Explanation* - `/etc` holds settings for tools like `ssh,apt` and `systemd`. 
`/var/log` holds system logs (`syslog,auth.log, kern.log`).
*Conclusion*- Config files live in `/etc` , while ongoing logs live in `/var/log` .

## Checking Virtual Filesystems (/proc,/sys,/dev)
*Objective* - Check` uptime` and inspect`/proc,/sys,/dev` with `stat`.

```bash
uptime
stat /proc
stat /sys
stat /dev/```

```output
heinlinhtetzaw@heinhtet-sv:~$ uptime
 09:32:01 up  1:44,  1 user,  load average: 0.03, 0.01, 0.00

heinlinhtetzaw@heinhtet-sv:~$ stat /proc
  File: /proc
  Size: 0               Blocks: 0          IO Block: 1024   directory
Device: 0,59    Inode: 1           Links: 254
Access: (0555/dr-xr-xr-x)  Uid: (    0/    root)   Gid: (    0/    root)

heinlinhtetzaw@heinhtet-sv:~$ stat /sys
  File: /sys
  Size: 0               Blocks: 0          IO Block: 4096   directory
Device: 0,22    Inode: 1           Links: 13
Access: (0555/dr-xr-xr-x)  Uid: (    0/    root)   Gid: (    0/    root)

heinlinhtetzaw@heinhtet-sv:~$ stat /dev/
  File: /dev/
  Size: 3860            Blocks: 0          IO Block: 4096   directory
Device: 0,5     Inode: 1           Links: 15
Access: (0755/drwxr-xr-x)  Uid: (    0/    root)   Gid: (    0/    root) ```

*Explanation*- `uptime` shows my WSL2 system has been up for `1:44`.
All there `stat` outputs show `Blocks: 0`, meaning they don't use regular disk blocks.

*Conlusion*- `/prc,/sys,/dev` are memory-based vitual folders used by Linux to show system and device info.

## Checking Mounts and Disk Space
*Objective*: See where`/` is mounted  and check disk space and filesystem types.

```bash
findmnt /
df -hT ```

```output
heinlinhtetzaw@heinhtet-sv:~$ findmnt /
TARGET SOURCE   FSTYPE OPTIONS
/      /dev/sdd ext4   rw,relatime,discard,errors=remount-ro,data=ordered

heinlinhtetzaw@heinhtet-sv:~$ df -hT
Filesystem     Type           Size  Used Avail Use% Mounted on
/dev/sdd       ext4          1007G  3.9G  952G   1% /
C:\            9p             146G  133G   14G  91% /mnt/c
D:\            9p             331G   85G  246G  26% /mnt/d
snapfuse       fuse.snapfuse   75M   75M     0 100% /snap/core22/2987
snapfuse       fuse.snapfuse 1.3G  1.3G     0 100% /snap/intellij-idea-community/685
tmpfs          tmpfs          374M   20K  374M   1% /run/user/1000 ```

*Explanaition*- `/`is mounted from `/dev/sdd` using `ext4`.
`df -hT` also shows my Widows drives (`C:\` and `D:\`) mounted under `/mnt/c` and `/mnt/d` as `9p`.
*Conclusion*- `findmnt ` and `df -hT` help me see how storage and Windows drives connect inside WSL2.

## Verification Results
- `/` is mounted read-wirte on `/dev/sdd (ext4)`.
- After running `sudo ls -lh /var/log` at *09:29* , `auth.log` updated to `8.1k` (up from `7.8k` at *09:21*).

## What I learned
- Linus puts all files and mounted drives into one tree starging at `/`.
-`/etc` is for config files, `/var/log` is for logs, and `/home` is for my personal file.
- `/proc,/sys,/dev` are virtual filesystems with `0` disk blocks.
- `ls, findmnt, df , stat` are greate basic tools for checking folders, mounts and disk space.
