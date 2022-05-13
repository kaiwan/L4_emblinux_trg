#!/bin/bash
# Blink the BBB's built-in LEDs
# NOTE: meant for the BeagleBone Black running standard Debian
# ref: https://robotic-controls.com/learn/beaglebone/beaglebone-black-built-leds
name=$(basename $0)
usage() {
 echo "Usage: ${name} LED#
FYI, defaults on the BBB are:
    • USR0 :  [heartbeat]    (like an aircraft’s lights!)
    • USR1 :  [mmc0]
    • USR2 :  [cpu0]
    • USR3 :  [mmc1]
(Pass LED# as 0 for USR0, 1 for USR1, ...)
"
}

[ $(id -u) -ne 0 ] && {
	echo "needs root."
	exit 1
}
[ $# -ne 1 ] && {
	usage
	exit 1
}
LEDNUM=$1
[ ${LEDNUM} -lt 0 -o ${LEDNUM} -gt 3 ] && {
	echo "${name}: invalid LED# ${LEDNUM} (has to be between 0-3)"
	exit 1
}

# take it over
echo timer > /sys/devices/platform/leds/leds/beaglebone\:green\:usr${LEDNUM}/trigger

# blink it by toggling it on/off
echo 100 > /sys/devices/platform/leds/leds/beaglebone\:green\:usr${LEDNUM}/delay_on
echo 500 > /sys/devices/platform/leds/leds/beaglebone\:green\:usr${LEDNUM}/delay_off
