#!/bin/bash
template="template"

if [ $# -ne 2 ]
then
	echo "Usage $0 file host "
	exit 1
fi

file=$1
host=$2
mac=`mac_generation.sh`
long=${#mac}
while [ $long -ne 17 ]
do
	mac=`mac_generation.sh`
	long=${#mac}
done
sed -i 's/domains\/'$template'/domains\/'$host'/' $file
sed -i 's/name.*=.*/name\ =\ '"'$host'"'/' $file
sed -i 's/vif.*/vif\ =\ [ '"'mac=$mac'"' ] /' $file
echo "$mac"
