# Architecture

**Preliminary design:** the independent capstone is planned. Its final topology, configuration, and implementation have not been established. The existing lab below provides context for design decisions, not evidence of a completed capstone.

The recorded environment consists of a Windows host running Oracle VirtualBox and an Ubuntu Server virtual machine. The [environment snapshot](../../ubuntu-server-lab/environment-setup.md) records two allocated CPUs, an LVM-backed ext4 root filesystem, NAT networking, and an active SSH service. The [storage exercise](../../ubuntu-server-lab/03-storage-management/README.md) also records an ext4 filesystem mounted at `/mnt/data`.

The labs separately document SSH administration, account and group access, Nginx, firewall practice, backups, and monitoring. See [implementation](implementation.md) for the source records. These observations are snapshots from exercises, not proof that every component operated together continuously.

Future improvements could include an off-site backup, documented recovery objectives, and a verified infrastructure diagram after the configuration is rechecked.
