# Ubuntu Server Service Management

## 1. Objective

My objective was to install and manage Nginx, deploy a simple web page, validate its configuration, and practice investigating and recovering a stopped service.

## 2. Lab Environment

I worked on my Ubuntu Server virtual machine, `jane-sv`, in Oracle VirtualBox using my existing SSH connection. I tested the website locally from the server. The service states, package version, and results below describe my recorded session.

Nginx can serve web pages and also act as a reverse proxy or load balancer. In this exercise, I used it to serve a static page.

## 3. Commands Practiced

| Command | Purpose |
|---|---|
| `dpkg -l`, `apt update`, `apt install` | Inspect, refresh package information, and install software. |
| `systemctl` | Inspect, stop, start, restart, reload, and enable the service. |
| `ss` | Inspect listening network sockets. |
| `curl` | Request a web page or its HTTP headers. |
| `nginx -t` | Test the Nginx configuration. |
| `journalctl`, `tail` | Inspect service and application logs. |

## 4. Practical Exercises

### Nginx Installation

I checked the package and port 80 before installation. `dpkg -l nginx` reported that no package matched, and the socket check displayed no listening entry for port 80. I refreshed package information with `sudo apt update`, reviewed the proposed changes, and installed Nginx with `sudo apt install nginx`.

The installation added `nginx` and `nginx-common`. My version check returned:

```bash
nginx -v
```

```output
nginx version: nginx/1.24.0 (Ubuntu)
```

The package check showed Nginx installed. The service status reported `active (running)`, and `systemctl is-enabled nginx` returned `enabled`.

### Service Lifecycle Management

I stopped and started Nginx, checking its runtime state after each operation:

```bash
sudo systemctl stop nginx
systemctl is-active nginx
```

```output
inactive
```

```bash
sudo systemctl start nginx
systemctl is-active nginx
```

```output
active
```

I also restarted and enabled the service. `active` describes its current state; `enabled` describes its startup configuration. My `ss` output showed Nginx listening on port 80 on IPv4 and IPv6. A local socket or HTTP response does not by itself establish accessibility from outside the server.

I requested the default page's headers with `curl -I http://localhost`. The response began:

```output
HTTP/1.1 200 OK
Server: nginx/1.24.0 (Ubuntu)
```

### Static Website Deployment

I inspected `/etc/nginx/` and `/var/www/html/`, then created a separate page at `/var/www/html/server-lab.html`. The existing default page remained in place. My local request returned:

```bash
curl http://localhost/server-lab.html
```

```output
<!DOCTYPE html>
<html>
<head>
    <title>Linux Administration Lab</title>
</head>
<body>
    <h1>Ubuntu Server Infrastructure Lab</h1>
    <p>Hostname: jane-sv</p>
    <p>Web Server: Nginx</p>
    <p>Deployment Status: Operational</p>
</body>
</html>
```

The header request also returned `HTTP/1.1 200 OK`. This demonstrates that Nginx served the page locally during the session.

### Configuration Validation

I inspected `/etc/nginx/nginx.conf`, the default site configuration, and the enabled-site link. The default site used `/var/www/html` as its document root. I tested the configuration before reloading:

```bash
sudo nginx -t
```

```output
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
```

I ran `sudo systemctl reload nginx`, confirmed it was active, and received HTTP 200 from the test page again. Validating configuration before reloading helps catch configuration errors before applying them.

### Service Failure and Recovery

To practice troubleshooting, I intentionally stopped Nginx and requested the test page. The request returned:

```output
curl: (7) Failed to connect to localhost port 80 after 2 ms: Couldn't connect to server
```

`systemctl status nginx` showed `inactive (dead)`, and the port 80 socket check displayed no listener. I reviewed the service journal, started Nginx again, and checked the result:

```bash
systemctl is-active nginx
curl -I http://localhost/server-lab.html
```

```output
active
```

```output
HTTP/1.1 200 OK
Server: nginx/1.24.0 (Ubuntu)
Date: Thu, 26 Nov 2026 16:35:22 GMT
Content-Type: text/html
Content-Length: 251
Last-Modified: Thu, 26 Nov 2026 16:29:16 GMT
Connection: keep-alive
ETag: "6b085e5c-fb"
Accept-Ranges: bytes
```

This showed that the local service and page responded again after recovery.

### Application Log Investigation

I inspected `/var/log/nginx/access.log` and `/var/log/nginx/error.log`. The error log displayed a notice about inherited sockets. I then requested a page that did not exist:

```bash
curl -I http://localhost/nonexistent-lab-page.html
```

```output
HTTP/1.1 404 Not Found
Server: nginx/1.24.0 (Ubuntu)
Date: Thu, 26 Nov 2026 16:36:25 GMT
Content-Type: text/html
Content-Length: 162
Connection: keep-alive
```

The access log recorded the request:

```output
::1 - - [26/Nov/2026:16:36:25 +0000] "HEAD /nonexistent-lab-page.html HTTP/1.1" 404 0 "-" "curl/8.5.0"
```

A connection failure means my client could not establish the connection. An HTTP 404 means the web server responded but the requested resource was not found.

## 5. Verification Results

| Exercise | Recorded result |
|---|---|
| Installation | Nginx 1.24.0 was installed, and its service was active and enabled. |
| Lifecycle | I stopped, started, restarted, enabled, and reloaded Nginx. |
| Static page | The local GET returned the page content, and the header request returned HTTP 200. |
| Configuration | `nginx -t` reported that the syntax and configuration test were successful. |
| Recovery | The stopped service did not accept the local connection; after starting it, the page returned HTTP 200. |
| Logs | I inspected service and application logs and observed the intentionally requested HTTP 404 in the access log. |

## 6. Troubleshooting Approach

When investigating an unavailable web service, I can check its service state, listening port, configuration, system journal, application logs, and HTTP response. After addressing the cause, I should repeat the relevant checks to verify recovery.

## 7. What I Learned

I learned to install and manage an application service, serve a separate static page, and validate Nginx configuration before reloading. I also practiced linking service status, listening sockets, HTTP responses, and logs when investigating a deliberately stopped service.

## 8. References

- Local documentation: `man nginx`, `man systemctl`, `man journalctl`, `man ss`, and `man curl`.
- My exercise specification and recorded terminal output.
