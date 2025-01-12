#!/usr/bin/env bash

power=$(cat /sys/class/power_supply/BAT1/current_now /sys/class/power_supply/BAT1/voltage_now | xargs | awk '{ printf "%.1f\n", $1 * $2 / 1e12 }')

echo $power
