# Linux User and Group Management

## 1. Objective

My objective was to practice creating and managing temporary Linux users and groups. I investigated my own account, assigned department memberships, managed passwords, switched users, and simulated employee offboarding.

## 2. Lab Environment

I performed this exercise in Ubuntu 24.04.5 LTS on WSL2. My temporary accounts were `labalice` and `labbob`, and my department groups were `labdevelopers` and `labitsupport`. I kept `labalice` and `labdevelopers` for the upcoming file permissions exercise.

## 3. User and Group Fundamentals

Linux can support multiple user accounts. The root account has UID 0 and administrative privileges. Regular accounts are used by people, while system accounts are commonly used by services.

A group helps manage access for several users. Each user has a primary group and can also belong to supplementary groups. In my lab, `labalice` had `labalice` as her primary group and `labdevelopers` as a supplementary group.

## 4. Important Configuration Files

| File or directory | Purpose |
|---|---|
| `/etc/passwd` | Local account details, including UID, primary GID, home directory, and shell. |
| `/etc/shadow` | Protected password hashes and password aging information. |
| `/etc/group` | Local group information. |
| `/etc/gshadow` | Protected group information. |
| `/etc/skel/` | Default files that may be copied into a new home directory. |
| `/etc/sudoers` | Sudo privilege configuration. |

I inspected the root account entry:

```bash
grep "^root:" /etc/passwd
```

```output
root:x:0:0:root:/root:/bin/bash
```

The fields contain the name, password placeholder, UID, GID, description, home directory, and login shell. The `x` is a placeholder; password information is normally stored separately. I did not include password hashes in this documentation.

## 5. Commands Practiced

| Command | Purpose |
|---|---|
| `whoami`, `id`, `groups` | Inspect my current identity and group membership. |
| `getent` | Look up account and group records. |
| `groupadd`, `groupdel` | Create and delete groups. |
| `useradd`, `usermod`, `userdel` | Create, modify, and delete user accounts. |
| `passwd`, `chage` | Manage passwords and inspect password aging. |
| `su`, `sudo` | Switch identity or run a command with authorized privileges. |
| `gpasswd` | Manage group membership. |

## 6. Practical Exercises

### Current User Investigation

I checked my identity with `whoami`, `id`, `groups`, and `getent`. My `id` output was:

```output
uid=1000(heinlinhtetzaw) gid=1000(generaluser) groups=1000(generaluser),4(adm),24(cdrom),27(sudo),30(dip),46(plugdev),100(users)
```

My UID was `1000`, my primary group was `generaluser`, and I was also a member of `sudo`. My account record showed my home directory and shell:

```output
heinlinhtetzaw:x:1000:1000:,,,:/home/heinlinhtetzaw:/bin/bash
```

### Group Creation

I checked the proposed account and group names, then created the department groups:

```bash
sudo groupadd labdevelopers
sudo groupadd labitsupport
getent group labdevelopers
getent group labitsupport
```

```output
labdevelopers:x:1007:
labitsupport:x:1008:
```

My initial lookup for `labdevelopers` was misspelled as `labdevelopres`, so that lookup did not verify whether the intended name already existed. The successful creation and subsequent lookup show that the intended group was created.

### User Account Creation

I created the two temporary accounts with home directories and Bash login shells. The `-m` option requests a home directory, and `-s` sets the login shell. I corrected a shell typo while creating Bob, as described in the troubleshooting section. I set both passwords interactively; my terminal reported `passwd: password updated successfully` for each.

I verified the identities and home directories:

```bash
id labalice
id labbob
ls -ld /home/labalice/ /home/labbob/
```

```output
uid=1007(labalice) gid=1009(labalice) groups=1009(labalice)
uid=1008(labbob) gid=1010(labbob) groups=1010(labbob)
drwxr-x--- 2 labalice labalice 4096 Nov 25 12:20 /home/labalice/
drwxr-x--- 2 labbob   labbob   4096 Nov 25 12:20 /home/labbob/
```

### Group Membership Management

I added Alice and Bob to their department groups:

```bash
sudo usermod -aG labdevelopers labalice
sudo usermod -aG labitsupport labbob
```

`-G` specifies supplementary groups, while `-a` appends the membership. Omitting `-a` can replace existing supplementary memberships. My checks showed:

```output
uid=1007(labalice) gid=1009(labalice) groups=1009(labalice),1007(labdevelopers)
uid=1008(labbob) gid=1010(labbob) groups=1010(labbob),1008(labitsupport)
```

```output
labdevelopers:x:1007:labalice
labitsupport:x:1008:labbob
```

I then removed Bob from `labitsupport`. After correcting my first `gpasswd` attempt, the terminal reported:

```output
Removing user labbob from group labitsupport
```

The following `id labbob` output showed only his primary group:

```output
uid=1008(labbob) gid=1010(labbob) groups=1010(labbob)
```

I ran `sudo usermod -aG labitsupport labbob` to add him back, but did not capture a separate verification before deleting his account.

### Switching Users

I used `su - labalice` to start a login shell as Alice. In that shell, my commands returned:

```bash
whoami
pwd
groups
```

```output
labalice
/home/labalice
labalice labdevelopers
```

I exited the shell, and `whoami` returned `heinlinhtetzaw`. I also ran `sudo -u labalice whoami`, which returned `labalice`. Unlike `su -`, this runs a specific authorized command as the selected user.

### Password Management

I inspected Alice's password status and aging information using `sudo passwd -S labalice` and `sudo chage -l labalice`. I then expired her password with `sudo passwd -e labalice`. My follow-up aging check included:

```output
Last password change                                    : password must be changed
Password expires                                        : password must be changed
Password inactive                                       : password must be changed
Account expires                                         : never
Minimum number of days between password change          : 0
Maximum number of days between password change          : 99999
Number of days of warning before password expires       : 7
```

This indicates that Alice must change her password at the next applicable login. The transcript does not show a subsequent login or password change.

### Account Locking and Unlocking

I locked and unlocked Bob's password with `sudo passwd -l labbob` and `sudo passwd -u labbob`. The status checks showed:

```output
labbob L 2026-11-25 0 99999 7 -1
```

```output
labbob P 2026-11-25 0 99999 7 -1
```

`L` indicates a locked password and `P` indicates a usable password. Locking a password does not necessarily block other authentication methods, such as SSH keys.

### User and Group Removal

To simulate offboarding, I ran `sudo userdel -r labbob`. The `-r` option removes the user's home directory and mail spool where applicable. I checked the account and home directory:

```bash
getent passwd labbob
ls -ld /home/labbob
```

`getent` printed no entry, and the home-directory check returned:

```output
ls: cannot access '/home/labbob': No such file or directory
```

I removed `labitsupport` with `sudo groupdel labitsupport`; the subsequent `getent group labitsupport` printed no entry. Before removing an actual employee account, I would follow the organization's offboarding and data-retention procedures.

## 7. Verification Results

| Exercise | Result |
|---|---|
| Current account | Verified UID, primary group, supplementary groups, account record, and `sudo` group membership. |
| Group and user creation | Both groups and users were shown; both home directories were listed. |
| Department assignments | Verified Alice and Bob in their respective groups. |
| User switching | Verified Alice's identity, home directory, and groups, then returned to my account. |
| Password management | Verified Alice's expired-password status and Bob's locked and unlocked password status. |
| Membership removal | Verified Bob was removed from `labitsupport`; his re-addition was not separately verified. |
| Offboarding | Bob's account and home directory and the `labitsupport` group were absent in subsequent checks. |

## 8. Errors and Troubleshooting

- I typed `gorups` instead of `groups`. The shell reported the command was not found, and I corrected it.
- My initial check used `labdevelopres` instead of `labdevelopers`. This did not check the intended group name before creation.
- I initially used `/bin/basg` as Bob's shell. `useradd` warned that the shell was missing or not executable, but the account was created. A retry reported that the user already existed. I deleted and recreated the account with `/bin/bash`; the later account record confirmed the corrected shell.
- Because I first deleted Bob without `-r`, his home directory remained. On recreation, `useradd` warned that the directory already existed and did not copy files from `/etc/skel`. The directory existed and was owned by Bob, but its complete contents were not verified. An attempted listing returned permission denied for my current user.
- My first `gpasswd` command used `0d` instead of `-d` and displayed usage information. My corrected attempt reported successful removal, and `id` confirmed it.
- `userdel -r` reported `userdel: labbob mail spool (/var/mail/labbob) not found`. The subsequent checks showed the account and home directory were absent; the message concerns the missing mail spool.

## 9. What I Learned

I learned to check accounts and groups before changing them, distinguish primary from supplementary groups, and verify changes with `id` and `getent`. I practiced password expiry and locking, switching identities, and removing a temporary account. I also learned that a warning can accompany a partially completed operation, so I need to inspect the result before retrying.

## 10. References

- Local manual pages: `man useradd`, `man usermod`, `man userdel`, `man groupadd`, `man groupdel`, `man passwd`, `man chage`, `man id`, and `man 5 passwd`.
- My exercise specification and recorded terminal output.
