# Ubuntu Server Backup and Restore

## 1. Objective

My objective was to create and inspect backups, verify an archive's checksum, restore practice files, synchronize a directory with `rsync`, and archive my Nginx website files.

## 2. Lab Environment

I worked on my Ubuntu Server virtual machine, `jane-sv`, using my existing SSH connection. I used `/mnt/data/backups/` on an additional virtual disk for the lab and created disposable sample files under `~/backup-lab/`.

The virtual disks are on the same physical laptop, so this is backup practice rather than a complete disaster recovery solution. The 3-2-1 principle recommends three copies of data, on two types of media, with one copy off-site. A backup also needs a tested restoration process.

## 3. Commands Practiced

| Command | Purpose |
|---|---|
| `findmnt`, `df` | Verify the backup filesystem and inspect its capacity. |
| `tar` | Create, list, and extract archives. |
| `sha256sum` | Record and check a file checksum. |
| `diff` | Compare directory contents. |
| `rsync` | Copy and synchronize files. |
| `mkdir`, `chown`, `chmod`, `ls`, `cat` | Prepare directories, set permissions, and inspect files. |

## 4. Practical Exercises

### Backup Storage Preparation

Before writing to the backup destination, I confirmed that the expected filesystem was mounted:

```bash
findmnt --mountpoint /mnt/data/
```

```output
TARGET    SOURCE    FSTYPE OPTIONS
/mnt/data /dev/sdb1 ext4   rw,relatime
```

My `df -hT /mnt/data/` output showed a 9.8G ext4 filesystem with 9.3G available. I created `/mnt/data/backups/`, assigned it to my user and primary group, and ran `chmod 700` on it. I then created separate source and restore directories with three simulated business files.

### Compressed Backup Using Tar

I created a compressed archive from the sample source directory:

```bash
tar -czvf /mnt/data/backups/business-data.tar.gz -C "$HOME/backup-lab" source
```

The options create an archive (`-c`), compress it with gzip (`-z`), show processed files (`-v`), and name the archive (`-f`). `-C` changes the working directory for the archive operation. I listed the archive contents:

```bash
tar -tzf /mnt/data/backups/business-data.tar.gz
```

```output
source/
source/config.txt
source/report.txt
source/employees.txt
```

### Backup Integrity Verification

I saved and checked a SHA256 checksum for the archive:

```bash
cd /mnt/data/backups/
sha256sum business-data.tar.gz > business-data.sha256
sha256sum -c business-data.sha256
```

```output
business-data.tar.gz: OK
```

This shows the archive matched the checksum I recorded. A checksum helps detect changes relative to that recorded value; it does not by itself prove that every desired file was included or that the archive can be restored.

### File Restoration

I extracted the archive into my separate restore directory:

```bash
tar -xzvf /mnt/data/backups/business-data.tar.gz -C "$HOME/backup-lab/restore"
```

```output
source/
source/config.txt
source/report.txt
source/employees.txt
```

I listed the restored files and compared the original and restored directories with `diff -r`. The comparison printed no output in the captured session. The commands and listing demonstrate that the practice files could be extracted into a separate location.

### Accidental Data Loss and Recovery

I simulated a missing file by interactively deleting the disposable `report.txt` from my source directory. I then restored that file from the archive:

```bash
tar -xzf /mnt/data/backups/business-data.tar.gz -C "$HOME/backup-lab" source/report.txt
cat ~/backup-lab/source/report.txt
```

```output
Business operations report
```

I ran the recursive directory comparison again; it printed no output before I made later changes to the report for the rsync exercise.

### Directory Synchronization Using Rsync

I confirmed that `rsync` was installed and copied the practice directory to `/mnt/data/backups/business-sync/`:

```bash
rsync -avh ~/backup-lab/source /mnt/data/backups/business-sync/
```

```output
sending incremental file list
source/
source/config.txt
source/employees.txt
source/report.txt

sent 360 bytes  received 77 bytes  874.00 bytes/sec
total size is 77  speedup is 0.18
```

I appended `Updated business report` to the source report, then ran rsync using `source/` with a trailing slash. The initial command copied the `source` directory itself; the later command copied its contents directly into `business-sync/`. I ran the contents-copy command again, and no filenames appeared in its transfer listing. My destination report contained:

```output
Business operations report
Updated business report
```

`-a` selects archive mode, `-v` shows details, and `-h` makes numbers human-readable. The source trailing slash affects the destination layout. A synchronized copy is useful, but changes can overwrite earlier destination content; retaining historical versions requires an additional strategy.

### Nginx Website Archive

I created a compressed archive containing the website directory and set the archive's permissions to `600`. The displayed contents were:

```output
var/www/html/
var/www/html/index.nginx-debian.html
var/www/html/server-lab.html
```

My final listing showed the archive was owned by root and had `-rw-------` permissions. I inspected its contents without restoring files over the running website.

## 5. Verification Results

| Exercise | Recorded result |
|---|---|
| Backup storage | `/dev/sdb1` was mounted read/write at `/mnt/data`. |
| Tar archive | The archive listing showed the source directory and three sample files. |
| Integrity | The archive matched its recorded SHA256 checksum. |
| Restore | The files were extracted into the restore directory; the deleted report was recovered and read. |
| Rsync | The destination report contained both the original and updated lines. |
| Website archive | The archive listing showed the Nginx website files, and its displayed mode was `600`. |

## 6. Errors and Troubleshooting

- I typed `cdmod` instead of `chmod` when setting the backup directory permissions. The shell reported that the command was not found, and I reran it as `chmod 700`.
- My first single-file restore used `soruce/report.txt`. Tar reported that the path was not in the archive. I corrected it to `source/report.txt`, restored the file, and read its content.
- My first Nginx archive command looked for `var/www/html` relative to `/etc/nginx` and failed. I reran tar with the absolute website path, then listed the resulting archive.

## 7. What I Learned

I learned to confirm a mounted backup destination, inspect an archive, check its checksum, and test recovery by extracting files. I also saw how an rsync trailing slash changes the destination layout and why a successful backup process should be followed by a restore test.

Recovery point objective (RPO) describes the maximum acceptable data loss measured in time; recovery time objective (RTO) describes the target time to restore service. Both help guide a backup and recovery plan.

## 8. References

- Local manual pages: `man tar`, `man rsync`, `man sha256sum`, `man diff`, `man findmnt`, and `man df`.

