# Ubuntu Server SSH and Remote Access

## 1. Objective

My objective was to investigate the SSH service, inspect its configuration, practice key-based authentication, and review remote-access and file-transfer evidence.

## 2. Lab Environment

I worked with an Ubuntu Server 24.04.5 LTS virtual machine, `jane-sv`, in Oracle VirtualBox. I connected from Windows PowerShell as `jane` using host-side port `2222`; the SSH server listened on port `22` inside the guest. The configuration and results below describe my recorded session.

## 3. SSH Architecture

SSH provides encrypted communication between an SSH client and server. My Windows `ssh` client connected to the server's `sshd` service to start a remote shell. Public-key authentication uses a key pair: the client proves possession of the private key, and the server checks an authorized public key. The private key stays on the client and must remain confidential.

`scp` transfers files over SSH. The SSH client uses lowercase `-p` for the port; `scp` uses uppercase `-P`.

## 4. Commands Practiced

| Command | Purpose |
|---|---|
| `systemctl`, `ss`, `dpkg -l` | Inspect the SSH service, listening sockets, and packages. |
| `sshd -T`, `sshd -t` | Inspect effective server settings and check configuration syntax. |
| `ssh-keygen` | Generate an SSH key pair. |
| `ssh` | Connect to the server. |
| `mkdir`, `chmod`, `ls` | Prepare and inspect the server-side SSH directory and authorized keys file. |
| `journalctl`, `grep`, `w` | Investigate authentication records and sessions. |

I studied `scp` for secure file transfer.

## 5. Practical Exercises

### SSH Service Investigation

I inspected the SSH service, its startup state, listening sockets, installed packages, and `/etc/ssh/`. `systemctl status ssh --no-pager` reported `active (running)`, and `systemctl is-enabled ssh` returned:

```output
enabled
```

My socket check showed listeners on IPv4 and IPv6 port `22`. My corrected package check showed both `openssh-client` and `openssh-server` installed. `/etc/ssh/sshd_config` controls the server; `/etc/ssh/ssh_config` configures the system-wide client. A user's `authorized_keys` file lists public keys that can be used for authentication.

### SSH Configuration Investigation

I inspected selected effective settings using `sudo sshd -T`:

```output
port 22
maxauthtries 6
permitrootlogin without-password
pubkeyauthentication yes
passwordauthentication yes
authorizedkeysfile .ssh/authorized_keys .ssh/authorized_keys2
```

The output shows that public-key and password authentication were enabled. `permitrootlogin without-password` restricts root password login; it is not the same as disabling every possible root login method. These are observed settings, not changes I made in this exercise.

I ran `sudo sshd -t` and saw no output.

### SSH Key-Based Authentication

I first mistakenly ran the PowerShell key-generation command in the remote Bash session. After removing the accidentally created pair, I generated a dedicated Ed25519 pair in Windows PowerShell:

```powershell
ssh-keygen -t ed25519 -C "ubuntu-server-lab" -f "$env:USERPROFILE\.ssh\ubuntu_server_lab"
```

The Windows output identified separate private and public key files. I displayed the public key and edited the server's `~/.ssh/authorized_keys`. My recorded permission checks were:

```output
drwx------ 2 jane jane 4096 Nov 26 15:09 /home/jean/.ssh
-rw------- 1 jane jane 100 Nov 26 15:09 /home/jean/.ssh/authorized_keys
```

The directory had mode `700` and the authorized keys file had mode `600`. The output used `/home/jean` for the home path even though the account was `jane`; I have not assumed why. The private key, public key contents, and fingerprint are omitted from this documentation.

From a second PowerShell window, I connected using the dedicated key:

```powershell
ssh -i "$env:USERPROFILE\.ssh\ubuntu_server_lab" -p 2222 jane@127.0.0.1
```

The client prompted for the key's passphrase and displayed the Ubuntu login banner. The SSH journal recorded an accepted Ed25519 public-key login with a fingerprint matching the Windows key. An explicit test with password fallback disabled remains unverified.

### Secure File Transfer Using SCP

I inspected a test file on the server:

```bash
ls -l ~/ssh-lab.txt
cat ~/ssh-lab.txt
```

```output
-rw-rw-r-- 1 jane jane 35 Nov 26 15:19 /home/jean/ssh-lab.txt
```

```output
Secure file transfer verigication
```

### SSH Authentication Log Investigation

I inspected `journalctl -u ssh`, searched `/var/log/auth.log` for accepted public-key and password logins, checked sessions with `w`, and displayed `SSH_CONNECTION`. The log contained actual `Accepted publickey` entries as well as an earlier `Accepted password` entry. It also recorded the sudo commands used to search the log; those search-command entries are not themselves authentication events.

Key fingerprints and detailed session records are omitted from this public summary.

## 6. Verification Results

| Exercise | Result |
|---|---|
| SSH service | Reported active and enabled; port 22 had IPv4 and IPv6 listeners. |
| Server configuration | Selected effective settings were displayed; `sshd -t` produced no output, but its exit status remains unverified. |
| Key-based login | Windows key generation, login banner, and a matching accepted public-key journal entry support a successful login. |
| Explicit key-only test | A test using `IdentitiesOnly` and `PreferredAuthentications` remains unverified. |
| File transfer | The server-side file and content were present; `scp` upload and download remain unverified. |
| Authentication logs | Both public-key and password login events were observed. |

## 7. Errors and Troubleshooting

### Incorrect SSH Key Generation Environment

I accidentally ran a PowerShell command in the remote Ubuntu Bash session. Bash interpreted the PowerShell environment variable syntax differently and created a key pair with an unintended filename on the server. I issued an interactive removal command and generated a new key in Windows PowerShell. I did not verify that the server files were removed.

I learned to check whether I am in the local client shell or the remote server shell before using platform-specific commands. I should never place a private key, password, or passphrase in the repository.

### Other Observations

- I misspelled `openssh-client` as `oepnssh-client` in my first package query. The corrected query showed both client and server packages.
- The test file contained `verigication`, rather than the exercise's `verification`. This is the actual recorded content.

## 8. What I Learned

I learned to distinguish SSH client and server settings, inspect authentication options, and verify a key login using both client and server evidence. I also learned that a file's presence on the server does not by itself prove how it was transferred, and that client and remote shell syntax can differ.

## 9. References

- Local manual pages: `man ssh`, `man sshd`, `man sshd_config`, `man ssh-keygen`, and `man scp`.
