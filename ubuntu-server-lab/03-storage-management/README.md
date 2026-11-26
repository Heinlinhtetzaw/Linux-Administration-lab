# Ubuntu Server Storage Management

## 1. Objective

My objective was to investigate my Ubuntu Server's disks, filesystems, LVM configuration, mount settings, and storage usage. I also verified that I could write and read a file on the additional mounted disk.

## 2. Lab Environment

I worked on my Ubuntu Server virtual machine, `jane-sv`, using the `jane` account. My server runs in Oracle VirtualBox, and the exercise used my existing SSH administration setup. The storage layout and usage shown below are snapshots from the supplied terminal session.

I investigated existing storage rather than repartitioning or formatting a disk. The exercise notes describe earlier partitioning and mount setup, but the terminal output does not show those earlier operations.

## 3. Storage Architecture

In a basic layout, a disk contains partitions, a partition can contain a filesystem, and the filesystem becomes accessible through a mount point. My additional disk follows this pattern: `/dev/sdb` → `/dev/sdb1` → ext4 → `/mnt/data`.

My root filesystem uses LVM. A physical volume (PV) supplies storage to a volume group (VG), and a logical volume (LV) is allocated from that group. My root path is `/dev/sda3` → PV → `ubuntu-vg` → `ubuntu-lv` → ext4 → `/`. LVM can make storage allocation more flexible, but it does not replace backups or RAID.

## 4. Commands Practiced

| Command | Purpose |
|---|---|
| `lsblk`, `fdisk -l`, `blkid` | Inspect block devices, partition tables, and filesystem identifiers. |
| `pvs`, `vgs`, `lvs` and their display commands | Inspect LVM physical volumes, volume groups, and logical volumes. |
| `findmnt`, `findmnt --verify` | Inspect mounts and check filesystem configuration. |
| `df`, `du` | Inspect filesystem capacity, inode usage, and directory space usage. |
| `mkdir`, `chown`, `echo`, `cat`, `ls` | Create and verify a small read/write test. |

`fdisk -l` listed partition information in this session; it did not modify a partition table. Formatting and partition modification can destroy data and require separate planning and verification.

## 5. Practical Exercises

### Disk and Partition Investigation

I listed my devices and mount points:

```bash
lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINTS
```

```output
NAME                       SIZE TYPE FSTYPE      MOUNTPOINTS
sda                         30G disk
├─sda1                       1M part
├─sda2                       2G part ext4        /boot
└─sda3                      28G part LVM2_member
  └─ubuntu--vg-ubuntu--lv   14G lvm  ext4        /
sdb                         10G disk
└─sdb1                      10G part ext4        /mnt/data
sr0                       1024M rom
```

I also used `sudo fdisk -l`, `sudo blkid`, and `df -hT`. The primary disk had a GPT partition table, and the additional disk had a DOS partition table. `blkid` identified ext4 filesystems on `/dev/sda2`, the root logical volume, and `/dev/sdb1`.

### LVM Configuration Investigation

I inspected the physical volume, volume group, and logical volume with `sudo pvs`, `sudo vgs`, and `sudo lvs`. My volume group result was:

```output
  VG        #PV #LV #SN Attr   VSize   VFree
  ubuntu-vg   1   1   0 wz--n- <28.00g 14.00g
```

`/dev/sda3` was the physical volume, and `ubuntu-lv` was the root logical volume at less than 14 GiB. The volume group had 14 GiB free for possible future allocation. This free volume-group capacity is different from the free space already available inside the root filesystem. I did not resize the logical volume.

### Additional Virtual Disk Configuration

The exercise notes describe previously configuring the 10 GiB additional disk and partitioning it with `fdisk`. My current `lsblk` and `fdisk -l` results verify that `/dev/sdb1` exists, but I forgot to captured the historical partitioning commands or my terminal output.

### Ext4 Filesystem Creation

The exercise notes describe earlier ext4 formatting with `mkfs.ext4`. My current `blkid` and mount checks show that `/dev/sdb1` contains an ext4 filesystem; they do not independently verify the earlier formatting command. I did not run `mkfs.ext4` in this verification session.

### Persistent Mount Configuration

I checked the active mount:

```bash
findmnt /mnt/data
```

```output
TARGET    SOURCE    FSTYPE OPTIONS
/mnt/data /dev/sdb1 ext4   rw,relatime
```

I inspected `/etc/fstab` and compared the UUID in its separate `/mnt/data` entry with `sudo blkid /dev/sdb1`; both contained `b084b61e-5ada-4bc4-bf8a-be3e03a31628`. A filesystem UUID can identify a filesystem more consistently than a device name when device discovery order changes.

However, my `fstab` output also showed a malformed line joining the swap entry to a second, incomplete mount entry:

```output
/swap.img       none    swap    sw      0       0UUID=b084b61e-5ada-4bc4-bf8a-be3e03a31628 /mnt/data ext4 defaults,nofail 0 2
UUID=b084b61e-5ada-4bc4-bf8a-be3e03a31628 /mnt/data ext4 defaults,nofail 0 2
```

The first line is malformed; the second is a separate entry. I validated the file with `sudo findmnt --verify`, which reported a parse error on line 12 and a warning that systemd was using an older configuration. After I ran `systemctl daemon-reload` and authenticated, the warning disappeared, but the parse error remained:

```output
findmnt: /etc/fstab: parse error at line 12 -- ignored

1 parse error, 0 errors, 0 warnings
```

The current mount is verified, but the malformed configuration remains unresolved in the supplied output. It may affect the swap entry and future mount behavior; the transcript does not establish the swap state or a successful reboot with this configuration. I should review and correct the file before relying on it for startup. Reloading systemd did not repair the malformed line.

The exercise notes also describe earlier use of `mount -a` and persistent mount setup, but those earlier commands are not capture. `systemctl daemon-reload` is shown in the current session as described above.

### Storage Read and Write Verification

I confirmed the mount with `findmnt --mountpoint /mnt/data` before creating a test directory. I assigned the directory to my current user and primary group, wrote a test file, and read it back:

```bash
sudo mkdir -p /mnt/data/storage-lab
sudo chown "$(id -un):$(id -gn)" /mnt/data/storage-lab/
echo "Storage read and write verification" > /mnt/data/storage-lab/test.txt
cat /mnt/data/storage-lab/test.txt
```

```output
Storage read and write verification
```

I checked which filesystem held the file:

```output
Filesystem     Type  Size  Used Avail Use% Mounted on
/dev/sdb1      ext4  9.8G   36K  9.3G   1% /mnt/data
```

This verifies read and write access to the currently mounted filesystem during the session. I kept `storage-lab` for the later backup exercise.

### Storage Capacity and Inode Monitoring

My `df -h` snapshot showed the root filesystem at 40% usage and `/mnt/data` at 1%. My `df -i` snapshot showed 11% inode usage on root and 1% on `/mnt/data`. Inodes store file metadata; a filesystem can exhaust inodes even if data space remains.

I used `du` to investigate directory usage:

```bash
sudo du -sh /var/log
sudo du -sh /mnt/data/
```

```output
229M    /var/log
32K     /mnt/data/
```

`df` reports filesystem accounting, while `du` examines file and directory usage, so their measurements can differ. My `du -xh --max-depth=1 /var | sort -hr` output identified `/var/cache`, `/var/lib`, and `/var/log` as the largest displayed directories under `/var`.

## 6. Verification Results

| Exercise | Result |
|---|---|
| Disks and filesystems | Identified the 30 GiB primary disk, 10 GiB additional disk, partitions, ext4 filesystems, and mount points. |
| LVM | Verified the root PV, VG, LV, and 14 GiB of free VG capacity. |
| Current data mount | `/dev/sdb1` was mounted read/write at `/mnt/data`; the test file was written and read there. |
| Persistent configuration | The data UUID matched, but `findmnt --verify` reported an unresolved parse error. Persistence across reboot and the swap entry remain unverified. |
| Capacity and inodes | Inspected filesystem usage, inode usage, and directory consumption. |
| Historical setup | The exercise notes describe partitioning, formatting, and mount setup; those historical operations are not shown in the supplied terminal output. |

## 7. Errors and Troubleshooting

The `/etc/fstab` parse error is the main unresolved issue. My output shows the swap line and an extra `/mnt/data` entry joined together, followed by a separate `/mnt/data` entry.

The initial systemd warning cleared after `systemctl daemon-reload`, but the parse error remained.

## 8. What I Learned

I learned to distinguish a disk, partition, filesystem, and mount point, and to trace my root filesystem through LVM. I verified a real read/write operation after confirming the mount and saw why free volume-group capacity is not the same as filesystem free space. I also learned to check both space and inodes and to treat a persistent-mount configuration error separately from a currently working mount.

## 9. References

- Local manual pages: `man lsblk`, `man fdisk`, `man blkid`, `man fstab`, `man mount`, `man lvm`, `man df`, and `man du`.
- My exercise specification and recorded terminal output.
