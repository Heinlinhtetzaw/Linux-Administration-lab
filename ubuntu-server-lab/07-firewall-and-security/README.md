# Ubuntu Server Firewall and Security

## 1. Objective

My objective was to inspect and configure a basic UFW firewall, practice adding and removing a rule, investigate SSH security settings, and review the server's security and operational state.

## 2. Lab Environment

I worked on my Ubuntu Server virtual machine, `jane-sv`, in Oracle VirtualBox using SSH from Windows PowerShell. The results below describe my recorded session. I kept access to an existing SSH session while working with firewall and SSH settings.

## 3. Security Fundamentals

A firewall filters network traffic according to rules. Incoming traffic enters the system, while outgoing traffic leaves it. A default policy applies when traffic is not covered by a more specific rule. UFW provides a simpler way to manage Linux host firewall rules.

My basic lab policy allowed incoming SSH and HTTP traffic, denied other incoming traffic by default, and allowed outgoing traffic. This was one part of a broader approach that also includes access controls, secure authentication, updates, logs, and backups.

## 4. Commands Practiced

| Command | Purpose |
|---|---|
| `ufw` | Inspect and manage firewall policies and rules. |
| `systemctl`, `ss` | Inspect service states and listening sockets. |
| `sshd -t`, `sshd -T` | Check SSH configuration and inspect effective settings. |
| `journalctl`, `getent`, `w` | Investigate logs, privileged group membership, and sessions. |
| `apt update`, `apt list --upgradable`, `apt -s upgrade` | Refresh package metadata, inspect available upgrades, and simulate an upgrade. |
| `curl` | Test the local web application. |

## 5. Practical Exercises

### Initial Security Assessment

I checked UFW, listening sockets, service states, and application profiles. My initial firewall status was:

```output
Status: inactive
```

The package listing showed UFW installed. Both SSH and Nginx were active. I inspected the OpenSSH and Nginx HTTP UFW profiles, which identified TCP ports 22 and 80 respectively.

### UFW Firewall Configuration

I allowed the guest's SSH and HTTP ports before enabling the firewall, set the default policies, enabled low-level logging, and reviewed the added rules:

```bash
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw logging low
sudo ufw show added
```

After I enabled UFW, `sudo ufw status verbose` returned:

```output
Status: active
Logging: on (low)
Default: deny (incoming), allow (outgoing), disabled (routed)
New profiles: skip

To                         Action      From
--                         ------      ----
22/tcp                     ALLOW IN    Anywhere
80/tcp                     ALLOW IN    Anywhere
22/tcp (v6)                ALLOW IN    Anywhere (v6)
80/tcp (v6)                ALLOW IN    Anywhere (v6)
```

These rules allow the specified ports from any source for IPv4 and IPv6 under the displayed policy. My recorded PowerShell sessions show successful SSH logins during the exercise.

### Firewall Rule Management

I added a temporary TCP port 8080 rule and verified that it appeared for IPv4 and IPv6. I then removed it:

```bash
sudo ufw delete allow 8080/tcp
```

```output
Rule deleted
Rule deleted (v6)
```

The subsequent numbered status listed the port 22 and 80 rules without the temporary 8080 rule.

### SSH Security Hardening

I inspected the SSH configuration directory and used `sshd -t` and `sshd -T` to investigate SSH settings. At one point, the effective-settings query returned:

```output
maxauthtries 3
permitrootlogin no
pubkeyauthentication yes
passwordauthentication no
kbdinteractiveauthentication no
```

These settings describe the configuration reported at that point in the session. I then reloaded SSH, removed `/etc/ssh/sshd_config.d/00-lab-hardening.conf`, and ran `sudo sshd -t && sudo systemctl reload ssh`. Removing the file was a rollback of that dedicated configuration; the displayed settings above should be read as a point-in-time result, not as a statement of the final settings.

Public-key authentication allows the client to prove possession of a private key without sending the private key to the server. I kept private keys and passphrases out of this documentation.

### Security Auditing and Verification

I checked the kernel journal for UFW events, inspected the sudo group and active sessions, refreshed package metadata, listed upgrade candidates, and simulated an upgrade. The package update reported:

```output
47 packages can be upgraded. Run 'apt list --upgradable' to see them.
```

I used `apt -s upgrade` for a simulation. A simulation previews proposed changes; it does not install the upgrades.

At the final recorded check, UFW was active with the port 22 and 80 rules, and `systemctl is-active ssh nginx` returned:

```output
active
active
```

I also checked listening sockets and tested my Nginx page locally. The HTTP response began:

```output
HTTP/1.1 200 OK
Server: nginx/1.24.0 (Ubuntu)
```

The local HTTP request verified an application response from the server itself.

## 6. Verification Results

| Exercise | Recorded result |
|---|---|
| Initial assessment | UFW was installed but inactive; SSH and Nginx were active. |
| Firewall | UFW reported active with default deny incoming, allow outgoing, and TCP 22 and 80 allow rules. |
| Rule management | Added and removed the temporary TCP 8080 rule for IPv4 and IPv6. |
| SSH settings | Observed the proposed effective settings, reloaded SSH, and subsequently removed the dedicated hardening file and reloaded after a syntax check. |
| Audit | Inspected sessions, sudo membership, firewall events, available updates, service states, sockets, and a local HTTP response. |

## 7. What I Learned

I learned to allow an SSH connection before enabling a firewall, inspect active rules and defaults, and remove a temporary rule after testing. I also practiced reviewing SSH configuration, separating a simulated upgrade from an installed upgrade, and checking both service status and application response.

## 8. References

- Local manual pages: `man ufw`, `man sshd`, `man sshd_config`, `man systemctl`, `man journalctl`, and `man apt`.
- My exercise specification and recorded terminal output.
