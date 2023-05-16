# Simple incomplete cloud init for Windows

This is a very basic implementation of cloud init for
the Microsoft Windows platform. Cloud init is used to
configure instance specific properties (like hostname,
ssh keys) of virtual machines.

## How it works

The hypervisor adds a CDROM drive with an virtual ISO
image containing two files: `user-data` and `meta-data`.
They contain instance specific data (like hostname,
ssh keys) in a yaml format.

## Prerequisites

Since cloud-init for Windows was orginally developed
for our (Linbit) internal ci system (which also
virter was written for) it requires cygwin (including
the openssh package) to be installed on the machine.
Please refer to the virter documentation for more
information about setting up such Windows virtual
machine templates.

The main work is done by a bash script, so we need
to have cygwin installed on the Windows VM. 
Windows Subsystem for Linux (WSL) does *not* work.

## Functionality

Again, because we use it in our internal ci, only
the features we need are implemented. These are:

 * Setting the hostname (including rebooting the
   machine if necessary).

 * Install the ssh host keys and authorized keys
   (to make `virter vm ssh` work)

 * Make sure that cygsshd (the OpenSSH daemon)
   is actually running.

That's it.

## Installing

There is an inno-setup installer script that adds
a Windows task scheduler job to run cloud-init for
Windows on system startup. It will generate an
EXE file which must be run on the VM template
before creating VM instances.

## Building

You need:

 * A copy of [inno-setup](https://jrsoftware.org/isinfo.php)
   version 5 (version 6 may work but hasn't been tested).

 * If you are building on Linux, you also need
   [wine](https://www.winehq.org/)

 * If you are building on Windows you just can unset
   WINE in the Makefile.

The run

    make

This will create a file called `install-cloud-init-$VERSION.exe`.
(you might have to also pull the git tags using:

    git pull --tags

).

This file then has to be run on the virtual machine template.

If you are running in an ssh session add the `/verysilent`
parameter as follows:

    install-cloud-init-0.6.exe /verysilent

## Questions?

The author of this little script can be reached at
`johannes@johannesthoma.com`

Have fun :)

