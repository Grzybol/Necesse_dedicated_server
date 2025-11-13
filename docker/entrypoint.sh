#!/usr/bin/env bash
set -euo pipefail

STEAMCMD_DIR="/opt/steamcmd"
NECESSE_DIR="/opt/necesse"
DATA_DIR="/data"

# Ensure SteamCMD is available (bind mounts on Windows may start empty)
if [[ ! -x "${STEAMCMD_DIR}/steamcmd.sh" ]]; then
  echo "SteamCMD not found in ${STEAMCMD_DIR}, bootstrapping..."
  mkdir -p "${STEAMCMD_DIR}"
  curl -sSL https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz \
    | tar -C "${STEAMCMD_DIR}" -xzvf -
fi

# Always pull the latest server build before launching
"${STEAMCMD_DIR}/steamcmd.sh" \
  +force_install_dir "${NECESSE_DIR}" \
  +login anonymous \
  +app_update 1169370 \
  +quit

SERVER_JAR="$(find "${NECESSE_DIR}" -maxdepth 5 -type f -name 'Necesse.jar' | head -n 1)"

if [[ -z "${SERVER_JAR}" ]]; then
  echo "Error: Necesse.jar not found under ${NECESSE_DIR}." >&2
  exit 1
fi

WORLD_NAME="${WORLD_NAME:-MyWorld}"
PORT="${PORT:-14159}"
SLOTS="${SLOTS:-10}"
PASSWORD="${PASSWORD:-}"
PAUSE="${PAUSE:-1}"

exec java -jar "${SERVER_JAR}" \
  -nogui \
  -datadir "${DATA_DIR}" \
  -world "${WORLD_NAME}" \
  -port "${PORT}" \
  -slots "${SLOTS}" \
  -password "${PASSWORD}" \
  -pausewhenempty "${PAUSE}"
