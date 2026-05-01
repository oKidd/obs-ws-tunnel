# Cloudflare Tunnel Setup for OBS WebSocket

This guide explains how to expose your local OBS WebSocket (`localhost:4455`) to the internet using Cloudflare Tunnel with a custom domain.

---

## Requirements

* A domain managed by Cloudflare
* `cloudflared` installed on your system
* OBS with WebSocket enabled (default port: 4455)

---

## 1. Authenticate with Cloudflare

```bash
cloudflared tunnel login
```

* A browser window will open
* Select your domain
* This will generate a `cert.pem` file in `~/.cloudflared`

---

## 2. Create a Tunnel

```bash
cloudflared tunnel create obs-tunnel
```

This will:

* Create a tunnel
* Generate a Tunnel ID
* Save credentials in `~/.cloudflared/<TUNNEL_ID>.json`

---

## 3. Create Configuration File

Create:

```bash
~/.cloudflared/config.yml
```

Example:

```yaml
tunnel: YOUR_TUNNEL_ID
credentials-file: /home/your-user/.cloudflared/YOUR_TUNNEL_ID.json

ingress:
  - hostname: obs.yourdomain.com
    service: http://localhost:4455
  - service: http_status:404
```

> On Windows, use:
> `C:\Users\YourUser\.cloudflared\YOUR_TUNNEL_ID.json`

---

## 4. Configure DNS in Cloudflare

In your Cloudflare dashboard:

* Go to **DNS**
* Add a record:

```
Type: CNAME
Name: obs
Target: YOUR_TUNNEL_ID.cfargotunnel.com
Proxy: ON (orange cloud)
```

---

## 5. Run the Tunnel

```bash
cloudflared tunnel run obs-tunnel
```

---

## 6. Connect to OBS Remotely

Use:

```
wss://obs.yourdomain.com
```

* Port: 443 (implicit)
* Password: your OBS WebSocket password

---

## 7. Enable OBS WebSocket

In OBS:

* Tools → WebSocket Server Settings
* Enable WebSocket server
* Set a password
* Default port: 4455

---

## Optional: Run as a Service

```bash
cloudflared service install
```

---

## Optional: Add Access Protection

In Cloudflare:

* Go to **Zero Trust → Access**
* Protect `obs.yourdomain.com` with login (Google, email, etc.)

---

## Troubleshooting

* Ensure `cloudflared` is running
* Check OBS WebSocket is enabled
* Verify DNS record is proxied (orange cloud)

Test:

```bash
https://obs.yourdomain.com
```

---

## Result

You now have a persistent endpoint:

```
wss://obs.yourdomain.com
```

for remotely controlling OBS from anywhere.
