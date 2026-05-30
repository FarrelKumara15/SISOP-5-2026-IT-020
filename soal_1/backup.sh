#!/bin/bash

set -e

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
OUT_DIR="${ROOT_DIR}/osboot"

TIMESTAMP="$(date +%d%m%Y-%H%M%S)"
BACKUP_NAME="farewell_backup_${TIMESTAMP}.zip"
BACKUP_PATH="${OUT_DIR}/${BACKUP_NAME}"

cd "$OUT_DIR"

for file in bzImage single.gz multi.gz farewell.iso; do
  if [ ! -f "$file" ]; then
    echo "[!] File tidak ditemukan: osboot/$file"
    exit 1
  fi
done

zip -r "$BACKUP_PATH" bzImage single.gz multi.gz farewell.iso

echo "[✓] Backup selesai."
echo "[✓] Output: osboot/${BACKUP_NAME}"
