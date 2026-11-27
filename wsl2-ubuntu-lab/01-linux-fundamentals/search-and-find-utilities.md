# Linux Search and Find Utilities

## 1. Objective

My objective was to learn how to find files, search file contents, discover command locations, and process search results in Ubuntu WSL2. I practiced with a controlled lab directory and performed read-only searches on system directories.

## 2. Lab Environment

I created `search-utilities-lab` inside my existing `~/linux-fundamentals-lab` workspace:

```bash
mkdir -p search-utilities-lab/{configs,logs,backups,scripts,documents}
```

The lesson specification recommended creating the lab outside my Git repository. My recorded lab was instead created inside `linux-fundamentals-lab`.

I created configuration, log, backup, script, and document files. My final lab structure included these files:

```output
search-utilities-lab/
├── backups
│   ├── backup-new.tar.gz
│   └── backup-old.tar.gz
├── configs
│   ├── database.conf
│   ├── nginx.conf
│   └── ssh.conf
├── documents
│   ├── meeting-notes.txt
│   ├── notes.txt
│   └── report.txt.txt
├── logs
│   ├── auth.log
│   ├── error.log
│   └── system.log
└── scripts
    ├── backup.sh
    └── monitor.sh
```



I added simulated entries to the lab logs:

- `auth.log`: `ERROR SSH authentication failed`
- `system.log`: `INFO System started`
- `error.log`: `ERROR Database connection failed`

These are simulated practice entries, not real system incidents.

I also created a 5 MiB apparent-size file and an old backup timestamp:

```bash
truncate -s 5M search-utilities-lab/backups/large-backup.img
touch -d "10 days ago" search-utilities-lab/backups/backup-old.tar.gz
```

## 3. Commands Practiced

| Command | Purpose | Example |
|---|---|---|
| `find` | Searches the filesystem using conditions. | `find . -type f -name "*.log"` |
| `locate` | Searches an indexed filename database. | `locate -i nginx.conf` |
| `updatedb` | Updates the database used by `locate`. | `sudo updatedb` |
| `grep` | Searches inside files for matching text. | `grep -rn "ERROR" search-utilities-lab/logs/` |
| `which` | Finds executable paths in `PATH`. | `which -a python3` |
| `whereis` | Finds binaries, source files, and manual pages. | `whereis ls` |
| `type` | Shows how Bash resolves a command name. | `type cd` |
| `command -v` | Checks how a command is resolved. | `command -v python3` |
| `xargs` | Converts input into command arguments. | `find . -print0 \| xargs -0 ls -lh` |

## 4. Practical Lab Setup

I set the required permissions in my lab:

```bash
chmod 755 search-utilities-lab/scripts/backup.sh
chmod 644 search-utilities-lab/scripts/monitor.sh
chmod 600 search-utilities-lab/configs/database.conf
```

I verified the important results with `find . -ls`:

```output
-rw-------   1 heinlinhtetzaw generaluser        0 ./configs/database.conf
-rwxr-xr-x   1 heinlinhtetzaw generaluser        0 ./scripts/backup.sh
-rw-r--r--   1 heinlinhtetzaw generaluser        0 ./scripts/monitor.sh
-rw-r--r--   1 heinlinhtetzaw generaluser  5242880 ./backups/large-backup.img
-rw-r--r--   1 heinlinhtetzaw generaluser        0 ./backups/backup-old.tar.gz
```

## 5. Filesystem Searching with `find`

`find` searches the real filesystem from a starting path. Its basic structure is:

```text
find [starting-path] [expression]
```

### Searching by Filename

I searched for a specific configuration file:

```bash
find . -name "nginx.conf"
```

```output
./search-utilities-lab/configs/nginx.conf
```

I searched for configuration and log files:

```bash
find . -name "*.conf"
find . -name "*.log"
find . -iname "*.LOG"
```

The `-name` option is case-sensitive. The `-iname` option is case-insensitive. I used quotation marks so Bash passed the wildcard pattern to `find`.

### Searching by File Type

I searched for regular files and directories:

```bash
find . -type f
find . -type d
```

I also searched for symbolic links below `/etc`:

```bash
find /etc/ -type l
```

This command returned many symbolic links and also displayed permission-denied messages for protected directories. This showed me that searches of system directories may need `sudo` and can produce many results.

I found the script files with:

```bash
find . -type f -name "*.sh"
```

```output
./search-utilities-lab/scripts/backup.sh
./search-utilities-lab/scripts/monitor.sh
```

### Controlling Search Depth

I limited the search depth with these commands:

```bash
find . -maxdepth 1
find . -maxdepth 2
find . -mindepth 1 -maxdepth 1
```

The starting directory is depth `0`. Using `-mindepth 1` excluded the starting directory from my results.

I first typed `-mindepth1` without a space, and `find` returned an unknown-predicate error. I corrected it by writing `-mindepth 1`.

### Searching by File Size

I found the 5 MiB apparent-size backup image:

```bash
find . -type f -size +1M
```

```output
./search-utilities-lab/backups/large-backup.img
```

I displayed its details with `-exec`:

```bash
find . -type f -size +1M -exec ls -lh {} \;
```

```output
-rw-r--r-- 1 heinlinhtetzaw generaluser 5.0M Nov 24 20:29 ./search-utilities-lab/backups/large-backup.img
```

I compared apparent file size with allocated disk usage:

```bash
ls -lh search-utilities-lab/backups/large-backup.img
du -h search-utilities-lab/backups/large-backup.img
```

```output
-rw-r--r-- 1 heinlinhtetzaw generaluser 5.0M Nov 24 20:29 search-utilities-lab/backups/large-backup.img
0       search-utilities-lab/backups/large-backup.img
```

This showed that `large-backup.img` is a sparse file: its apparent size is 5.0 MiB, while it used no allocated disk blocks in this output.

I searched `/var/log` for files larger than 10 MiB. The command produced no matching output, so no files met that condition at the time of the search.

### Searching by Modification Time

I searched for files modified recently and files older than seven completed 24-hour periods:

```bash
find . -type f -mtime -1
find . -type f -mtime +7
find . -type f -mmin -60
```

My old backup matched the older-file search:

```output
./search-utilities-lab/backups/backup-old.tar.gz
```

I compared the old and new backup timestamps with `stat`. The old backup had a modification time of November 14, while the new backup had a modification time of November 24.

I also searched recently modified system files:

```bash
sudo find /etc/ -type f -mtime -1
```

```output
/etc/hostname
/etc/ld.so.conf.d/ld.wsl.conf
/etc/ld.so.cache
```

### Searching by Ownership

I searched for files owned by my current user and group:

```bash
find . -type f -user "$(whoami)"
find . -type f -group "$(id -gn)"
```

Both commands returned the files in my lab and the earlier lab folders because I ran them from `~/linux-fundamentals-lab` rather than only inside `search-utilities-lab`.

I also searched for root-owned regular files directly under `/etc`:

```bash
find /etc/ -maxdepth 1 -type f -user root
```

The command returned many root-owned system files, including `/etc/hostname`, `/etc/passwd`, and `/etc/services`.

The following searches produced no output:

```bash
find . -nouser
find . -nogroup
```

This means I did not find files with unresolved user or group ownership in my search scope.

### Searching by Permissions

I found the file with exact `600` permissions:

```bash
find . -type f -perm 600
```

```output
./search-utilities-lab/configs/database.conf
```

I found files with any execute permission bit:

```bash
find . -type f -perm /111
```

```output
./search-utilities-lab/scripts/backup.sh
```

I attempted a world-writable-file search. My first command contained the typo `-tupe`; a confirmed result remains unavailable.

### Combining Search Conditions

I searched for nonempty log files:

```bash
find . -type f -name "*.log" -size +0c
```

The result included my simulated logs, the earlier lesson logs, and `combined.log` because I ran the command from the parent workspace.

I combined filename conditions with OR:

```bash
find . -type f \( -name "*.conf" -o -name "*.log" \)
```

I excluded log files with NOT:

```bash
find . -type f ! -name "*.log"
```

### Executing Commands with `-exec`

I used `-exec` to display details for log files:

```bash
find . -type f -name "*.log" -exec ls -lh {} \;
find . -type f -name "*.log" -exec ls -lh {} +
```

`{}` is replaced by each matching path. `\;` runs one `ls` command for each match, while `+` passes multiple paths to fewer `ls` commands.

I used `find` with `grep` to search all matching log files for `ERROR`:

```bash
find . -type f -name "*.log" -exec grep -Hn "ERROR" {} +
```

```output
./search-utilities-lab/logs/error.log:1:ERROR Database connection failed
./search-utilities-lab/logs/auth.log:1:ERROR SSH authentication failed
```

The full output also included matching simulated logs from previous lessons because my search started in the parent workspace.

## 6. Indexed File Searching

### `locate`

`locate` searches a filename database, so it is usually faster than `find`. It can be out of date until the database is updated.

`locate` was not installed at first. I installed the `plocate` package and then confirmed the executable path:

```bash
command -v locate
sudo apt update
sudo apt install plocate
command -v locate
```

```output
/usr/bin/locate
```

Before I ran `updatedb`, searches failed because the database did not exist:

```output
/var/lib/plocate/plocate.db: No such file or directory
```

After updating the database, I searched for `nginx.conf` and up to ten paths containing `passwd`:

```bash
sudo updatedb
locate -i nginx.conf
locate -l 10 passwd
```

```output
/home/heinlinhtetzaw/linux-fundamentals-lab/search-utilities-lab/configs/nginx.conf

/etc/passwd
/etc/passwd-
/etc/pam.d/chpasswd
/etc/pam.d/passwd
/etc/security/opasswd
/usr/bin/gpasswd
/usr/bin/passwd
```

### `updatedb`

I created a unique file and tested the difference between `find` and `locate`:

```bash
touch search-utilities-lab/documents/linux-index-test-20261124.txt
find search-utilities-lab/ -type f -name "linux-index-test-20261124.txt"
sudo updatedb
locate linux-index-test-20261124.txt
```

```output
search-utilities-lab/documents/linux-index-test-20261124.txt
/home/heinlinhtetzaw/linux-fundamentals-lab/search-utilities-lab/documents/linux-index-test-20261124.txt
```

I made two typing errors during this test: `locat` instead of `locate`, and `20261142` instead of `20261124` in one `find` search. I corrected both before the final successful `locate` search.

### Comparison Between `find` and `locate`

| Feature | `find` | `locate` |
|---|---|---|
| Search source | Actual filesystem | Filename database |
| New files | Found immediately | May require `updatedb` |
| Search conditions | Names, type, size, time, ownership, permissions | File and path names |
| Speed | Depends on the search scope | Usually fast |
| Run commands on matches | Yes, with `-exec` | No |

## 7. Recursive Content Searching with `grep`

I searched my simulated log directory recursively:

```bash
grep -r "ERROR" search-utilities-lab/logs/
grep -rn "ERROR" search-utilities-lab/logs/
grep -irn "error" search-utilities-lab/logs/
```

```output
search-utilities-lab/logs/error.log:1:ERROR Database connection failed
search-utilities-lab/logs/auth.log:1:ERROR SSH authentication failed
```

I searched all `.log` files under the current workspace:

```bash
grep -rn --include="*.log" "ERROR"
```

This found matching entries in the simulated logs from several lesson directories.

I attempted to exclude the backups directory, but I typed `bakcups` rather than `backups`:

```bash
grep -rn --exclude-dir=bakcups "ERROR"
```

The misspelled directory name meant the command did not test the intended exclusion.

## 8. Command Discovery

### Understanding `PATH`

`PATH` is the list of directories Bash searches for external commands. I displayed my `PATH` and then printed one directory per line:

```bash
echo "$PATH"
echo "$PATH" | tr ':' '\n'
```

My `PATH` started with these Linux directories:

```output
/usr/local/sbin
/usr/local/bin
/usr/sbin
/usr/bin
/sbin
/bin
```

It also contained WSL-mounted Windows program directories. The directory order matters because Bash normally uses the first suitable executable it finds.

### `which`

I found all `python3` executable paths:

```bash
which -a python3
```

```output
/usr/bin/python3
/bin/python3
```

I ran `which cd`, and it displayed no output. This is expected because `cd` is a shell builtin, not a separate executable in `PATH`.

### `whereis`

I used `whereis` to find the `ls` binary and manual page:

```bash
whereis ls
whereis -b ls
whereis -m ls
whereis -s ls
```

```output
ls: /usr/bin/ls /usr/share/man/man1/ls.1.gz
ls: /usr/bin/ls
ls: /usr/share/man/man1/ls.1.gz
ls:
```

The empty source-file result means `whereis` did not find source files for `ls` in its search locations.

### `type`

I used `type` to see how Bash resolves commands:

```bash
type ls
type cd
type echo
type grep
type sudo
```

```output
ls is aliased to `ls --color=auto'
cd is a shell builtin
echo is a shell builtin
grep is aliased to `grep --color=auto'
sudo is hashed (/usr/bin/sudo)
```

I used `type -a` to show all known interpretations and `type -t` to show a command category:

```bash
type -a ls
type -a echo
type -t cd
```

```output
ls is aliased to `ls --color=auto'
ls is /usr/bin/ls
ls is /bin/ls

echo is a shell builtin
echo is /usr/bin/echo
echo is /bin/echo

builtin
```

### `command -v`

I used `command -v` to check command resolution:

```bash
command -v python3
command -v git
command -v bash
command -v cd
```

```output
/usr/bin/python3
/usr/bin/git
/usr/bin/bash
cd
```

`command -v` is useful in scripts because it can check whether a command is available before I try to run it.

## 9. Argument Processing with `xargs`

### Basic Usage

I used `xargs -n 1` to pass one word at a time to `echo`:

```bash
echo "Linux Ubuntn Debian" | xargs -n 1 echo
```

```output
Linux
Ubuntn
Debian
```

The word `Ubuntn` is my recorded spelling mistake.

### Null-Separated Filenames

I used `-print0` and `xargs -0` to safely process paths. This is useful when file names contain spaces.

```bash
find . -type f -name "*.log" -print0 | xargs -0 -r ls -lh
```

The command listed all matching log files, including those from earlier lessons. The simulated log files in `search-utilities-lab/logs` were listed with their expected sizes of 32, 33, and 20 bytes.

I also used `-t` to print the generated `ls` command before it ran:

```bash
find . -type f -name "*.txt" -print0 | xargs -0 -r -t ls -lh
```

The displayed command included `./search-utilities-lab/documents/meeting-notes.txt`, demonstrating that null-separated processing works with file names supplied by `find`.

### Comparison with `find -exec`

Both `find -exec ... {} +` and `find ... -print0 | xargs -0` can pass matching paths to another command.

I used both methods with `ls -lh`. I use `find -exec` for direct actions on `find` results, while `xargs` is useful when I need to pass results through a pipeline.

## 10. Practical System Administration Exercises

### Configuration Audit

I searched for configuration files modified in the last seven days:

```bash
sudo find /etc/ -type f -name "*.conf" -mtime -7
```

```output
/etc/ld.so.conf.d/ld.wsl.conf
/etc/updatedb.conf
```

I saved the same search output and separated errors:

```bash
sudo find /etc/ -type f -name "*.conf" -mtime -7 > search-utilities-lab/recent-configration.txt 2> search-utilities-lab/search-errors.txt
wc -l search-utilities-lab/recent-configration.txt
cat search-utilities-lab/search-errors.txt
```

```output
2 search-utilities-lab/recent-configration.txt
```

The error file was empty. My output file name contains the recorded spelling `recent-configration.txt`.

Recently modified configuration files can be relevant during troubleshooting because a recent configuration change may affect service behavior. The search alone does not show who made the change or whether it was authorized.

### Storage Investigation

I searched `/var` for files larger than 500 MiB by apparent size:

```bash
sudo find /var -xdev -type f -size +500M -printf '%s %p \n' | sort -nr | head -n 10
```

```output
1308684288 /var/lib/snapd/snaps/intellij-idea-community_685.snap
1308684288 /var/lib/snapd/cache/f05ad67d3e6a8b2fce3c901ea6b59f0bcfa2ddff82c514b0d6533d4ff7a4f6ce489632cfceecb913eae084f5605df342
```

I then compared allocated disk usage:

```bash
sudo du -xah /var | sort -rh | head -n 10
```

```output
2.4G    /var
1.7G    /var/lib
1.5G    /var/lib/snapd/snaps
1.3G    /var/lib/snapd/snaps/intellij-idea-community_685.snap
571M    /var/log
```

I first typed `di` instead of `du`, then corrected the command. I used `+500M` rather than the lesson's requested `+50M`, so this investigation used a narrower threshold.

### Log Investigation

I first searched `logs/` from the parent workspace, which only contained an earlier empty `system.log`. The command produced no output.

I then ran the command again but still used `logs/` instead of `search-utilities-lab/logs/`:

```bash
find logs/ -type f -name "*.log" -exec grep -Hni "error" {} + | tee search-utilities-lab/error-invistigation.txt
cat search-utilities-lab/error-invistigation.txt
```

The output file was empty because the intended simulated log directory was not searched. My saved file name also contains the recorded spelling `error-invistigation.txt`.

### Security Permission Audit

I searched the workspace for world-writable regular files; no matches were displayed.

I searched the root filesystem for SUID regular files and redirected errors into a separate file:

```bash
sudo find / -xdev -type f -perm -4000 2> search-utilities-lab/suid-search-errors.txt
```

```output
/usr/sbin/pppd
/usr/bin/mount
/usr/bin/chfn
/usr/bin/chsh
/usr/bin/passwd
/usr/bin/sudo
/usr/bin/umount
/usr/bin/gpasswd
/usr/bin/su
/usr/bin/fusermount3
```

The error file was empty. The presence of SUID files is not automatically a security problem; many standard system utilities use SUID legitimately. I did not change permissions.

### Software Availability Audit

I checked whether common commands were available:

```bash
for cmd in bash git python3 ssh nginx docker; do
    if command -v "$cmd" > /dev/null 2>&1; then
        echo "$cmd: AVAILABLE"
    else
        echo "$cmd: NOT FOUND"
    fi
done
```

```output
bash: AVAILABLE
git: AVAILABLE
python3: AVAILABLE
ssh: AVAILABLE
nginx: NOT FOUND
docker: NOT FOUND
```

## 11. Verification Results

- I created a controlled search-utilities lab with simulated logs, scripts, backups, and configuration files.
- I used `find` to search by file name, type, depth, size, timestamp, owner, group, and permissions.
- I verified that `database.conf` had `600` permissions and `backup.sh` had execute permission.
- I demonstrated the difference between a sparse file's apparent size and its allocated disk usage.
- I installed `plocate`, updated its database, and verified a new file with both `find` and `locate`.
- I used recursive `grep` to find simulated error entries.
- I used `which`, `whereis`, `type`, and `command -v` for command discovery.
- I used `xargs` with `-print0`, `-0`, `-r`, and `-t`.
- I completed the configuration audit, storage investigation, SUID read-only investigation, and software availability audit.

## 12. Errors and Troubleshooting

### Incorrect File Names and Paths

- I created `report.txt.txt` instead of `report.txt`.
- I created `meeting-notes.txt` instead of `meeting notes.txt`.
- I typed `servic.log` instead of `services.txt` while copying the earlier lesson file.
- I typed `locat` instead of `locate`.
- I used an incorrect date, `20261142`, in one `find` command.

### `find` Syntax Errors

- `-mindepth1` failed because the option and its value need a space.
- `-tupe` failed because the correct option is `-type`.
- A `find` command without `-name` failed because `*.log` was interpreted in the wrong position.
- `-ecec` failed because the correct option is `-exec`.

### Search Scope Problems

I ran many lab searches from `~/linux-fundamentals-lab` instead of from `search-utilities-lab`. This caused results to include files from my earlier labs and made the log-investigation exercise search the wrong `logs/` directory.

### `locate` Database Was Missing

After installing `plocate`, `locate` could not search until I ran `sudo updatedb`. The error correctly showed that `/var/lib/plocate/plocate.db` did not exist yet.

### Permission-Denied Messages in `/etc`

My non-sudo searches under `/etc` returned permission-denied messages for protected paths. This is normal when my current user does not have access to every directory.

## 13. Safety Considerations

- I used read-only `find` searches for the system investigations.
- I did not use modifying actions such as `-delete`, `chmod`, or `chown` on search results.
- I used `-xdev` while searching `/var` and `/` so the search stayed on the current filesystem.
- I treated SUID results as items for review, not automatic vulnerabilities.
- I distinguished simulated lab logs from system files and did not present simulated errors as real incidents.
- I should always verify search results before using destructive actions on them.

## 14. What I Learned

- I learned that `find` searches the live filesystem and can test file names, types, sizes, timestamps, ownership, and permissions.
- I learned that `locate` is fast because it searches an index, but I may need to run `updatedb` before it finds new files.
- I learned that a file's apparent size can differ from its allocated disk usage when the file is sparse.
- I learned that `grep` searches inside files, while `find` searches for files.
- I learned that `type` and `command -v` can identify shell builtins and aliases, while `which` is mainly for executable paths.
- I learned that `xargs -0` works safely with null-separated paths from `find -print0`.
- I learned that correct paths and careful spelling are important when searching files.
- I learned to run commands from the intended directory or use explicit paths to avoid searching unrelated files.

## 15. References

- My Ubuntu WSL2 terminal output.
- Local manual pages referenced by the exercise: `man find`, `man locate`, `man updatedb`, `man grep`, `man xargs`, `man whereis`, and `man bash`.
