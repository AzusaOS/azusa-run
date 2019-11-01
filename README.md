# Running AZUSA

You can experimentally experience AZUSA inside a vm or on a computer by downloading one of our iso images and running it on a CD or a USB disk.

Download [the latest binary release](https://github.com/AzusaOS/azusa-run/releases).

## Running in qemu

	qemu-system-x86_64 -m 4096 --enable-kvm -cpu host -cdrom azusa-*.iso
