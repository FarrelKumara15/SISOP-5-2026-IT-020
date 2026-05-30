#!/bin/bash

set -e

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
OUT_DIR="${ROOT_DIR}/osboot"
ISO_DIR="${ROOT_DIR}/build/iso_root"

BZIMAGE="${OUT_DIR}/bzImage"
SINGLE="${OUT_DIR}/single.gz"
MULTI="${OUT_DIR}/multi.gz"
ISO="${OUT_DIR}/farewell.iso"

echo "[+] Mengecek file yang dibutuhkan..."

if [ ! -f "$BZIMAGE" ]; then
  echo "[!] osboot/bzImage tidak ditemukan. Jalankan ./kernel.sh dulu."
  exit 1
fi

if [ ! -f "$SINGLE" ]; then
  echo "[!] osboot/single.gz tidak ditemukan. Jalankan ./single.sh dulu."
  exit 1
fi

if [ ! -f "$MULTI" ]; then
  echo "[!] osboot/multi.gz tidak ditemukan. Jalankan ./multi.sh dulu."
  exit 1
fi

echo "[+] Membuat struktur ISO..."
rm -rf "$ISO_DIR"
mkdir -p "$ISO_DIR/boot/grub"

cp "$BZIMAGE" "$ISO_DIR/boot/bzImage"
cp "$SINGLE" "$ISO_DIR/boot/single.gz"
cp "$MULTI" "$ISO_DIR/boot/multi.gz"

echo "[+] Membuat grub.cfg..."

cat >"$ISO_DIR/boot/grub/grub.cfg" <<'EOF'
set timeout=15
set default=0

menuentry "Farewell Party - Single User Filesystem" {
    linux /boot/bzImage console=tty0 rdinit=/init loglevel=7
    initrd /boot/single.gz
}

menuentry "Farewell Party - Multi User Filesystem" {
    linux /boot/bzImage console=tty0 rdinit=/init loglevel=7
    initrd /boot/multi.gz
}
EOF

echo "[+] Membuat ISO bootable..."
grub-mkrescue -o "$ISO" "$ISO_DIR"

echo "[✓] Selesai."
echo "[✓] Output: osboot/farewell.iso"
