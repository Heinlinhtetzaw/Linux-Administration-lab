# Linux Package Management

## 1. Objective

My objective was to understand how Ubuntu finds, installs, inspects, updates, and removes software packages. I investigated repositories and dependencies, practiced a package lifecycle, and collected package health information.

## 2. Lab Environment

I worked in Ubuntu 24.04.5 LTS on WSL2. My practice files were in `~/linux-fundamentals-lab/package-management-lab/`. The health report recorded APT 2.8.4 and dpkg 1.22.6 on amd64.

## 3. Software Package Fundamentals

A software package can contain programs, configuration, documentation, and information about other packages it needs. Ubuntu uses Debian `.deb` packages. A package manager tracks and manages these files.

A dependency is another package that software needs. I used `apt depends` to inspect dependencies and `apt rdepends` to investigate packages that refer to another package. For example:

```bash
apt depends curl
```

```output
curl
  Depends: libc6 (>= 2.34)
  Depends: libcurl4t64 (= 8.5.0-2ubuntu10.16)
  Depends: zlib1g (>= 1:1.1.4)
```

## 4. Ubuntu Package Management Architecture

APT is the higher-level tool I used to search repositories, plan changes, and resolve dependencies. `dpkg` is the lower-level tool that manages Debian package installation and provides information about installed packages. APT uses dpkg for underlying package operations; dpkg alone does not automatically download missing dependencies.

## 5. Software Repositories

A repository provides packages and package information. I inspected `/etc/apt/sources.list.d/ubuntu.sources` without changing it. The following is the first active repository entry from my output:

```output
Types: deb
URIs: http://archive.ubuntu.com/ubuntu/
Suites: noble noble-updates noble-backports
Components: main universe restricted multiverse
Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg
```

My file also contained a `noble-security` entry. `main` contains officially supported open-source packages; `universe` contains community-maintained packages. `restricted` and `multiverse` contain software with licensing or other restrictions. `Signed-By` identifies the keyring used to verify repository metadata.

## 6. Package Lifecycle Management

### Updating and Upgrading

I refreshed package metadata with `sudo apt update`. This does not itself upgrade installed software. The end of my update output was:

```output
Fetched 12.0 MB in 18s (669 kB/s)
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
23 packages can be upgraded. Run 'apt list --upgradable' to see them.
```

I also ran `apt -s upgrade` and `apt -s full-upgrade`. The `-s` option simulates changes. An earlier upgrade simulation reported the following; this excerpt is from before I repaired the interrupted dpkg operation:

```output
The following upgrades have been deferred due to phasing:
  libsqlite3-0
```

```output
22 upgraded, 0 newly installed, 0 to remove and 1 not upgraded.
2 not fully installed or removed.
```

The simulation proposed no new packages at that time. Its result is a preview, and I did not perform a full system upgrade in this exercise. `full-upgrade` may remove packages to resolve dependencies; `upgrade` avoids removing installed packages.

### Searching and Inspecting Packages

I searched for `htop` and `nginx`, inspected `htop` with `apt show htop`, and checked its available version with `apt policy htop`:

```output
htop:
  Installed: (none)
  Candidate: 3.3.0-4build1
  Version table:
     3.3.0-4build1 500
        500 http://archive.ubuntu.com/ubuntu noble/main amd64 Packages
```

The candidate is the version APT would normally select, subject to the package state and dependencies.

### Installing Packages

`tree` was already available at `/usr/bin/tree`, so I chose `sl` for the installation and removal exercise. `dpkg -s sl` reported that it was not installed before the exercise. I inspected it with `apt show sl` and simulated installation with `apt -s install sl`, which proposed installing `sl` and its dependency `libncurses6`.

My first installation attempt failed because dpkg had been interrupted. After I ran the recovery command shown in the error, I retried `sudo apt install sl` and confirmed the proposed changes. The installation output included:

```output
Setting up libncurses6:amd64 (6.4+20240113-1ubuntu2.2) ...
Setting up sl (5.02-1) ...
```

I checked the command path:

```bash
command -v sl
```

```output
/usr/games/sl
```

`dpkg -s sl` reported `Status: install ok installed` and version `5.02-1`.

### Removing and Purging Packages

I removed the package with `sudo apt remove sl`. The removal output included:

```output
Removing sl (5.02-1) ...
```

The dpkg log later showed `status not-installed sl:amd64 <none>`. When I ran `sudo apt purge sl`, APT reported `Package 'sl' is not installed, so not removed`.

Generally, `remove` removes package files while retaining managed configuration where applicable; `purge` also removes managed system configuration. Neither should be assumed to remove user-created files in home directories.

### Automatic Dependency Removal and Cache

After removing `sl`, APT identified `libncurses6` as no longer required. I simulated, but did not perform, automatic removal:

```output
The following packages will be REMOVED:
  libncurses6
0 upgraded, 0 newly installed, 1 to remove and 23 not upgraded.
Remv libncurses6 [6.4+20240113-1ubuntu2.2]
```

I inspected `/var/cache/apt/archives/`. Cache cleanup removes downloaded package archives, not installed packages. My cache measurement encountered a permission error, discussed below.

## 7. Low-Level Package Management

I used `dpkg -l` to list packages and `dpkg -s` to inspect `bash`, `coreutils`, and `openssh-client`. In `dpkg -l`, `ii` means a package is desired and currently installed; `rc` indicates removed package files with configuration remaining.

I used `dpkg -L` to inspect files associated with installed packages, and `dpkg -S` to find their package owners. My ownership results were:

```output
coreutils: /usr/bin/ls
grep: /usr/bin/grep
findutils: /usr/bin/find
openssh-client: /usr/bin/ssh
```

For example, `dpkg -L findutils | head -n 20` listed both `/usr/bin/find` and `/usr/bin/xargs` among its files. I also viewed the file lists for `coreutils` and `openssh-client`.

### Local Debian Package Inspection

I downloaded a `tree` package into my lab directory with `apt download tree`, then inspected it without installing it again:

```bash
ls -lh *.deb
dpkg-deb -I ./tree_*.deb
dpkg-deb -c ./tree_*.deb
```

The file listing was:

```output
-rw-r--r-- 1 heinlinhtetzaw generaluser 47K Oct 31  2025 tree_2.1.1-2ubuntu3.24.04.2_amd64.deb
```

The metadata identified version `2.1.1-2ubuntu3.24.04.2`, architecture `amd64`, and a `libc6` dependency. The contents included `./usr/bin/tree`.

## 8. Package Version Management

I used `apt policy bash` and `apt policy openssh-client` to compare installed and candidate versions, and `apt list -a curl` to see available versions:

```output
Listing... Done
curl/noble-updates,noble-security,now 8.5.0-2ubuntu10.16 amd64 [installed,automatic]
curl/noble 8.5.0-2ubuntu10 amd64
```

Ubuntu version numbers can include distribution revisions and backported fixes; an older-looking upstream version alone does not establish that a package is vulnerable.

### Package Holds

I temporarily held my already-installed `tree` package and removed the hold:

```bash
sudo apt-mark hold tree
apt-mark showhold
sudo apt-mark unhold tree
apt-mark showhold
```

```output
tree set on hold.
tree
Canceled hold on tree.
```

The final `apt-mark showhold` produced no visible output. A hold can prevent upgrades, so it needs a reason and a review date in production.

APT also distinguishes manually installed packages from automatically installed dependencies.

## 9. Package Management Logs

I inspected `/var/log/apt/history.log` for APT transactions and `/var/log/dpkg.log` for lower-level package activity. My dpkg log included these entries for the package I practiced with:

```output
2026-11-25 11:21:01 status installed sl:amd64 5.02-1
```

```output
2026-11-25 11:24:59 status not-installed sl:amd64 <none>
```

My search for `tree` also matched `libhtml-tree-perl`, demonstrating that a text match is not necessarily the exact package I intended to find.

## 10. Practical System Administration Exercises

### Software Inventory Report

I created an inventory of packages whose status was `install ok installed`:

```bash
dpkg-query -W \
    -f='${Package}\t${Version}\t${Architecture}\t${Status}\n' \
    | awk -F '\t' '$4 == "install ok installed"' \
    > package-management-lab/installed-packages.txt
```

I inspected the first ten lines and counted the report:

```output
651 package-management-lab/installed-packages.txt
```

### Package Update Assessment

I saved the list of available updates and an upgrade simulation in my lab directory. The update-list filename was misspelled as `avialable-updates.txt`. The earlier update and simulation results are in section 6; the later saved simulation remains unverified.

### Package Lifecycle and Ownership

I installed and removed `sl`, simulated automatic dependency removal, and identified the package owners of `ls`, `grep`, `find`, and `ssh`, as documented above. The installation status and removal log support the lifecycle results; a separate post-removal command check is missing.

### Package Management Health Report

I redirected a grouped set of checks to `package-health-report.txt` and errors to `package-health-errors.txt`, then displayed both files. The report included the following excerpt:

```output
=== INSTALLED PACKAGE COUNT ===
651
=== HELD PACKAGES ===
=== PACKAGE AUDIT ===
=== DISK CAPACITY ===
Filesystem      Size  Used Avail Use% Mounted on
/dev/sdd       1007G  3.9G  952G   1% /
=== PACKAGE CACHE USAGE ===
16M     /var/cache/apt/archives/
```

The empty hold and audit sections mean the commands printed no entries in this report; an empty `dpkg --audit` result normally means it found no package inconsistencies. The cache figure may be incomplete because the error file reported an unreadable directory.

## 11. Verification Results

| Task | Result |
|---|---|
| Repository and dependencies | Inspected the active Ubuntu sources and package dependencies. |
| Package installation | `sl` was initially absent, then its path and installed status were shown. |
| Package removal | Removal output and dpkg log show `sl` was removed; a separate post-removal path/status check is missing. |
| Update assessment | 23 packages were reported upgradable; an earlier simulation proposed 22 upgrades and no new packages. The later saved simulation remains unverified. |
| Inventory and ownership | Inventory contained 651 lines; owners of four commands were identified. |
| Local package and hold | Downloaded and inspected a `.deb`; held and unheld `tree`. |
| Health report | Created and read both report files; the cache check had a permission error, and `apt check` failed. |

## 12. Errors and Troubleshooting

### Interrupted dpkg Operation

My initial installation attempt reported:

```output
E: dpkg was interrupted, you must manually run 'sudo dpkg --configure -a' to correct the problem.
```

I ran `sudo dpkg --configure -a`, which configured `plocate` and processed triggers, then successfully installed `sl`. Later, `dpkg --audit` produced no output. The recovery command changes package state and should be used when the corresponding problem exists.

### Package Health Check

The lesson suggested `sudo apt check`, but my command returned:

```output
E: Invalid operation check
```

The dependency check remains unverified. `sudo apt-get check` can be run separately to check dependencies.

### Cache Permissions

My report's error file contained:

```output
du: cannot read directory '/var/cache/apt/archives/partial': Permission denied
```

I also combined `cd` and `apt download` in one command and received `-bash: cd: too many arguments`. I corrected this by changing directory first and running the download separately.

## 13. Production Safety Considerations

I should review proposed package changes before confirming them, simulate upgrades when assessing impact, and plan production changes around backups and maintenance windows. I should investigate package manager processes before acting on lock errors and avoid deleting lock files. I should use recovery commands only when the relevant issue exists and review automatic removals before applying them.

## 14. What I Learned

I learned that refreshing metadata and upgrading installed packages are different operations. I can inspect dependencies and package ownership, verify an installation using both a command path and package status, and use logs to investigate package changes. I also learned to check report error output and distinguish a simulation from an actual change.

## 15. References

- Local manual pages: `man apt`, `man apt-get`, `man apt-cache`, `man apt-mark`, `man dpkg`, `man dpkg-query`, `man dpkg-deb`, and `man sources.list`.
