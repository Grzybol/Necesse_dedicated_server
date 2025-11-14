# Necesse Dedicated Server in Docker

This repository contains a minimal, production-ready Docker setup for hosting the Necesse dedicated server (Steam AppID **1169370**) on any Debian/Ubuntu VPS. It ships with a Debian slim base image, SteamCMD auto-updates on every boot, persistent data volumes, and optional NGINX stream forwarding for hostname-based UDP routing.

## Repository layout
```
.
├─ docker/
│  ├─ Dockerfile
│  └─ entrypoint.sh
├─ docker-compose.yml
├─ .env.example
├─ nginx/
│  └─ necesse-stream.conf
└─ data/              # created locally, mounted into the container
```

## Prerequisites
- Debian/Ubuntu VPS with Docker Engine and Docker Compose v2 installed.
- Firewall rule opening the UDP port you intend to expose (default `14159`). Example:
  ```bash
  sudo ufw allow 14159/udp
  ```

## Initial setup
1. Clone this repository on your VPS.
2. Copy the environment template and adjust it to your needs:
   ```bash
   cp .env.example .env
   nano .env  # edit WORLD_NAME, PORT, SLOTS, PASSWORD, PAUSE
   ```
3. Build the image:
   ```bash
   docker compose build
   ```
4. Start the server in the background:
   ```bash
   docker compose up -d
   ```
5. Tail the logs if you want to watch the first start:
   ```bash
   docker compose logs -f
   ```

On every container start, SteamCMD automatically pulls the newest Necesse server build before Java launches the dedicated server headless (`-nogui`).

## Connecting from the game client
- Point the Necesse client to your server hostname/IP and UDP port, e.g., `bestservers.com:14159`.
- Many clients require explicitly typing the port; hostname DNS (A record) must point to your VPS.

## Changing ports
- Update `PORT` inside `.env` to change the in-container port the server listens on.
- Edit the `ports` section in `docker-compose.yml` to change the external mapping, e.g.:
  ```yaml
  ports:
    - "24159:14159/udp"
  ```
  Clients would then connect to `bestservers.com:24159`.
- Adjust your firewall (`ufw`, cloud provider rules, etc.) for the new external port.

## Updates
- The container runs SteamCMD on every boot, so regular restarts pick up new server builds.
- To force an update:
  ```bash
  docker compose build      # or `docker compose pull` if you host the image elsewhere
  docker compose restart
  ```

## Persistence and backups
- All worlds, configs, and logs live inside `./data`, which is bind-mounted to `/data` in the container.
- Back up the server by compressing that directory:
  ```bash
  tar -czf necesse-backup.tgz data/
  ```

## Optional: NGINX UDP stream proxy
If you want to forward UDP traffic by hostname/port without exposing the Docker port directly, use the provided stream configuration:
1. Copy `nginx/necesse-stream.conf` to your server (e.g., `/etc/nginx/streams-available/`).
2. Ensure `nginx.conf` includes your stream directory, such as:
   ```
   include /etc/nginx/streams-enabled/*.conf;
   ```
3. Symlink the file into that directory, test, and reload:
   ```bash
   sudo ln -s /etc/nginx/streams-available/necesse-stream.conf /etc/nginx/streams-enabled/
   sudo nginx -t
   sudo systemctl reload nginx
   ```
4. Clients still connect via hostname + UDP port (no HTTP, no paths), e.g., `bestservers.com:14159`.

## Autostart after VPS reboot
`restart: unless-stopped` in `docker-compose.yml` ensures Docker restarts the container after the Docker daemon starts. Make sure Docker itself is enabled:
```bash
sudo systemctl enable docker
```

## Troubleshooting
- **Port closed?** Check hosting provider firewalls, `ufw`, and `iptables` rules. Confirm the compose file maps the correct UDP port.
- **Hostname not resolving?** Verify the DNS A record for your domain points to the VPS IP.
- **SteamCMD download errors?** The container logs will show SteamCMD output. Retry with `docker compose restart`.

Enjoy your Necesse world! All saves stay under `./data`, so you can move the folder or rsync it to another host whenever needed.
