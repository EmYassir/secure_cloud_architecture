#!/bin/bash

if [ $# != 1 ]
then
	echo "usage : $0 mac_adress"
else
	ip n flush all
	arping -i br0 $1 -c1 | grep '): icmp' | cut -d ' ' -f4
fi

