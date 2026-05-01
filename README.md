# OBS WebSocket Tunnel (Cloudflare + Lua)

A lightweight Lua script designed to expose your local OBS WebSocket server to the internet using a tunnel (e.g., Cloudflare Tunnel).

This allows remote control of OBS without opening ports or exposing your local network directly.

## ✨ Features

- 🌐 Expose local OBS WebSocket securely
- 🔌 Works with tunneling solutions (Cloudflare Tunnel recommended)
- ⚡ Minimal setup (Lua script)
- 🔒 Avoids direct port forwarding
- 🧩 Compatible with OBS WebSocket API

OBS WebSocket enables remote control of OBS via a WebSocket server (default port `4455`) :contentReference[oaicite:0]{index=0}

---

## 📦 Project Structure

- `cloudflare_tunnel.lua` → Main script to connect OBS to your tunnel endpoint

---

## 🚀 How It Works

1. OBS runs locally with the WebSocket plugin enabled.
2. A tunnel (like Cloudflare Tunnel) exposes your local port to a public URL.
3. This script connects OBS to that tunnel endpoint.
4. Remote clients can control OBS through the public tunnel URL.

Tunneling works by forwarding local traffic through an external server over protocols like WebSocket or HTTP, allowing access behind firewalls or NAT :contentReference[oaicite:1]{index=1}

---

## ⚙️ Requirements

- OBS Studio
- OBS WebSocket plugin enabled
- Lua scripting enabled in OBS
- A running tunnel (e.g., Cloudflare Tunnel)

---

## 🧑‍💻 Setup

### 1. Enable OBS WebSocket

- Open OBS
- Go to `Tools → WebSocket Server Settings`
- Enable the server (default port: `4455`)

---

### 2. Create a Tunnel

You can use Cloudflare Tunnel or any similar solution.

👉 If you want to use a **custom domain**, follow this guide:

➡️ https://github.com/oKidd/obs-ws-tunnel/blob/main/custom-domain-tunnel.md

---

### 3. Load the Script in OBS

- Go to `Tools → Scripts`
- Add `cloudflare_tunnel.lua`
- Configure parameters if needed

---

### 4. Connect Remotely

Use your public tunnel URL to connect to OBS WebSocket:
