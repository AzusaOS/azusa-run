#!/bin/sh
set -e

KVER=`cat /pkg/main/sys-kernel.linux.core/version.txt`
INITVER=`readlink /pkg/main/azusa.init.core | sed -r -e 's/.*\.([0-9]+)\..*/\1/'`

echo "Building initrd for kernel version $KVER with init $INITVER"

RELEASE="$(TZ=UTC date '+%Y%m%d%H%M%S')"
INITRD_CPIO="initrd-$RELEASE.cpio"
INITRD_DIR="initrd-$RELEASE-tmp"
INITRD="initrd-$KVER.img"
KERNEL="kernel-$KVER.img"
ARCHIVE="azusa-$RELEASE.iso"
ROOTDIR="$PWD/cdroot"
mkdir cdroot cdroot/isolinux

echo "Preparing initrd for kernel $KVER"

cd "/pkg/main/sys-kernel.linux.modules.${KVER}"
find . | cpio -H newc -o -R +0:+0 --file "$ROOTDIR/$INITRD_CPIO"

cd "$ROOTDIR"
mkdir "$INITRD_DIR"
cd "$INITRD_DIR"

echo "Adding tools..."

# prepare environment
mkdir -p usr/azusa etc
cp -T "/pkg/main/azusa.apkg.core/apkg" usr/azusa/apkg
cp -T /pkg/main/sys-apps.busybox.core/bin/busybox usr/azusa/busybox
cp -T "/pkg/main/azusa.init.core.$INITVER/init" init
cp -T /pkg/main/azusa.baselayout.core/etc/shadow etc/shadow
# update root password to "azusa"
sed -i 's/^root:\*:/root:$1$ZOxNJ00C$lfCUkDnpSu9tSBothd4lQ.:/' etc/shadow
chmod 0600 etc/shadow

find -L . | cpio -H newc -o -R +0:+0 --append --file "$ROOTDIR/$INITRD_CPIO"

cd "$ROOTDIR"
rm -fr "$INITRD_DIR"

echo "Compressing..."
xz -v --check=crc32 --x86 --lzma2 --stdout "$INITRD_CPIO" >"isolinux/$INITRD"
rm -f "$INITRD_CPIO"

echo "Copy kernel..."
cp -T /pkg/main/sys-kernel.linux.core.$KVER/linux-$KVER.img "isolinux/$KERNEL"

echo "Copy syslinux"
cp -T /pkg/main/sys-boot.syslinux.core/share/syslinux/isolinux.bin isolinux/isolinux.bin
cp -T /pkg/main/sys-boot.syslinux.core/share/syslinux/linux.c32 isolinux/linux.c32
cp -T /pkg/main/sys-boot.syslinux.core/share/syslinux/ldlinux.c32 isolinux/ldlinux.c32
cp -T /pkg/main/sys-boot.syslinux.core/share/syslinux/efi64/syslinux.efi isolinux/efiboot.img
cat >isolinux/isolinux.cfg <<EOF
DEFAULT azusa
SAY Now booting AZUSA...

LABEL azusa
	KERNEL /isolinux/$KERNEL
	APPEND initrd=/isolinux/$INITRD quiet loglevel=3 azusa=live vga=current
EOF

echo "Make ISO..."
cd ..
xorriso -as mkisofs -o "$ARCHIVE" -isohybrid-mbr /pkg/main/sys-boot.syslinux.core/share/syslinux/isohdpfx.bin -c isolinux/boot.cat -b isolinux/isolinux.bin -no-emul-boot -boot-load-size 4 -boot-info-table -eltorito-alt-boot -e isolinux/efiboot.img -no-emul-boot -isohybrid-gpt-basdat cdroot

echo "Checksum..."
sha1sum -b "$ARCHIVE" >"release/azusa-$RELEASE.sha1"
sha256sum -b "$ARCHIVE" >"release/azusa-$RELEASE.sha256"

rm -fr cdroot

echo "Complete!"
echo "git add release/azusa-$RELEASE.*"
echo "echo $RELEASE >release/LATEST.txt && git add release/LATEST.txt"
echo "git commit -a -m 'Release $RELEASE'"
echo "git tag v$RELEASE"
echo "git push && git push --tags"

