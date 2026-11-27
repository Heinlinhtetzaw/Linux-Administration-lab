# Ubuntu Server User and Access Management

## 1. Objective

My objective was to audit administrative access, create temporary administrator and developer accounts, verify their privileges, configure a shared directory, and practice revoking administrative access.

## 2. Lab Environment

- Host operating system: Windows 11.
- Guest operating system: Ubuntu Server 24.04.5 LTS.
- Virtualization platform: Oracle VirtualBox.
- Server hostname: `jane-sv`.
- Original administrative account: `jane`.
- Administration method: SSH from Windows PowerShell.

My terminal output shows a successful SSH login using `ssh -p 2222 jane@127.0.0.1`. The host-side port `2222` is the port used in this connection; the login alone does not establish all of the underlying VirtualBox networking settings.

## 3. Principle of Least Privilege

Least privilege means giving an account the access needed for its responsibilities. In my lab, `labadmin` initially received sudo access, while `labdev` received membership in a developer group without sudo access. I later removed the administrator's sudo membership.

The root account is the superuser with UID 0. `sudo` lets an authorized user run commands as another user, usually root, according to the system's sudo policy. Sudo also records administrative activity.

## 4. Commands Practiced

| Command | Purpose |
|---|---|
| `whoami`, `id`, `groups`, `getent` | Inspect accounts and group membership. |
| `sudo -l`, `sudo -l -U` | Inspect authorized sudo privileges. |
| `adduser`, `groupadd` | Create accounts and a group. |
| `usermod -aG`, `gpasswd -d` | Add or remove supplementary group membership. |
| `su`, `sudo -u` | Switch user or run an authorized command as another user. |
| `chown`, `chmod`, `ls` | Configure and verify directory ownership and permissions. |
| `journalctl`, `tail` | Investigate administrative activity. |

`visudo` is used to edit sudo configuration with syntax checking. I did not change sudo policy files in this exercise.

## 5. Practical Exercises

### Administrative Access Audit

I checked my `jane` account with `whoami`, `id`, `groups`, and `getent group sudo`. The group lookup returned:

```output
sudo:x:27:jane
```

My `sudo -l` output included:

```output
User jane may run the following commands on jane-sv:
    (ALL : ALL) ALL
```

I also listed local accounts with UIDs from 1000 through 65533 using `awk` on `/etc/passwd`. This is a useful basic inventory, but UID range alone does not definitively identify the purpose of every account.

### Role-Based User and Group Creation

I checked whether `labadmin` and `labdev` existed, then created them interactively with `sudo adduser`. I created `serverdevelopers`, added `labadmin` to `sudo`, and added `labdev` to `serverdevelopers` using `usermod -aG`. The `-a` option appends the supplementary group membership.

My checks showed:

```output
uid=1009(labadmin) gid=1009(labadmin) groups=1009(labadmin),27(sudo),100(users)
uid=1010(labdev) gid=1010(labdev) groups=1010(labdev),100(users),1011(serverdevelopers)
```

My initial group pre-check used `getent passwd serverdeverlopers`: it had both the wrong database and a misspelled group name. It therefore did not verify whether `serverdevelopers` already existed. The subsequent group creation and `id labdev` output show the intended group was present and assigned afterward.

### Administrative Access Verification

I switched to `labadmin` with `su - labadmin`. `whoami` returned `labadmin`, and `sudo whoami` returned:

```output
root
```

`sudo -l` showed that `labadmin` could run `(ALL : ALL) ALL` before revocation. I then switched to `labdev`. Its `sudo whoami` attempt returned:

```output
labdev is not in the sudoers file.
```

This demonstrated that the administrator could run the tested privileged command and the developer was denied at that point in the exercise.

### Shared Directory and SGID Configuration

I created `/opt/server-lab/developers`, assigned it to `root:serverdevelopers`, and applied mode `2770`:

```bash
sudo mkdir -p /opt/server-lab/developers
sudo chown root:serverdevelopers /opt/server-lab/developers/
sudo chmod 2770 /opt/server-lab/developers/
ls -ld /opt/server-lab/developers/
```

```output
drwxrws--- 2 root serverdevelopers 4096 Nov 26 05:23 /opt/server-lab/developers/
```

The `2` enables SGID on the directory; `770` grants the owner and group full ordinary directory permissions and none to others. The `s` in the group execute position shows SGID is set. New files normally inherit the directory's group, but SGID does not itself guarantee group write access; the file's creation mode and umask also matter.

I created a file as the developer and listed it:

```bash
sudo -u labdev touch /opt/server-lab/developers/application.txt
sudo ls -l /opt/server-lab/developers/
```

```output
total 0
-rw-rw-r-- 1 labdev serverdevelopers 0 Nov 26 05:25 application.txt
```

The file inherited `serverdevelopers` as its group. Its own mode was `664`; access to it also depends on being able to traverse the containing directories.

### Administrative Privilege Revocation

I checked `labadmin` with `sudo -l -U labadmin`, removed the account from the `sudo` group, and checked again:

```bash
sudo gpasswd -d labadmin sudo
id labadmin
sudo -l -U labadmin
```

```output
Removing user labadmin from group sudo
uid=1009(labadmin) gid=1009(labadmin) groups=1009(labadmin),100(users)
User labadmin is not allowed to run sudo on jane-sv.
```

The account database and sudo policy check showed revocation. I exited the earlier `labadmin` shell before removing membership; a fresh login and direct sudo test remain unverified. Existing sessions can retain their previous group membership until restarted.

### Administrative Log Investigation

I inspected recent sudo activity with `sudo journalctl -t sudo -n 15 --no-pager` and reviewed `/var/log/auth.log`. The authentication log recorded the group change:

```output
2026-11-26T05:26:52.764808+00:00 jane-sv gpasswd[1345]: user labadmin removed by root from group sudo
```

## 6. Verification Results

| Exercise | Result |
|---|---|
| Administrative audit | `jane` belonged to `sudo` and `sudo -l` showed broad privileges. |
| Role creation | `labadmin` and `labdev` were created and assigned their intended supplementary groups. |
| Sudo access | `labadmin` ran `sudo whoami` successfully; `labdev` was denied. |
| Shared directory | Mode `2770` and ownership were shown; the new file inherited `serverdevelopers`. |
| Revocation | `id` and `sudo -l -U` showed `labadmin` no longer had sudo membership or authorization; a fresh direct login test remains unverified. |
| Logging | The journal and authentication log recorded administrative activity. |

## 7. Errors and Troubleshooting

- My pre-creation check for the developer group queried `passwd` and misspelled the group name. A correct group lookup would use `getent group serverdevelopers` before creating it.
- `labdev` being denied sudo was the expected least-privilege result, not an exercise failure.

## 8. What I Learned

I learned to audit an administrator's privileges, assign separate roles, and verify access with an actual command. I practiced using SGID to inherit a shared directory's group and learned that group inheritance does not control all file permissions. I also learned to verify privilege removal and inspect administrative logs.

## 9. References

- Local manual pages: `man sudo`, `man sudoers`, `man adduser`, `man usermod`, `man gpasswd`, `man chmod`, and `man journalctl`.
