# First thing: tell virter that we are not yet ready ...
rm -f /run/cloud-init/result.json

# if test -f /run/cloud-init/result.json
# then
# 	echo "Init already done doing nothing"
# 	exit 0	# already done
# fi

CDROM=/cygdrive/d
HOME=/home/Administrator

HOSTNAME=$( hostname )
WANTED_HOSTNAME=$( grep local-hostname $CDROM/meta-data | cut -d' ' -f2 )

if [ "$HOSTNAME" -a "$WANTED_HOSTNAME" -a "$HOSTNAME" != "$WANTED_HOSTNAME" ]
then
	powershell -Command "Rename-Computer -NewName $WANTED_HOSTNAME -Force"
	shutdown /r /t 0
# don't do anything else, we get called again hopefully with the new
# hostname after reboot.
	exit 0
fi

mv /etc/ssh_host_rsa_key /etc/ssh_host_rsa_key.orig
mv /etc/ssh_host_rsa_key.pub /etc/ssh_host_rsa_key.pub.orig
mv $HOME/.ssh/authorized_keys $HOME/.ssh/authorized_keys.orig

# parse private host key:
sed -e '/BEGIN/,/END/!d' $CDROM/user-data | sed -e 's/^ *//g' > /etc/ssh_host_rsa_key
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

mkdir -p /run/cloud-init
touch /run/cloud-init/result.json
