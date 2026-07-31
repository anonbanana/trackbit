# TrackBit Self-Hosting Guide

Run TrackBit on your own server with Docker. Your data stays on your infrastructure — no subscriptions, no vendor lock-in.

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/) installed (v20.10+)
- [Docker Compose](https://docs.docker.com/compose/install/) (v2.0+) — usually included with Docker Desktop

## Quick Start

```bash
# 1. Clone the repository
git clone https://github.com/anonbanana/trackbit.git
cd trackbit

# 2. Start TrackBit
docker compose up -d

# 3. Open in browser
open http://localhost:8080
```

**Default credentials:**
- Username: `admin`
- Password: `admin123`

> Change the default password immediately after first login.

## Using Pre-Built Image

If you don't want to build from source, pull the pre-built image from GitHub Container Registry:

```bash
docker pull ghcr.io/anonbanana/trackbit:latest
docker run -d -p 8080:80 --name trackbit ghcr.io/anonbanana/trackbit:latest
```

## Configuration

### Change Port

Edit `docker-compose.yml`:

```yaml
services:
  trackbit:
    ports:
      - "3000:80"  # Change 8080 to your preferred port
```

### Custom Domain with Nginx Reverse Proxy

For production, put TrackBit behind Nginx with SSL:

```nginx
server {
    listen 80;
    server_name trackbit.yourdomain.com;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name trackbit.yourdomain.com;

    ssl_certificate /etc/letsencrypt/live/trackbit.yourdomain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/trackbit.yourdomain.com/privkey.pem;

    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

### SSL with Let's Encrypt

```bash
# Install Certbot
sudo apt install certbot python3-certbot-nginx -y

# Get SSL certificate
sudo certbot --nginx -d trackbit.yourdomain.com

# Auto-renewal is configured automatically
sudo certbot renew --dry-run
```

## Updating TrackBit

```bash
# Pull latest changes
git pull

# Rebuild and restart
docker compose up -d --build
```

If using the pre-built image:

```bash
docker pull ghcr.io/anonbanana/trackbit:latest
docker stop trackbit
docker rm trackbit
docker run -d -p 8080:80 --name trackbit ghcr.io/anonbanana/trackbit:latest
```

## Stopping TrackBit

```bash
docker compose down
```

## Data Persistence

TrackBit uses SQLite with IndexedDB (via Drift/WebDatabase) in the browser. Data is stored in the browser's IndexedDB on each client device.

For peer-to-peer sync between devices, use TrackBit's built-in sync feature (Settings > Sync).

## Troubleshooting

### Container won't start

```bash
# Check logs
docker compose logs trackbit

# Check if port 8080 is in use
lsof -i :8080
```

### Rebuild from scratch

```bash
docker compose down
docker compose build --no-cache
docker compose up -d
```

### Health check

```bash
curl http://localhost:8080
# Should return HTML content
```

## Architecture

```
┌─────────────────────────────────────┐
│           Docker Container          │
│  ┌─────────────┐  ┌─────────────┐  │
│  │   Nginx     │  │  Flutter    │  │
│  │  (port 80)  │──│  Web App    │  │
│  │             │  │  (static)   │  │
│  └─────────────┘  └─────────────┘  │
└─────────────────────────────────────┘
```

- **Nginx**: Serves static files, handles SPA routing, gzip compression
- **Flutter Web App**: Compiled Dart application (HTML/JS/WASM)
- **No backend server**: All data stored in browser IndexedDB (offline-first)
- **P2P Sync**: Devices sync directly over LAN (no central server needed)

## Support

- [GitHub Issues](https://github.com/anonbanana/trackbit/issues)
- [GitHub Discussions](https://github.com/anonbanana/trackbit/discussions)
