# Running AZUSA

Right now AZUSA cannot be run standalone because its bootloader isn't ready yet.

You can however experimentally experience AZUSA inside a qemu VM.

Download [the latest binary release](https://github.com/AzusaOS/azusa-run/releases) first and extract it, then run in that directory:

	qemu-system-x86_64 -kernel kernel-*.img -initrd initrd-*.img -m 4096 --enable-kvm -cpu host
