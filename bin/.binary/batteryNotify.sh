#!/bin/bash

hash notify-send 2>/dev/null || exit

CAPACITY=$(/usr/bin/cat /sys/class/power_supply/BAT*/capacity)


case $CAPACITY in 
	5) notify-send -t 2000 "low battery 5% "
		;;
	15) notify-send -t 2000 "low battery 15% "
		;;
	*)
		;;

	esac
		
	

	
