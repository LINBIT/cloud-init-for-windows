LOGFILE=/cygdrive/c/WinDRBD/cloud-init.log
HOME=/home/Administrator

if [ ! -e /cygdrive/c/WinDRBD ] ; then
	mkdir -p /cygdrive/c/WinDRBD
	echo "$( date ) C:\\WinDRBD didn't exist, created it. Please install WinDRBD." >> $LOGFILE
fi

found=0
while true
do
	for CDROM in /cygdrive/?
	do
		if [ -e $CDROM -a -f $CDROM/meta-data -a -f $CDROM/user-data ] ; then
			echo "$( date ) $CDROM (and $CDROM/meta-data and $CDROM/user-data) found, using that as configuration" >> $LOGFILE
			found=1
			break
		fi
	done
	if [ $found -eq 1 ]
	then
		break
	fi
	echo "$( date ) No virter ci CDROM found. Please use virter to control this VM." >> $LOGFILE
	echo "$( date ) I am searching again in 5 seconds ..." >> $LOGFILE
	sleep 5
done

if [ $found -eq 0 ] ; then
	echo "$( date ) $CDROM (or $CDROM/meta-data or $CDROM/user-data) didn't exist. Please use virter to control this VM." >> $LOGFILE
	exit 1
fi

echo "$( date ) Simple Incomplete Cloud Init For Windows started." >> $LOGFILE

# First thing: tell virter that we are not yet ready ...
rm -f /run/cloud-init/result.json

HOSTNAME=$( hostname )
WANTED_HOSTNAME=$( grep local-hostname $CDROM/meta-data | cut -d' ' -f2 )

if [ "$HOSTNAME" -a "$WANTED_HOSTNAME" -a "$HOSTNAME" != "$WANTED_HOSTNAME" ]
then
	echo "$( date ) Attempt to change hostname from $HOSTNAME to $WANTED_HOSTNAME (need to reboot)" >> $LOGFILE
	powershell -Command "Rename-Computer -NewName $WANTED_HOSTNAME -Force"
	echo "$( date ) Now rebooting ..." >> $LOGFILE
	shutdown /r /t 0
# don't do anything else, we get called again hopefully with the new
# hostname after reboot.
	exit 0
fi

echo "$( date ) Installing SSH keys ..." >> $LOGFILE

# Only do this once, not on every system startup
if [ ! -e /etc/dont-overwrite-ssh-keys ]
then
	echo "$( date ) Looks like this is the first system start, installing ssh keys" >> $LOGFILE
	mv /etc/ssh_host_rsa_key /etc/ssh_host_rsa_key.orig
	mv /etc/ssh_host_rsa_key.pub /etc/ssh_host_rsa_key.pub.orig
	mkdir -p $HOME/.ssh
	mv $HOME/.ssh/authorized_keys $HOME/.ssh/authorized_keys.orig

# parse private host key:
	sed -e '/----BEGIN/,/----END/!d' $CDROM/user-data | sed -e 's/^ *//g' > /etc/ssh_host_rsa_key
# parse public host key:
	sed -e '1,/rsa_public:/d' $CDROM/user-data | sed -e '2,$d' | sed -e 's/^[ -]*//g' > /etc/ssh_host_rsa_key.pub
# parse authorized public key:
	sed -e '1,/ssh_authorized_keys:/d' $CDROM/user-data | sed -e '2,$d' | sed -e 's/^[ -]*//g' > $HOME/.ssh/authorized_keys

# Give all files to Administrator (else ssh might work or not):
	chown Administrator.None $HOME/.ssh/authorized_keys /etc/ssh_host_rsa_key.pub /etc/ssh_host_rsa_key

# set permissions for host key:
	chmod 600 /etc/ssh_host_rsa_key

# and restart cygsshd (necessary on Windows Server 2016)
	echo "$( date ) Restarting cygsshd ..." >> $LOGFILE

	sc stop cygsshd >> $LOGFILE
	sc start cygsshd >> $LOGFILE
else
	echo "$( date ) Not overwriting (possibly changed) ssh keys" >> $LOGFILE
fi

# this creates one storage spaces storage pool with all available physical
# disks (typically only one). Storage Pool is called LINSTORTest
# Should be done by provisioning scripts in the test repos
# powershell -Command '$PhysicalDisks = (Get-PhysicalDisk -CanPool $True) ; New-StoragePool -FriendlyName LINSTORTest -StorageSubsystemFriendlyName "Windows Storage*" -PhysicalDisks $PhysicalDisks'

echo "$( date ) Done, telling virter that we are ready ..." >> $LOGFILE

mkdir -p /run/cloud-init
touch /run/cloud-init/result.json

# start cygsshd and make sure it is started.
# This should solve ocosional ERRORs we observe in LINSTOR tests
# (vm run --wait-ssh fails)
# do this by grepping sc query cygsshd output for RUNNING
# maybe we want a ko count here ...
# Do this forever. With DRBD9 tests we observe
# cygsshd crashing from time to time and not being
# restarted (even when windows is configured for it)

i=0
while true
do
	sleep 3
	if ! sc query cygsshd | grep RUNNING > /dev/null
	then
		echo "$( date ) cygsshd not running, trying to start it ($i) ..." >> $LOGFILE
		sc start cygsshd >> $LOGFILE
	else
		echo "$( date ) cygsshd is running ($i)" >> $LOGFILE
	fi

	i=$[ $i+1 ]
done
