#!/bin/bash

BAR_SYMBOL="#"
MAX_WIDTH=$(($(tput cols) - 2))
BAR_WIDTH=$MAX_WIDTH
BAR_DURATION=$(($MAX_WIDTH * 1000))

while getopts 'w:s:d:' flag; do
	case "${flag}" in
		w) BAR_WIDTH=${OPTARG} ;;
		s) BAR_SYMBOL="${OPTARG}" ;;
		d) BAR_DURATION=${OPTARG} ;;
		*)
			printf "Usuage: $0 -w <width> -s <symbol> -d <duration_in_ms>\n"
			printf "Defaults: width: $MAX_WIDTH, symbol: $BAR_SYMBOL, duration: ${BAR_DURATION}ms\n"
			printf "Max width supported by your Terminal is $MAX_WIDTH\n"
       			exit 1
			;;
	esac
done

if [ $BAR_WIDTH -gt $MAX_WIDTH ] || [ $BAR_WIDTH -lt 4 ]; then
	printf "The provided width \"$BAR_WIDTH\" is invalid. It must be between 4 and $MAX_WIDTH (inclusive).\n"
	exit 1
elif [ ${#BAR_SYMBOL} -ne 1 ]; then
	printf "The provided symbol \"$BAR_SYMBOL\" is invalid. It must only be one character.\n"
	exit 1
elif [ $BAR_DURATION -le 0 ]; then
	printf "The provided duration \"$BAR_DURATION\" is invalid. It must be greater than 0.\n"
	exit 1
fi

UPDATE_TIME=$(awk "BEGIN { printf \"%.3f\", $BAR_DURATION / $BAR_WIDTH / 1000 }")

printf "[\033[s"

for ((char_idx = 1; char_idx <= BAR_WIDTH; char_idx++)); do
	bar="$bar$BAR_SYMBOL"

	percent=$(echo "scale=10; ($char_idx / $BAR_WIDTH) * 100" | bc | awk '{ print int($1) }')

	printf "\033[u$bar\033[u\033[$((BAR_WIDTH / 2 - 2))C$percent%%\033[u\033[${BAR_WIDTH}C]"

	sleep "$UPDATE_TIME"
done

printf "\n"
