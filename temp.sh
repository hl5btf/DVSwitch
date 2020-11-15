#!/bin/bash

#===================================
SCRIPT_VERSION="Menu Script v.1.60"
SCRIPT_AUTHOR="HL5KY"
SCRIPT_DATE="10/15/2020"
#===================================

source /var/lib/dvswitch/dvs/var.txt

cpu_usage=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)* id.*/\1/" | awk '{printf "%.0f", 100 - $1}')

#temp=$(vcgencmd measure_temp)
temp=$(cat /sys/class/thermal/thermal_zone0/temp)
temp=$(($temp/1000))

# do not send cpu temp if no change from last check
#if [ $temp != ${cpu_temp} ]; then
  update_var cpu_temp ${temp}
# ${MESSAGE} "  CPU   Temp = ${temp}'C  "
  ${MESSAGE} "  CPU   Temp = ${temp}'C   Usage = ${cpu_usage}%  "
#fi

exit 0
