#!/bin/bash

set -e

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
OUT_DIR="${ROOT_DIR}/osboot"

BZIMAGE="${OUT_DIR}/bzImage"
SINGLE="${OUT_DIR}/single.gz"
MULTI="${OUT_DIR}/multi.gz"
ISO="${OUT_DIR}/farewell.iso"

NET="-netdev user,id=net0 -device e1000,netdev=net0"

check_file() {
  if [ ! -f "$1" ]; then
    echo "[!] File tidak ditemukan: $1"
    exit 1
  fi
}

case "$1" in
--single)
  check_file "$BZIMAGE"
  check_file "$SINGLE"

  qemu-system-x86_64 \
    -m 512M \
    -cpu max \
    -kernel "$BZIMAGE" \
    -initrd "$SINGLE" \
    -append "console=tty0 rdinit=/init loglevel=7" \
    -display gtk \
    $NET
  ;;

--multi)
  check_file "$BZIMAGE"
  check_file "$MULTI"

  qemu-system-x86_64 \
    -m 512M \
    -cpu max \
    -kernel "$BZIMAGE" \
    -initrd "$MULTI" \
    -append "console=tty0 rdinit=/init loglevel=7" \
    -display gtk \
    $NET
  ;;

--all)
  check_file "$ISO"

  qemu-system-x86_64 \
    -m 512M \
    -cpu max \
    -cdrom "$ISO" \
    -boot d \
    -display gtk \
    $NET
  ;;

*)
  echo "Usage:"
  echo "  ./qemu.sh --single"
  echo "  ./qemu.sh --multi"
  echo "  ./qemu.sh --all"
  exit 1
  ;;
esac
