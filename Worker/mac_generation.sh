#!/bin/bash
RANGE=255
#set integer ceiling

number=$RANDOM
numbera=$RANDOM
numberb=$RANDOM
#generate random numbers

let "number %= $RANGE"
let "numbera %= $RANGE"
let "numberb %= $RANGE"
#ensure they are less than ceiling

octets='00:16:3E'
#set mac stem

octeta=`echo "obase=16;$number" | bc`
octetb=`echo "obase=16;$numbera" | bc`
octetc=`echo "obase=16;$numberb" | bc`
#use a command line tool to change int to hex(bc is pretty standard)
#they're not really octets.  just sections.

macadd="${octets}:${octeta}:${octetb}:${octetc}"
#concatenate values and add dashes


echo $macadd
#echo result to screen
#note: does not generate a leading zero on single character sections.  easily remediedm but that's an exercise for you
