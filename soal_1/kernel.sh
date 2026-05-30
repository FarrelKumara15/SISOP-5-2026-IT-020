#!/bin/bash

set -e

KERNEL_VERSION="6.1.1"
KERNEL_TAR="linux-${KERNEL_VERSION}.tar.xz"
KERNEL_DIR="linux-${KERNEL_VERSION}"
KERNEL_URL="https://cdn.kernel.org/pub/linux/kernel/v6.x/${KERNEL_TAR}"

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
OUT_DIR="${ROOT_DIR}/osboot"

CC_CMD="gcc -std=gnu11"
HOSTCC_CMD="gcc -std=gnu11"

echo "[+] Membuat folder osboot..."
mkdir -p "$OUT_DIR"

cd "$ROOT_DIR"

echo "[+] Download Linux kernel ${KERNEL_VERSION}..."
if [ ! -f "$KERNEL_TAR" ]; then
  wget -c "$KERNEL_URL" -O "$KERNEL_TAR"
else
  echo "[=] ${KERNEL_TAR} sudah ada, skip download."
fi

echo "[+] Extract kernel..."
if [ ! -d "$KERNEL_DIR" ]; then
  tar -xf "$KERNEL_TAR"
else
  echo "[=] Folder ${KERNEL_DIR} sudah ada, skip extract."
fi

cd "$KERNEL_DIR"

echo "[+] Membuat config kernel Linux 6.1.1..."
make CC="$CC_CMD" HOSTCC="$HOSTCC_CMD" x86_64_defconfig

echo "[+] Mengaktifkan fitur wajib soal..."

# initramfs / gzip
./scripts/config --enable BLK_DEV_INITRD
./scripts/config --enable RD_GZIP

# executable
./scripts/config --enable BINFMT_ELF
./scripts/config --enable BINFMT_SCRIPT

# pseudo filesystem
./scripts/config --enable DEVTMPFS
./scripts/config --enable DEVTMPFS_MOUNT
./scripts/config --enable TMPFS
./scripts/config --enable PROC_FS
./scripts/config --enable SYSFS

# VGA console untuk QEMU window
./scripts/config --enable TTY
./scripts/config --enable VT
./scripts/config --enable VT_CONSOLE
./scripts/config --enable HW_CONSOLE
./scripts/config --enable VGA_CONSOLE
./scripts/config --enable DUMMY_CONSOLE

# keyboard QEMU
./scripts/config --enable INPUT
./scripts/config --enable INPUT_KEYBOARD
./scripts/config --enable KEYBOARD_ATKBD
./scripts/config --enable SERIO
./scripts/config --enable SERIO_I8042

# network
./scripts/config --enable NET
./scripts/config --enable UNIX
./scripts/config --enable INET
./scripts/config --enable PACKET
./scripts/config --enable PCI
./scripts/config --enable NETDEVICES
./scripts/config --enable ETHERNET
./scripts/config --enable NET_VENDOR_INTEL
./scripts/config --enable E1000

# FUSE
./scripts/config --enable FUSE_FS

echo "[+] Mematikan fitur yang sering bikin error di GCC baru..."
./scripts/config --disable WERROR
./scripts/config --disable RUST
./scripts/config --disable MODULES
./scripts/config --disable BLK_CGROUP_IOCOST
./scripts/config --disable NET_VENDOR_BROADCOM
./scripts/config --disable TIGON3

echo "[+] Menyesuaikan config..."
make \
  CC="$CC_CMD" \
  HOSTCC="$HOSTCC_CMD" \
  RUSTC=/bin/false \
  BINDGEN=/bin/false \
  RUSTFMT=/bin/false \
  KCFLAGS="-Wno-error -Wno-array-bounds -Wno-format" \
  olddefconfig

cp .config "$ROOT_DIR/.config"

echo "[+] Cek config penting..."
grep -E 'CONFIG_BLK_DEV_INITRD|CONFIG_RD_GZIP|CONFIG_BINFMT_ELF|CONFIG_BINFMT_SCRIPT|CONFIG_VT_CONSOLE|CONFIG_VGA_CONSOLE|CONFIG_E1000|CONFIG_FUSE_FS' .config || true

echo "[+] Compile kernel bzImage..."
make -j"$(nproc)" \
  CC="$CC_CMD" \
  HOSTCC="$HOSTCC_CMD" \
  RUSTC=/bin/false \
  BINDGEN=/bin/false \
  RUSTFMT=/bin/false \
  KCFLAGS="-Wno-error -Wno-array-bounds -Wno-format" \
  bzImage

echo "[+] Copy hasil kernel ke osboot/bzImage..."
cp arch/x86/boot/bzImage "$OUT_DIR/bzImage"

echo "[✓] Selesai compile kernel."
echo "[✓] Output: osboot/bzImage"
