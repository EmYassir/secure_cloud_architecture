#!/bin/bash

if [ $# -ne 2 ]
then
	echo "Usage: demarre idjob user "
	exit 1
fi

host=$1
user=$2
echo "idjob: $host"
echo "user: $user"
file=/etc/xen/$host.cfg
template="template"

# copier les image
echo "Copy started at: `date`"
cp -R /home/xen/domains/$template/ /home/xen/domains/$host
echo "Copy termined at: `date`"
# modifier le ficher de configuration
cp /etc/xen/$template.cfg $file
mac=`modify_script.sh $file $host`

#Demmarer la machine virtuelle
echo "starting vm"
xm create $file
sleep 20
echo "mac : $mac"
#Adresse ip
address_ip=`getip.sh $mac`
i=0
while [ $i -ne 1 ]
do
	if [ -z "$address_ip" ] && [ "${address_ip+xxx}" = "xxx" ]; 
	then
		sleep 10
		address_ip=`getip.sh $mac`
		echo $host"_ip = "$address_ip
	else
		i=1;
	fi
done
#address_ip="10.0.0.253"
echo "address_ip = $address_ip"

# mounter le repertoire avec sshfs
mkdir /tmp/$host
sshfs /tmp/$host user@$address_ip:/home/user
mv /tmp/$host.tar.gz /tmp/$host/

#il faut garantir la non-repudiabilité
ssh -f root@$address_ip '/opt/root_run.sh '$host
ssh -f user@$address_ip '/opt/vm_run.sh'

i="0"
time="5"
while [ $i -ne "1" ]
do
	sleep $time
	if [ -e "/tmp/$host/termine/donefinito"   ]
	then
		i="1"
	fi
done

cp /tmp/$host/$host.tar.gz /opt/

# terminé la machine
umount /tmp/$host
rm -rf /tmp/$host
xm destroy $host
rm -rf /home/xen/domains/$host/
rm -rf $file
