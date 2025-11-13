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

find_server_jar() {
  find "${NECESSE_DIR}" -type f \
    \( -iname 'necesse.jar' -o -iname 'necesse*.jar' -o -iname 'server.jar' \) \
    | head -n 1
}

SERVER_JAR="$(find_server_jar)"

if [[ -z "${SERVER_JAR}" ]]; then
  # Some Steam releases bundle the dedicated server inside zip archives. Extract
  # any archives we just received so the Java entrypoint can discover the jar.
  shopt -s nullglob globstar
  for archive in "${NECESSE_DIR}"/**/*.zip; do
    unzip -o "$archive" -d "$(dirname "$archive")"
  done
  shopt -u globstar
  shopt -u nullglob

  SERVER_JAR="$(find_server_jar)"
fi

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
