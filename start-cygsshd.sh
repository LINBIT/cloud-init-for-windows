LOGFILE=/cygdrive/c/WinDRBD/start-cygsshd.log

if [ ! -e /cygdrive/c/WinDRBD ] ; then
        mkdir -p /cygdrive/c/WinDRBD
        echo "$( date ) C:\\WinDRBD didn't exist, created it. Please install WinDRBD." >> $LOGFILE
fi

i=0
while true
do
	if ! sc query cygsshd | grep RUNNING > /dev/null
	then
		echo "$( date ) cygsshd not running, trying to start it ($i) ..." >> $LOGFILE
		sc start cygsshd
	else
		echo "$( date ) cygsshd is running ($i)"
	fi
	sleep 3

	i=$[ $i+1 ]
done
