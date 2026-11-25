# Linux File Permissions and Ownership

## 1. Objective

My objective was to understand Linux file ownership and permissions, secure a developer directory, verify access as different users, and observe how `umask` affects newly created files and directories.

## 2. Lab Environment

I worked in Ubuntu on WSL2 and reused the `labalice` account and `labdevelopers` group from my previous exercise. My permissions lab was `~/linux-fundamentals-lab/permissions-lab/developers/`; my `umask` practice was in `~/linux-fundamentals-lab/umask-lab/`.

Before beginning, I verified Alice's membership:

```bash
id labalice
getent group labdevelopers
```

```output
uid=1007(labalice) gid=1009(labalice) groups=1009(labalice),1007(labdevelopers)
labdevelopers:x:1007:labalice
```

## 3. File Ownership and Permission Fundamentals

A file has an owner and an owning group. Permissions are shown separately for the owner, the group, and others. I inspected `/etc/passwd`:

```bash
ls -l /etc/passwd
```

```output
-rw-r--r-- 1 root root 1672 Nov 25 12:30 /etc/passwd
```

The first character, `-`, identifies a regular file. The next three characters, `rw-`, allow the owner to read and write. The next `r--` allows the group to read, and the last `r--` allows others to read. The first `root` is the owner and the second is the owning group.

| Permission | Numeric value | File | Directory |
|---|---:|---|---|
| `r` | 4 | Read contents. | List entry names. |
| `w` | 2 | Modify contents. | Create or remove entries when traversal is also allowed. |
| `x` | 1 | Execute a program or script. | Traverse or access entries by name. |

Numeric modes combine these values for owner, group, and others. For example, `640` means read and write for the owner, read for the group, and no ordinary permissions for others. Directory access also depends on permissions on parent directories; listing details generally requires traversal as well as directory read permission.

## 4. Commands Practiced

| Command | Purpose |
|---|---|
| `ls -l`, `ls -ld` | Inspect file and directory permissions and ownership. |
| `chmod` | Change permission bits. |
| `chown` | Change the owner and optionally the group. |
| `sudo -u` | Run an authorized command as another user for access testing. |
| `umask` | Inspect or set the mask for permissions on newly created items. |

`chgrp` changes group ownership and `stat` displays detailed metadata.

## 5. Practical Exercises

### Numeric Permissions

I created `report.txt` and `private.txt` in my lab directory. Both were initially owned by `heinlinhtetzaw:generaluser` with mode `644`. I set the report to `644` and the private file to `600`:

```bash
chmod 644 permissions-lab/developers/report.txt
chmod 600 permissions-lab/developers/private.txt
ls -l permissions-lab/developers/
```

```output
total 0
-rw------- 1 heinlinhtetzaw generaluser 0 Nov 25 12:47 private.txt
-rw-r--r-- 1 heinlinhtetzaw generaluser 0 Nov 25 12:47 report.txt
```

Mode `600` gives the owner read and write access and no ordinary permissions to the group or others. Mode `644` also allows group and other users to read, subject to directory traversal permissions.

### Symbolic Permissions

I added group write permission and removed read permission from others on the report:

```bash
chmod g+w permissions-lab/developers/report.txt
chmod o-r permissions-lab/developers/report.txt
ls -l permissions-lab/developers/report.txt
```

```output
-rw-rw---- 1 heinlinhtetzaw generaluser 0 Nov 25 12:47 permissions-lab/developers/report.txt
```

The final mode was `660`. In symbolic notation, `+` adds permissions, `-` removes them, and `=` sets the specified permissions.

### File and Group Ownership

I changed the report's owner and group using `chown`:

```bash
sudo chown labalice:labdevelopers permissions-lab/developers/report.txt
ls -l permissions-lab/developers/report.txt
```

```output
-rw-rw---- 1 labalice labdevelopers 0 Nov 25 12:47 permissions-lab/developers/report.txt
```

My later directory listing showed that `private.txt` still belonged to `heinlinhtetzaw:generaluser`, with mode `600`. I did not perform the specified change of that file to `labalice:labdevelopers`. Consequently, Alice's access to the private file is not established by my tests.

### Department Directory Permissions

I assigned the directory to root and the developer group, then set mode `770`:

```bash
sudo chown root:labdevelopers permissions-lab/developers/
sudo chmod 770 permissions-lab/developers/
ls -ld permissions-lab/developers/
```

```output
drwxrwx--- 2 root labdevelopers 4096 Nov 25 12:47 permissions-lab/developers/
```

The owner and owning group have read, write, and execute permissions on the directory. Others have no ordinary directory permissions.

### Authorized and Unauthorized Access Verification

I created the temporary `labvisitor` account. I used `sudo -u labalice` to list the directory:

```bash
sudo -u labalice ls -l permissions-lab/developers/
```

```output
total 0
-rw------- 1 heinlinhtetzaw generaluser   0 Nov 25 12:47 private.txt
-rw-rw---- 1 labalice       labdevelopers 0 Nov 25 12:47 report.txt
```

Being able to list a filename does not by itself mean Alice can read the file. I appended to the report as Alice and read it back:

```bash
sudo -u labalice bash -c 'echo "Developer report" >> permissions-lab/developers/report.txt'
sudo -u labalice cat permissions-lab/developers/report.txt
```

```output
Developer report
```

I then tested a directory listing as the visitor:

```bash
sudo -u labvisitor ls permissions-lab/developers/
```

```output
ls: cannot open directory 'permissions-lab/developers/': Permission denied
```

The denied listing is the expected result for this access test. I did not separately capture `id labvisitor` or a root access test, so those details remain unverified in my transcript.

### Default Permissions Using umask

My current shell's mask was `0022`, shown symbolically as `u=rwx,g=rx,o=rx`. A umask removes permission bits from the permissions requested when creating an item; typical starting modes are `666` for files and `777` for directories. It is a bit mask, not ordinary subtraction.

I used a subshell for each test so its mask would not change my current shell:

```bash
(
    umask 022
    touch public.txt
    mkdir public-dir
    ls -ld public.txt public-dir
)
```

```output
drwxr-xr-x 2 heinlinhtetzaw generaluser 4096 Nov 25 13:01 public-dir
-rw-r--r-- 1 heinlinhtetzaw generaluser    0 Nov 25 13:01 public.txt
```

With a more restrictive mask:

```bash
(
    umask 077
    touch private.txt
    mkdir private-dir
    ls -ld private.txt private-dir
)
```

```output
drwx------ 2 heinlinhtetzaw generaluser 4096 Nov 25 13:02 private-dir
-rw------- 1 heinlinhtetzaw generaluser    0 Nov 25 13:02 private.txt
```

Afterward, `umask` still returned `0022`. These results reflect the modes requested by the commands and my lab environment; applications and default access-control lists can affect new permissions.

## 6. Verification Results

| Exercise | Result |
|---|---|
| Numeric and symbolic permissions | Verified `600` for the private file and `660` for the report. |
| File ownership | Verified the report belongs to `labalice:labdevelopers`; the private file retained its original ownership. |
| Directory permissions | Verified `root:labdevelopers` and mode `770`. |
| Access tests | Alice listed the directory and wrote and read the report; the visitor's listing was denied. Root access and visitor group membership were not separately tested. |
| Default permissions | Verified file and directory results for masks `022` and `077`; the parent shell remained at `0022`. |

## 7. Errors and Troubleshooting

- My first `mkdir permissions-lab/developers` failed because the parent directory did not exist. I corrected it with `mkdir -p`.
- I typed `cdmod` instead of `chmod`; the shell reported that the command was not found. I corrected the command and verified the resulting mode.
- My first attempt to change the report's owner without `sudo` returned `Operation not permitted`. I used `sudo chown` and verified the final ownership.
- My preliminary visitor lookup used `labvistor` instead of `labvisitor`. It therefore did not check the intended name before creation. The following `useradd` command returned without a visible error, and the access test ran as `labvisitor`.

## 8. What I Learned

I learned to read owner, group, and other permissions, and to use numeric and symbolic modes. I saw that `chmod` changes permissions while `chown` changes ownership, and that directory traversal affects access. Testing as different users helped me distinguish an allowed operation from an expected permission denial. I also observed how `umask` affects new files and directories.

## 9. References

- Local documentation: `man chmod`, `man chown`, `man chgrp`, `man stat`, and `help umask`.
- My exercise specification and recorded terminal output.
