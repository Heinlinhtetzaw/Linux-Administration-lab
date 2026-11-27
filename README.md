# Linux System Administration Portfolio

## Overview

This repository documents my hands-on learning and practical experience in Linux System Administration, with a focus on developing foundational skills relevant to Systems Engineering, Cloud Infrastructure, and Data Center Modernization.

The portfolio includes Linux administration exercises, server configuration, Bash automation, technical documentation, and troubleshooting in two Linux environments.

## Lab Environments

| Environment | Platform | Purpose |
|---|---|---|
| Ubuntu 24.04 LTS | WSL2 | Linux fundamentals and foundational administration |
| Ubuntu Server 24.04 LTS | Oracle VirtualBox | Practical server administration and automation |

## Technical Skills Practiced

- Linux command-line operations and filesystem management
- User and group administration
- File ownership, permissions, and access control
- Process and service management using systemd
- Package management using APT and dpkg
- Network configuration inspection and connectivity troubleshooting
- Storage investigation using LVM, ext4, and mount configuration
- SSH remote administration and key-based authentication
- Nginx web server deployment
- Firewall configuration using UFW
- Backup, restoration, and integrity verification
- System monitoring and log analysis
- Bash scripting and scheduled tasks using cron
- Technical documentation

## Repository Structure

| Section | Description | Status |
|---|---|---|
| [WSL2 Ubuntu Lab](wsl2-ubuntu-lab/README.md) | Linux fundamentals and foundational administration | Guided practice documented |
| [Ubuntu Server Lab](ubuntu-server-lab/README.md) | Practical server administration | Guided practice documented |
| [WSL2 Automation](wsl2-ubuntu-lab/scripts/README.md) | Basic system monitoring | Implemented |
| [Server Automation](ubuntu-server-lab/scripts/README.md) | Monitoring, backup, and user provisioning | Implemented |
| [Small Business Linux Infrastructure](projects/small-business-linux-infrastructure/README.md) | Independent infrastructure capstone | Planned |

## Bash Automation

| Script | Purpose |
|---|---|
| [system-monitor.sh](wsl2-ubuntu-lab/scripts/system-monitor.sh) | Collect basic system health information |
| [system-health.sh](ubuntu-server-lab/scripts/system-health.sh) | Generate system health and service availability reports |
| [backup.sh](ubuntu-server-lab/scripts/backup.sh) | Automate file backups and SHA256 integrity verification |
| [user-management.sh](ubuntu-server-lab/scripts/user-management.sh) | Automate user and department group provisioning with interactive password setup |

## Technologies and Tools

Linux · Ubuntu · WSL2 · VirtualBox · Bash · OpenSSH · Nginx · UFW · LVM · ext4 · systemd · cron · tar · rsync · Git

## Project Scope and Limitations

This portfolio represents practical learning in controlled Linux environments rather than production infrastructure.

Individual lab documents describe results, troubleshooting, and known limitations.

The [storage lab](ubuntu-server-lab/03-storage-management/README.md) documents a resolved `fstab` parse error and a data mount verified after reboot. Active swap was verified; a swap-file warning remains a non-blocking observation. Some scheduled runs and other checks remain unverified; see the individual reports.

The Small Business Linux Infrastructure capstone is planned as a separate practical implementation to demonstrate the independent application of these administration skills.

## Future Development

- Independent Linux infrastructure deployment
- Advanced networking and troubleshooting
