[![Telegram](https://img.shields.io/badge/chat-telegram-blue.svg?logo=telegram&logoColor=white)](https://t.me/azusa_en)

# Running AZUSA

You can experimentally experience AZUSA inside a vm or on a computer by downloading one of our iso images and running it on a CD or a USB disk.

Download [the latest binary release](https://github.com/AzusaOS/azusa-run/releases) as ISO file (found in "Assets").

The default root password will be set to "azusa".

## Running in qemu

	qemu-system-x86_64 -m 4096 --enable-kvm -cpu host -cdrom azusa-*.iso

Or if kvm is not available on your system:

	qemu-system-x86_64 -m 4096 -cdrom azusa-*.iso
