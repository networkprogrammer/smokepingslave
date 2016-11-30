#!/bin/bash
apt-get -qq update
if [ ! -e "slavesecrets.conf" ] || [ ! -e "smokeping.conf" ] || [ ! -e "scheduling" ] || [ ! -e "tcpping" ]
then
	echo "Some required files are missing. Exiting..."
	exit 1
fi
reportinghosturl="garbage value"
slavename="garbage value"
if [ ! $# -eq 3 ]
then
	echo "Not enough arguments to process request. Exiting..."
	echo "Usage: ./script.sh \"masterhost\" \"slavename\" \"key\""
	exit 1
elif [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]
then
	echo "Bad arguments. Exiting..."
	echo "Usage: ./script.sh \"masterhost\" \"slavename\" \"key\""
	exit 1
else
	reportinghosturl=$1
	slavename=$2
	slavesecrets=$3
fi

sed -i "s~#reportinghosturl#~$reportinghosturl/cgi-bin/smokeping.cgi~g" smokeping.conf
sed -i "s~#slavename#~$slavename~g" smokeping.conf
echo $3 >  slavesecrets.conf
sudo apt-get -yqq install --no-install-recommends smokeping
sudo apt-get -yqq install supervisor dnsutils tcptraceroute
sudo cp tcpping /usr/local/bin/tcpping
sudo chmod +x /usr/local/bin/tcpping
sudo cp smokeping.conf  /etc/supervisor/conf.d/smokeping.conf 
sudo cp slavesecrets.conf /etc/smokeping/slavesecrets.conf
sudo chmod 700 /etc/smokeping/slavesecrets.conf
sudo crontab -l >> scheduling
sudo crontab scheduling
sudo service smokeping stop
sudo systemctl disable smokeping
sudo systemctl enable supervisor
sudo systemctl start supervisor
sleep 30
tail -n 20 /var/log/syslog