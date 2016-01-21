#!/bin/sh
set -x
export LANG=C

function set_color {
	local light=$1
	local color=$2
	local transition=$3

	# UNUSED, can be switched with the other while below
	while false; do
		s=`ps auxww | grep "lolo $light" | grep -v grep`
		if [ "$s" == "" ]; then
			break
		fi
	done

	../lolo-cli/lolo.rb light $light -t $transition $color
	sh -c "sleep $transition && echo 'lolo $light'" >/dev/null &
}

function random_color {
	local colors=(red blue green cold warm "hex 942b85")
	local color=${colors[$RANDOM % ${#colors[@]} ]}
	echo $color
}

function random_light {
	local lights=(L1 L2 L3)

	# Wait for a light to free up before returning.
	while true; do
		local light=${lights[$RANDOM % ${#lights[@]} ]}
		s=`ps auxww | grep "lolo $light" | grep -v grep`
		if [ "$s" == "" ]; then
			break
		fi
	done

	echo $light
}

function random_transition {
	local transition=`awk -v "seed=$[(RANDOM & 32767) + 32768 * (RANDOM & 32767)]" \
				 'BEGIN { srand(seed); printf("%.1f\n", rand() * 2.0) }'`
	echo $transition
}

while true; do
	#set_color "$(random_light)" "$(random_color)" "$(random_transition)"
	set_color "$(random_light)" "$(random_color)" "1.0"
done
