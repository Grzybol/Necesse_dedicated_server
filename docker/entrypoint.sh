#!/usr/bin/env bash
set -euo pipefail

STEAMCMD_DIR="/opt/steamcmd"
NECESSE_DIR="/opt/necesse"
DATA_DIR="/data"

# Always pull the latest server build before launching
"${STEAMCMD_DIR}/steamcmd.sh" \
  +login anonymous \
  +force_install_dir "${NECESSE_DIR}" \
  +app_update 1169370 \
  +quit

WORLD_NAME="${WORLD_NAME:-MyWorld}"
PORT="${PORT:-14159}"
SLOTS="${SLOTS:-10}"
PASSWORD="${PASSWORD:-}"
PAUSE="${PAUSE:-1}"

exec java -jar Necesse.jar \
  -nogui \
  -datadir "${DATA_DIR}" \
  -world "${WORLD_NAME}" \
  -port "${PORT}" \
  -slots "${SLOTS}" \
  -password "${PASSWORD}" \
  -pausewhenempty "${PAUSE}"
