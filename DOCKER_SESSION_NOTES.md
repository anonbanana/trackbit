# TrackBit Docker Setup - Session Notes

## Date: July 31, 2026

## What Was Done

### 1. Created Docker Files (committed to `main` branch)
- `Dockerfile` — Multi-stage build (Flutter SDK → Nginx Alpine)
- `docker-compose.yml` — One-command deployment
- `nginx.conf` — SPA routing, gzip, cache headers, security headers
- `.dockerignore` — Excludes build/, .git/, android/, ios/, etc.
- `.github/workflows/docker.yml` — CI/CD to publish Docker images to GHCR
- `documentation/self-hosting-guide.md` — Self-hosting guide for users

### 2. Updated Landing Page (committed to `gh-pages` branch)
- Hero button: "Use Web App" → "Self-Host with Docker"
- Download card: "Open Web App" → "Setup Guide"
- Both link to `documentation/self-hosting-guide.md`

### 3. Installed Docker on WSL
- Docker version: 29.1.3
- Docker Compose version: 2.40.3
- User added to `docker` group (requires new terminal to take effect)
- WSL version: WSL2 (confirmed)

### 4. Fixed Dockerfile
- Removed `pubspec.lock` from COPY (it's gitignored, not in repo)
- Changed to: copy `pubspec.yaml` → `flutter pub get` → copy everything

## What Needs to Be Done Next Session

### Priority 1: Test Docker Build
```bash
# Start Docker service (if not running)
sudo service docker start

# Build and run TrackBit
docker compose up -d --build

# Open in browser
# http://localhost:8080
```

**Note:** First build takes 10-15 minutes (downloads Flutter SDK ~1.8GB + builds app). Subsequent builds are fast due to Docker layer caching.

### Priority 2: Verify the App Works
- Open `http://localhost:8080` in Windows browser
- Login with `admin` / `admin123`
- Check that all modules load correctly
- Test P2P sync (if multiple devices available)

### Priority 3: Fix Any Build Issues
If build fails, check:
- `docker compose logs` for error details
- Network issues (pulling Flutter image from ghcr.io)
- Disk space (Flutter SDK image is ~1.8GB)

### Priority 4: Commit Dockerfile Fix
```bash
git add Dockerfile
git commit -m "fix: remove pubspec.lock from Dockerfile COPY"
git push origin main
```

## Commands Reference

```bash
# Start Docker
sudo service docker start

# Build and run
docker compose up -d --build

# Check status
docker ps

# View logs
docker compose logs

# Stop
docker compose down

# Rebuild from scratch
docker compose down
docker compose build --no-cache
docker compose up -d

# Access the app
# http://localhost:8080

# Default credentials
# Username: admin
# Password: admin123
```

## Files Modified (Not Yet Committed)

- `Dockerfile` — Removed `pubspec.lock` from COPY instruction
