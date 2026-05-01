# OBS WebSocket Tunnel (Cloudflare + Lua)

A lightweight Lua script that lets you control your local OBS instance from **anywhere on the internet**, even outside your local network.

It works by exposing your OBS WebSocket server through a secure tunnel (e.g., Cloudflare Tunnel), so you can remotely manage OBS without opening ports or dealing with complex network configuration.

> ✅ Control OBS from another city, device, or network
> ✅ No port forwarding required
> ✅ Works behind NAT / firewalls

---

## ✨ Features

* 🌐 Expose local OBS WebSocket securely
* 🌍 Control OBS from anywhere (not just your LAN)
* 🔌 Works with tunneling solutions (Cloudflare Tunnel recommended)
* ⚡ Minimal setup (Lua script)
* 🔒 Avoids direct port forwarding
* 🧩 Compatible with OBS WebSocket API

---

## 📦 Project Structure

* `cloudflare_tunnel.lua` → Main script to connect OBS to your tunnel endpoint

---

## 🚀 How It Works

1. OBS runs locally with the WebSocket plugin enabled.
2. A tunnel (e.g., Cloudflare Tunnel) exposes your local OBS WebSocket to a public URL.
3. The Lua script helps bridge/configure the connection.
4. You can connect to OBS from **anywhere in the world** using that public endpoint.

This means you are no longer limited to controlling OBS from within your local network.

---

## ⚙️ Requirements

* OBS Studio
* OBS WebSocket plugin enabled
* Lua scripting enabled in OBS
* A running tunnel (e.g., Cloudflare Tunnel)

---

## 🧑‍💻 Setup

### 1. Enable OBS WebSocket

* Open OBS
* Go to `Tools → WebSocket Server Settings`
* Enable the server (default port: `4455`)

---

### 2. Create a Tunnel

You can use Cloudflare Tunnel or any similar solution.

👉 If you want to use a **custom domain**, follow this guide:

➡️ https://github.com/oKidd/obs-ws-tunnel/blob/main/custom-domain-tunnel.md

---

### 3. Load the Script in OBS

* Go to `Tools → Scripts`
* Add `cloudflare_tunnel.lua`
* Configure parameters if needed

---

### 4. Connect Remotely

Use your public tunnel URL to connect to OBS WebSocket:

```
obs.your-domain.com/
```

---

## 🌍 Example Use Case

Control your OBS setup from:

* Your phone using mobile data
* Another computer outside your home network
* A remote production environment

---

## 🔐 Security Notes

* Always use authentication (password/token)
* Prefer HTTPS/WSS tunnels
* Avoid exposing raw ports directly

---

## 🧠 Use Cases

* Remote streaming control
* Cloud-based automation
* Multi-device OBS management
* Remote production setups

---

## ⚠️ Disclaimer

This project is intended for development and controlled environments.
Ensure proper security practices before exposing any service publicly.

---

## 📄 License

MIT (or same as repository)

---

## 🤝 Contributing

PRs and suggestions are welcome!
