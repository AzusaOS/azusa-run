# Running AZUSA

Right now AZUSA cannot be run standalone because its init project isn't ready yet.

You can however experimentally experience AZUSA inside a chroot in an existing Linux amd64 installation.

## Setting up APKG

First, you will need to run and install apkg as root. apkg will mount a filesystem in /pkg/main (dir will be created automatically) and put its files in /var/lib/apkg.

To download the latest version of apkg, run:

	curl -s https://raw.githubusercontent.com/TrisTech/make-go/master/get.sh | /bin/sh -s apkg

This will create a "apkg" binary. apkg has no external dependencies and only requires an internet connection and a valid resolver in /etc/resolv.conf.

Launch apkg as root and keep it open in a console in order to see what happens and stop it afterward (you can stop apkg with Ctrl-C, it will cause clean unmount of /pkg/main).

## Creating a chroot

Once you have installed apkg, creating a chroot is fairly easy.

Create en empty directory

	mkdir azusa

Initialize it

	/pkg/main/core.symlinks.core/azusa/makeroot.sh azusa

The makeroot.sh will initialize the directory with a number of needed files and symlinks. Feel free to have a look.

## Mounting

Typically Linux expects to find a number of things mounted in a chroot. We are going to mount a few things.

	cd azusa
	mkdir -p pkg/main
	mount -o bind /pkg/main pkg/main
	mount -t proc proc proc
	mount -o mode=1777 -t tmpfs tmpfs dev/shm

We could also mount other things (sysfs, etc) but these aren't needed right now.

## Entering the chroot

You can now enter the chroot.

	chroot . /bin/bash --login

You will see apkg download bash, glibc, etc as needed. You are now in a shell inside AZUSA. You can compile stuff with gcc, launch a nginx server, run some PHP scripts, etc. Everything you need will be downloaded by apkg seamlessly as you use it.

Note that currently apkg does not perform package partial download and streaming yet, which means that it might take some time for a package to be available. The future versions are expected to bring a much better experience.
