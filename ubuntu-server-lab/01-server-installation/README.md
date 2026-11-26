# Ubuntu Server Installation and Initial Configuration

## 1. Objective

My objective was to install Ubuntu Server in Oracle VirtualBox and create a dedicated command-line environment for Linux system administration practice.

## 2. Installation Environment

My installation notes record the following setup:

| Component | Configuration |
|---|---|
| Host operating system | Windows 11 |
| Virtualization software | Oracle VirtualBox 7.0.20 |
| Installation image | Ubuntu Server 24.04.3 LTS, amd64 |
| Virtual CPUs | 2 |
| Allocated memory | 2 GB |
| Virtual disk | 30 GB, dynamically allocated VDI |
| Network mode | NAT |
| Storage | LVM |
| Interface | Command-line interface |

My existing [environment shttps://chatgpt.com/share/6b07b403-0a2c-83ec-8c16-78a05c380ac1etup notes](../environment-setup.md) record the installed system as Ubuntu 24.04.5 LTS. The installation-image version and the installed system version describe different points in time; the supplied notes do not show when or how the version changed.

## 3. Installation Media Preparation

I used an Ubuntu Server 24.04.5 LTS ISO for the virtual machine.

```powershell
Get-FileHash .\ubuntu-24.04.3-live-server-amd64.iso -Algorithm SHA256
```

Calculating a hash and comparing it with a trusted published checksum can help confirm the image's integrity.

## 4. Virtual Machine Configuration

I configured a Linux virtual machine with two virtual CPUs, 2048 MB of memory, and a 30 GB dynamically allocated VDI. A dynamically allocated disk grows as data is written, up to its configured capacity; the virtual capacity is not necessarily the host disk space immediately used.

I selected NAT networking so the guest could use the host's network connection. NAT can allow outbound connectivity, but reaching a guest service from another system depends on the VirtualBox networking and any required port forwarding.

## 5. Ubuntu Server Installation

1. I created the VirtualBox virtual machine and configured its resources.
2. I booted from the Ubuntu Server ISO and completed the installer.
3. I selected LVM-based storage and created my initial user.
4. I rebooted the virtual machine and reached the command-line login.

This as a CLI-based server setup without a desktop environment. LVM manages storage through physical volumes, volume groups, and logical volumes. My existing environment notes identify the root device as `/dev/mapper/ubuntu--vg-ubuntu--lv` with an ext4 filesystem.

## 6. Initial Server Configuration

| Component | Recorded configuration |
|---|---|
| Hostname | `jane-sv` |
| User | `jane` |
| Network | VirtualBox NAT |
| Remote access | OpenSSH |
| Service manager | systemd |

My existing environment report that the SSH service was active and enabled and that it listened on port 22.

## 7. Post-Installation Verification

I run these commands as checks for the server environment:

| Command | Purpose |
|---|---|
| `hostnamectl`, `cat /etc/os-release`, `uname -r` | Inspect the system identity, distribution, and kernel. |
| `whoami` | Identify the current user. |
| `lscpu`, `free -h` | Inspect processor and memory information. |
| `lsblk`, `df -h` | Inspect storage devices and filesystem usage. |
| `ip addr`, `ip route` | Inspect addresses and routes. |
| `systemctl status ssh` | Inspect the SSH service. |
| `uptime` | Inspect uptime and load averages. |
My [environment setup notes](../environment-setup.md) provide a written summary, including two allocated CPUs, approximately 1.9 GiB of visible memory, an LVM root filesystem, and an active SSH service.

## 8. Installation Issues and Troubleshooting

I investigated the virtual optical disk configuration and the virtual machine's saved state, and that the server login interface later became available.

I also noted that the absence of a graphical mouse cursor in the text-based server console was expected for this CLI environment.

## 9. Installation Results

I installed Ubuntu Server, configured the VM resources and LVM storage, created the user and hostname, and reached the command-line login.And also NAT networking and OpenSSH setup.

- The ISO checksum value and its match against a trusted checksum.
- Terminal output for the post-installation checks, including the system version, storage, and SSH service state.
- A successful network test and a remote SSH connection, if I want to demonstrate those separately.


## 10. What I Learned

I learned the purpose of configuring virtual machine resources, dynamically allocated storage, NAT networking, and LVM for a server lab. I also learned that an installed SSH service and an actual remote connection are separate things to verify, and that installation-image integrity requires comparing the calculated hash with a trusted value.

## 11. References

- [Ubuntu Server Documentation](https://documentation.ubuntu.com/server/)
- [Oracle VirtualBox Documentation](https://www.virtualbox.org/manual/)
- [My Ubuntu Server Environment Setup](../environment-setup.md)
