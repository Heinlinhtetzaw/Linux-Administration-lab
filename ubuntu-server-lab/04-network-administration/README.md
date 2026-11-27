# Ubuntu Server Network Administration

## 1. Objective

My objective was to inspect my Ubuntu Server's network interface, addressing, routes, Netplan configuration, DNS, connectivity, and active SSH connection. I studied static IP configuration without applying a network change.

## 2. Lab Environment

I worked on Ubuntu Server `jane-sv` in Oracle VirtualBox, administering it through my existing SSH connection. My lab uses VirtualBox NAT according to my environment notes. The values below are snapshots from my recorded session and may change.

## 3. Networking Fundamentals

DHCP automatically supplies network settings such as an IP address and gateway. A static IP is configured manually and stays as configured until changed. A DHCP reservation is another way to provide a predictable address without configuring it statically on the server.

Netplan describes network settings in YAML and generates configuration for a backend such as `systemd-networkd` or NetworkManager. `systemd-resolved` provides name resolution services. A route tells the system which interface and next hop to use for a destination.

## 4. Commands Practiced

| Command | Purpose |
|---|---|
| `ip`, `hostname -I` | Inspect interfaces, addresses, routes, and interface statistics. |
| `netplan get` | Inspect the effective Netplan configuration. |
| `networkctl` | Inspect network links and their management state. |
| `resolvectl`, `getent` | Inspect DNS settings and resolve names. |
| `ping`, `curl` | Test ICMP connectivity and an HTTPS response. |
| `ss`, `w`, `SSH_CONNECTION` | Inspect sockets and the current SSH session. |

## 5. Practical Exercises

### Network Interface and IP Investigation

I used `ip -br addr`, `ip link show`, `hostname -I`, and `ip route`. My main interface, `enp0s3`, was `UP` with IPv4 address `10.0.2.15/24`. I omit the link-local IPv6 and hardware addresses from this public summary; they were present in my original output.

My route output was:

```output
default via 10.0.2.2 dev enp0s3 proto dhcp src 10.0.2.15 metric 100
10.0.2.0/24 dev enp0s3 proto kernel scope link src 10.0.2.15 metric 100
10.0.2.2 dev enp0s3 proto dhcp scope link src 10.0.2.15 metric 100
192.168.8.1 via 10.0.2.2 dev enp0s3 proto dhcp src 10.0.2.15 metric 100
```

The default gateway was `10.0.2.2`. The `/24` prefix corresponds to subnet mask `255.255.255.0` and network `10.0.2.0/24`. `ip route get 8.8.8.8` selected that gateway and interface; a route lookup does not itself send a test packet.

### Netplan Configuration Investigation

I listed `/etc/netplan/`, inspected its YAML file, and ran `sudo netplan get`. Both displayed:

```output
network:
  version: 2
  ethernets:
    enp0s3:
      dhcp4: true
```

`dhcp4: true` configures automatic IPv4 addressing. `networkctl list` showed `enp0s3` as `routable` and `configured`. `networkctl status enp0s3` identified a generated networkd configuration file and showed:

```output
                     Address: 10.0.2.15 (DHCP4 via 10.0.2.2)
```

The status showed `systemd-networkd` messages for the interface. I mistakenly checked `systemd-network` rather than `systemd-networkd` with `systemctl is-active`. `networkctl` showed networkd managing the interface, but a correctly named direct service check remains unverified.

### DHCP and Static IP Configuration Concepts

I studied how a static Netplan configuration can specify `dhcp4: false`, an address and prefix, a default route, and DNS servers. My recorded configuration used DHCP; I did not apply the static example or change the server's network configuration during this exercise.

### DNS and Network Connectivity Verification

`systemctl is-active systemd-resolved` returned `active`. `/etc/resolv.conf` listed `127.0.0.53`, the local systemd resolver stub, while `resolvectl status` identified `192.168.8.1` as the current upstream DNS server for `enp0s3`. I used `resolvectl query example.com` and `getent hosts example.com`; both returned addresses.

I tested the gateway and an external IP address. These are my actual statistics:

```output
--- 10.0.2.2 ping statistics ---
4 packets transmitted, 4 received, 0% packet loss, time 4409ms
rtt min/avg/max/mdev = 1.147/1.818/3.130/0.801 ms
```

```output
--- 8.8.8.8 ping statistics ---
4 packets transmitted, 3 received, 25% packet loss, time 3079ms
rtt min/avg/max/mdev = 647.882/654.665/667.197/8.871 ms
```

The external test had one unanswered request and high response times in this short sample. It does not establish the cause or prove a persistent network problem.

I also requested HTTPS headers:

```bash
curl -I --max-time 10 https://example.com
```

The first response line was:

```output
HTTP/2 200
```

This confirms that the application returned a successful HTTP response for that request; it does not rule out intermittent connectivity problems.

### Active Network Connection Investigation

I inspected `SSH_CONNECTION`, established TCP sockets, and logged-in users. My SSH environment reported:

```output
10.0.2.2 65428 10.0.2.15 22
```

These values represent the client address and port followed by the server address and port as seen by the server. The client port is temporary. My socket check showed SSH listening on IPv4 and IPv6:

```output
LISTEN 0      4096         0.0.0.0:22        0.0.0.0:*    users:(("sshd",pid=793,fd=3),("systemd",pid=1,fd=185))
LISTEN 0      4096            [::]:22           [::]:*    users:(("sshd",pid=793,fd=4),("systemd",pid=1,fd=186))
```

The wildcard addresses indicate listening on the corresponding local address families; they do not by themselves prove that SSH is reachable from every external network. My established socket and `w` output showed the current session.

I also inspected `ip -s link show enp0s3`. Its RX and TX counters showed zero errors and zero dropped packets at the time of the check. These interface counters alone do not explain the external ping loss.

## 6. VirtualBox Networking Modes

| Mode | General purpose |
|---|---|
| NAT | Guest outbound access through NAT; inbound access generally needs port forwarding. |
| Bridged | Connect the VM as a separate endpoint on the physical network. |
| Host-only | Connect the host and VMs on a private network; no internet access by default. |
| Internal Network | Connect VMs on a private virtual network. |
| NAT Network | Connect VMs through a shared NAT network with outbound access. |

I kept my existing configuration during this exercise. Availability and reachability still depend on the host and network configuration.

## 7. Verification Results

| Exercise | Result |
|---|---|
| Interface and routing | `enp0s3` was up with `10.0.2.15/24` and gateway `10.0.2.2`. |
| Netplan and backend | DHCPv4 was configured; `networkctl` showed a configured interface and networkd messages. A correctly named direct service check was not recorded. |
| DNS | Resolver service was active and both name-resolution commands returned addresses. |
| Connectivity | Gateway ping received four replies; external ping received three of four; HTTPS returned HTTP 200. |
| SSH and counters | Recorded an established SSH session, listening sockets, and interface counters with zero displayed errors and drops. |
| Static IP | Studied the example; no static configuration was applied. |

## 8. Errors and Troubleshooting

- I typed `hsotname -I`; the shell reported the command was not found. I corrected it to `hostname -I` and received `10.0.2.15`.
- My external ping had 25% loss and approximately 655 ms average round-trip time in four attempts. DNS and the HTTPS request succeeded in the same exercise, but the cause and duration of the loss are unverified.

## 9. What I Learned

I learned to connect Netplan's DHCP setting with the interface and route actually in use, distinguish the local DNS stub from the upstream DNS server, and inspect the SSH session that I was using for administration. I also learned that an application can respond successfully even when a short ICMP test shows packet loss, so I should interpret each test in context.

## 10. References

- Local manual pages: `man ip`, `man netplan`, `man networkctl`, `man resolvectl`, and `man ss`.
