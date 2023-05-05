LOGFILE=/cygdrive/c/WinDRBD/cloud-init.log
CDROM=/cygdrive/d
HOME=/home/Administrator

if [ ! -e /cygdrive/c/WinDRBD ] ; then
	mkdir -p /cygdrive/c/WinDRBD
	echo "$( date ) C:\\WinDRBD didn't exist, created it. Please install WinDRBD." >> $LOGFILE
fi

if [ ! -e $CDROM -o ! -f $CDROM/meta-data -o ! -f $CDROM/user-data ] ; then
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
	shutdown /r /t 0
# don't do anything else, we get called again hopefully with the new
# hostname after reboot.
	exit 0
fi

echo "$( date ) Installing SSH keys ..." >> $LOGFILE

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

# this creates one storage spaces storage pool with all available physical
# disks (typically only one). Storage Pool is called LINSTORTest
# powershell -Command '$PhysicalDisks = (Get-PhysicalDisk -CanPool $True) ; New-StoragePool -FriendlyName LINSTORTest -StorageSubsystemFriendlyName "Windows Storage*" -PhysicalDisks $PhysicalDisks'

# start cygsshd and make sure it is started.
# This should solve ocosional ERRORs we observe in LINSTOR tests
# (vm run --wait-ssh fails)
# do this by grepping sc query cygsshd output for RUNNING
# maybe we want a ko count here ...

while ! sc query cygsshd | grep RUNNING > /dev/null
do
	echo "$( date ) cygsshd not running, trying to start it ..." >> $LOGFILE
	sc start cygsshd
	sleep 10
done

echo "$( date ) Done, telling virter that we are ready ..." >> $LOGFILE

mkdir -p /run/cloud-init
touch /run/cloud-init/result.json
