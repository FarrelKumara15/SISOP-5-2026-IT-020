#!/bin/bash

set -e

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
OUT_DIR="${ROOT_DIR}/osboot"
BUILD_DIR="${ROOT_DIR}/build"

BUSYBOX_VERSION="1.36.1"
BUSYBOX_TAR="busybox-${BUSYBOX_VERSION}.tar.bz2"
BUSYBOX_DIR="busybox-${BUSYBOX_VERSION}"
BUSYBOX_URL="https://busybox.net/downloads/${BUSYBOX_TAR}"

ROOTFS="${BUILD_DIR}/multi_rootfs"
OUTPUT="${OUT_DIR}/multi.gz"

mkdir -p "$OUT_DIR"
mkdir -p "$BUILD_DIR"

cd "$BUILD_DIR"

echo "[+] Download BusyBox..."
if [ ! -f "$BUSYBOX_TAR" ]; then
  wget -c "$BUSYBOX_URL" -O "$BUSYBOX_TAR"
else
  echo "[=] BusyBox archive sudah ada, skip download."
fi

echo "[+] Extract BusyBox..."
if [ ! -d "$BUSYBOX_DIR" ]; then
  tar -xf "$BUSYBOX_TAR"
else
  echo "[=] Folder BusyBox sudah ada, skip extract."
fi

cd "$BUSYBOX_DIR"

echo "[+] Konfigurasi BusyBox..."
make defconfig

bb_enable() {
  local key="$1"

  if grep -q "^# ${key} is not set" .config; then
    sed -i "s/^# ${key} is not set/${key}=y/" .config
  elif grep -q "^${key}=" .config; then
    sed -i "s/^${key}=.*/${key}=y/" .config
  else
    echo "${key}=y" >>.config
  fi
}

bb_disable() {
  local key="$1"

  if grep -q "^${key}=y" .config; then
    sed -i "s/^${key}=y/# ${key} is not set/" .config
  elif grep -q "^${key}=" .config; then
    sed -i "s/^${key}=.*/# ${key} is not set/" .config
  elif ! grep -q "^# ${key} is not set" .config; then
    echo "# ${key} is not set" >>.config
  fi
}

bb_enable CONFIG_STATIC
bb_enable CONFIG_ASH
bb_enable CONFIG_SH_IS_ASH
bb_disable CONFIG_ASH_JOB_CONTROL
bb_enable CONFIG_MOUNT
bb_enable CONFIG_UMOUNT
bb_enable CONFIG_MKNOD
bb_enable CONFIG_MKDIR
bb_enable CONFIG_CHMOD
bb_enable CONFIG_CHOWN
bb_enable CONFIG_LS
bb_enable CONFIG_CAT
bb_enable CONFIG_ECHO
bb_enable CONFIG_CLEAR
bb_enable CONFIG_WHOAMI
bb_enable CONFIG_ID
bb_enable CONFIG_SU
bb_enable CONFIG_LOGIN
bb_enable CONFIG_SETSID
bb_enable CONFIG_CTTYHACK
bb_enable CONFIG_FEATURE_SHADOWPASSWDS
bb_enable CONFIG_FEATURE_SECURETTY
bb_enable CONFIG_IFCONFIG
bb_enable CONFIG_IP
bb_enable CONFIG_UDHCPC
bb_enable CONFIG_PING
bb_enable CONFIG_WGET

bb_disable CONFIG_TC
bb_disable CONFIG_FEATURE_TC_INGRESS

if grep -q '^CONFIG_EXTRA_CFLAGS=' .config; then
  sed -i 's|^CONFIG_EXTRA_CFLAGS=.*|CONFIG_EXTRA_CFLAGS="-march=x86-64 -mtune=generic -O2"|' .config
else
  echo 'CONFIG_EXTRA_CFLAGS="-march=x86-64 -mtune=generic -O2"' >>.config
fi

yes "" | make oldconfig

echo "[+] Compile BusyBox..."
make -j"$(nproc)" CFLAGS_EXTRA="-march=x86-64 -mtune=generic -O2"

echo "[+] Install BusyBox ke rootfs..."
rm -rf "$ROOTFS"
mkdir -p "$ROOTFS"
make CONFIG_PREFIX="$ROOTFS" install

echo "[+] Membuat struktur root filesystem multi-user..."

mkdir -p "$ROOTFS/bin"
mkdir -p "$ROOTFS/sbin"
mkdir -p "$ROOTFS/dev"
mkdir -p "$ROOTFS/proc"
mkdir -p "$ROOTFS/sys"
mkdir -p "$ROOTFS/etc"
mkdir -p "$ROOTFS/tmp"
mkdir -p "$ROOTFS/root"
mkdir -p "$ROOTFS/home/henn"
mkdir -p "$ROOTFS/home/hann"
mkdir -p "$ROOTFS/home/viii"
mkdir -p "$ROOTFS/home/kids"
mkdir -p "$ROOTFS/dev/pts"

chmod 1777 "$ROOTFS/tmp"
chmod 700 "$ROOTFS/root"
chmod 755 "$ROOTFS/home"

echo "[+] Membuat user dan password..."

ROOT_HASH="$(openssl passwd -6 root123)"
HENN_HASH="$(openssl passwd -6 henn123)"
HANN_HASH="$(openssl passwd -6 hann123)"
VIII_HASH="$(openssl passwd -6 viii123)"
KIDS_HASH="$(openssl passwd -6 kids123)"

cat >"$ROOTFS/etc/passwd" <<EOF
root:x:0:0:root:/root:/bin/sh
henn:x:1001:1001:henn:/home/henn:/bin/sh
hann:x:1002:1002:hann:/home/hann:/bin/sh
viii:x:1003:1003:viii:/home/viii:/bin/sh
kids:x:1004:1004:kids:/home/kids:/bin/sh
EOF

cat >"$ROOTFS/etc/shadow" <<EOF
root:${ROOT_HASH}:19000:0:99999:7:::
henn:${HENN_HASH}:19000:0:99999:7:::
hann:${HANN_HASH}:19000:0:99999:7:::
viii:${VIII_HASH}:19000:0:99999:7:::
kids:${KIDS_HASH}:19000:0:99999:7:::
EOF

cat >"$ROOTFS/etc/group" <<EOF
root:x:0:root
henn:x:1001:henn
hann:x:1002:hann
viii:x:1003:viii
kids:x:1004:kids
grp_home_hann:x:2001:henn,hann
grp_home_viii:x:2002:henn,hann,viii
grp_home_kids:x:2003:henn,hann,viii,kids
EOF

chmod 600 "$ROOTFS/etc/shadow"

cat >"$ROOTFS/etc/securetty" <<EOF
console
tty
tty0
tty1
ttyS0
EOF

cat >"$ROOTFS/etc/resolv.conf" <<EOF
nameserver 8.8.8.8
nameserver 1.1.1.1
EOF

echo "[+] Membuat package manager party..."

cat >"$ROOTFS/bin/party" <<'EOF'
#!/bin/sh

INSTALLED_DIR="/etc/party/installed"
mkdir -p "$INSTALLED_DIR" 2>/dev/null

case "$1" in
    help|"")
        echo "Party Package Manager"
        echo
        echo "Usage:"
        echo "  party help"
        echo "  party list"
        echo "  party installed"
        echo "  party install <package>"
        echo "  party remove <package>"
        ;;
    list)
        echo "Available packages:"
        echo "  hello"
        echo "  fuse-demo"
        ;;
    installed)
        echo "Installed packages:"
        ls "$INSTALLED_DIR" 2>/dev/null || true
        ;;
    install)
        if [ -z "$2" ]; then
            echo "Usage: party install <package>"
            exit 1
        fi

        case "$2" in
            hello)
                cat > /bin/hello-party <<'HELLO'
#!/bin/sh
echo "Hello from package installed by party"
HELLO
                chmod +x /bin/hello-party
                touch "$INSTALLED_DIR/hello"
                echo "[party] Installed: hello"
                echo "Run with: hello-party"
                ;;
            fuse-demo)
                echo "FUSE demo package installed by party" > /root/fuse-demo.txt
                touch "$INSTALLED_DIR/fuse-demo"
                echo "[party] Installed: fuse-demo"
                echo "Run with: fuse_test"
                ;;
            *)
                echo "[party] Package not found: $2"
                exit 1
                ;;
        esac
        ;;
    remove)
        if [ -z "$2" ]; then
            echo "Usage: party remove <package>"
            exit 1
        fi

        rm -f "$INSTALLED_DIR/$2"

        if [ "$2" = "hello" ]; then
            rm -f /bin/hello-party
        fi

        if [ "$2" = "fuse-demo" ]; then
            rm -f /root/fuse-demo.txt
        fi

        echo "[party] Removed: $2"
        ;;
    *)
        echo "[party] Unknown command: $1"
        echo "Run: party help"
        exit 1
        ;;
esac
EOF

chmod +x "$ROOTFS/bin/party"

cat >"$ROOTFS/bin/fuse_test" <<'EOF'
#!/bin/sh

echo "[FUSE Test]"

if [ -e /dev/fuse ]; then
    echo "[OK] /dev/fuse tersedia"
else
    echo "[FAIL] /dev/fuse tidak tersedia"
    exit 1
fi

echo
echo "Mengecek dukungan FUSE:"
grep fuse /proc/filesystems 2>/dev/null || echo "FUSE belum muncul di /proc/filesystems"

echo
echo "Install demo package:"
echo "  party install fuse-demo"
EOF

chmod +x "$ROOTFS/bin/fuse_test"

echo "[+] Membuat /init..."

cat >"$ROOTFS/init" <<'EOF'
#!/bin/sh

export PATH=/bin:/sbin:/usr/bin:/usr/sbin
export TERM=linux

mkdir -p /dev /proc /sys /tmp /dev/pts

mount -t devtmpfs devtmpfs /dev 2>/dev/null || true
mount -t proc proc /proc 2>/dev/null || true
mount -t sysfs sysfs /sys 2>/dev/null || true
mount -t devpts devpts /dev/pts 2>/dev/null || true
mount -t tmpfs tmpfs /tmp 2>/dev/null || true

[ -c /dev/console ] || mknod -m 622 /dev/console c 5 1
[ -c /dev/null ] || mknod -m 666 /dev/null c 1 3
[ -c /dev/zero ] || mknod -m 666 /dev/zero c 1 5
[ -c /dev/tty ] || mknod -m 666 /dev/tty c 5 0
[ -c /dev/tty0 ] || mknod -m 666 /dev/tty0 c 4 0
[ -c /dev/tty1 ] || mknod -m 666 /dev/tty1 c 4 1
[ -c /dev/fuse ] || mknod -m 666 /dev/fuse c 10 229

ifconfig lo up 2>/dev/null || true
ifconfig eth0 up 2>/dev/null || true
ip link set lo up 2>/dev/null || true
ip link set eth0 up 2>/dev/null || true
udhcpc -i eth0 -q -t 3 2>/dev/null || true

print_banner() {
    echo "Farewell Party"
    echo "Welcome, $1"
    echo
}

while true
do
    clear 2>/dev/null || true
    echo "======================================"
    echo " Farewell Party OS - Multi User"
    echo "======================================"
    echo
    echo -n "login: "
    read USERNAME
    echo -n "password: "
    read PASSWORD

    OK=0

    if [ "$USERNAME" = "root" ] && [ "$PASSWORD" = "root123" ]; then
        OK=1
    elif [ "$USERNAME" = "henn" ] && [ "$PASSWORD" = "henn123" ]; then
        OK=1
    elif [ "$USERNAME" = "hann" ] && [ "$PASSWORD" = "hann123" ]; then
        OK=1
    elif [ "$USERNAME" = "viii" ] && [ "$PASSWORD" = "viii123" ]; then
        OK=1
    elif [ "$USERNAME" = "kids" ] && [ "$PASSWORD" = "kids123" ]; then
        OK=1
    fi

    if [ "$OK" = "1" ]; then
        export USER="$USERNAME"
        export LOGNAME="$USERNAME"

        if [ "$USERNAME" = "root" ]; then
            export HOME=/root
            print_banner "$USERNAME"
            cd /root
            /bin/sh
        else
            export HOME="/home/$USERNAME"
            print_banner "$USERNAME"
            cd "$HOME" 2>/dev/null || cd /
            /bin/su "$USERNAME"
        fi
    else
        echo
        echo "Login incorrect"
        sleep 2
    fi
done
EOF

chmod +x "$ROOTFS/init"

echo "[+] Membuat initramfs multi.gz..."

if ! command -v fakeroot >/dev/null 2>&1; then
  echo "[!] fakeroot belum terinstall."
  echo "[!] Install dengan: sudo pacman -S --needed fakeroot"
  exit 1
fi

fakeroot -- bash -c '
set -e

ROOTFS="$1"
OUTPUT="$2"

cd "$ROOTFS"

rm -f dev/console dev/null dev/zero dev/tty dev/tty0 dev/tty1 dev/fuse

mknod -m 622 dev/console c 5 1
mknod -m 666 dev/null c 1 3
mknod -m 666 dev/zero c 1 5
mknod -m 666 dev/tty c 5 0
mknod -m 666 dev/tty0 c 4 0
mknod -m 666 dev/tty1 c 4 1
mknod -m 666 dev/fuse c 10 229

chown -R 0:0 .

chmod 755 init
chmod 1777 tmp
chmod 700 root
chmod 755 home
chmod 600 etc/shadow

chown 1001:1001 home/henn
chmod 700 home/henn

chown 1002:2001 home/hann
chmod 770 home/hann

chown 1003:2002 home/viii
chmod 770 home/viii

chown 1004:2003 home/kids
chmod 770 home/kids

find . | cpio -o -H newc --quiet | gzip -9 > "$OUTPUT"
' _ "$ROOTFS" "$OUTPUT"

echo "[✓] Selesai."
echo "[✓] Output: osboot/multi.gz"
