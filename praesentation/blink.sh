#!/bin/sh
set -x
export LANG=C

# trap ctrl-c and call ctrl_c()
trap ctrl_c INT

function ctrl_c() {
	echo "** Trapped CTRL-C"
	for child in $children; do
		kill $child
	done
	exit
}

function set_color {
	local light=$1
	local color=$2
	local transition=$3

	../lolo-cli/lolo.rb light $light -t $transition $color
	sleep $transition
}

function random_color {
	local colors=(red blue green cold warm "hex 942b85")
	local color=${colors[$RANDOM % ${#colors[@]} ]}
	echo $color
}

function random_transition {
	local transition=`awk -v "seed=$[(RANDOM & 32767) + 32768 * (RANDOM & 32767)]" \
				 'BEGIN { srand(seed); printf("%.1f\n", rand() * 2.0) }'`
	echo $transition
}

function light_loop {
	local light=$1

	# introduce initial delay between lights
	sleep $(random_transition)

	while true; do
		#set_color $light "$(random_color)" "$(random_transition)"
		set_color $light "$(random_color)" "2.0"
	done
}

# Spawn children for each light.  Each child randomly changes
# the color of its designated light.  Record child pid so we can
# kill it later.
children=""
lights="L1 L2 L3"
for light in $lights; do
	light_loop $light &
	children="$children $!"
done

# Master sleeper.
while true; do
	sleep 60;
done
