#!/bin/sh
set -e

KVER=`cat /pkg/main/sys-kernel.linux.core/version.txt`
INITVER=`readlink readlink /pkg/main/azusa.init | sed -r -e 's/.*\.([0-9]+)\..*/\1/'`

echo "Building initrd for kernel version $KVER with init $INITVER"

RELEASE="$KVER.$INITVER"
INITRD_CPIO="initrd-$RELEASE.cpio"
INITRD_DIR="initrd-$RELEASE-tmp"
INITRD="initrd-$RELEASE.img"
KERNEL="kernel-$RELEASE.img"
ARCHIVE="azusa-$RELEASE.tar.gz"
ROOTDIR="$PWD"

echo "Preparing initrd for kernel $KVER"

cd "/pkg/main/sys-kernel.linux.modules.${KVER}"
find . | cpio -H newc -o -R +0:+0 --file "$ROOTDIR/$INITRD_CPIO"

cd "$ROOTDIR"
mkdir "$INITRD_DIR"
cd "$INITRD_DIR"

echo "Adding tools..."

# prepare environment
mkdir -p usr/azusa
cp -T "/pkg/main/azusa.apkg.core/apkg" usr/azusa/apkg
cp -T /pkg/main/sys-apps.busybox.core/bin/busybox usr/azusa/busybox
cp -T "/pkg/main/azusa.init.$INITVER/init" init

find -L . | cpio -H newc -o -R +0:+0 --append --file "$ROOTDIR/$INITRD_CPIO"

cd "$ROOTDIR"
rm -fr "$INITRD_DIR"

echo "Compressing..."
xz -v --check=crc32 --x86 --lzma2 --stdout "$INITRD_CPIO" >"$INITRD"
rm -f "$INITRD_CPIO"

echo "Copy kernel..."
cp -T /pkg/main/sys-kernel.linux.core.$KVER/linux-$KVER.img "$KERNEL"

echo "Archive..."
tar czf "$ARCHIVE" "$INITRD" "$KERNEL"

echo "Checksum..."
sha1sum -b "$ARCHIVE" >"release/azusa-$RELEASE.sha1"
sha256sum -b "$ARCHIVE" >"release/azusa-$RELEASE.sha256"

rm "$INITRD" "$KERNEL"

echo "Complete!"
echo "git add release"
echo "git commit -a -m 'Release $RELEASE'"
echo "git tag v$RELEASE"
echo "git push && git push --tags"

