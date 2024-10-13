#!/bin/env bash
# This file is part of Origami Kernel Manager.
#
# Origami Kernel Manager is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Origami Kernel Manager is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Origami Kernel Manager.  If not, see <https://www.gnu.org/licenses/>.
#
# Copyright (C) 2023-present Rem01Gaming

header() {
	clear
	echo -e "\e[30;48;2;254;228;208m Origami Kernel Manager ${VERSION}$(printf '%*s' $((LINE - 30)) '')\033[0m"
	echo -e "\e[38;2;254;228;208m"
	cut -c 1-$LINE <<EOF
    _________      ${header_info[0]}
   /        /\\     ${header_info[1]}
  /        /  \\    ${header_info[2]}
 /        /    \\   ${header_info[3]}
/________/      \\  ${header_info[4]}
\\        \\      /  ${header_info[5]}
 \\        \\    /   ${header_info[6]}
  \\        \\  /    ${header_info[7]}
   \\________\\/     ${header_info[8]}

//////////////
EOF
	echo -e "$(printf '─%.0s' $(seq 1 $LINE))\n"
	echo -e "[] $1\033[0m"

	# Hide cursor
	tput civis
}

fzf_select() {
	options=($(echo $1))
	selected_option=$(printf "%s\n" "${options[@]}" | fzf --no-clear --reverse --cycle --prompt "$2")
	echo $selected_option
	clear >&2
}

fzf_select_n() {
	selected_option=$(echo -e "${1%\\n}" | fzf --no-clear --select-1 --reverse --cycle --prompt "$2")
	echo $selected_option
	clear >&2
}

fzy_select() {
	selected_option=$(echo -e "$1" | fzy -l 24 -p "$2")
	echo $selected_option
}

apply() {
	chmod 644 $2 >/dev/null 2>&1
	echo $1 >$2 2>/dev/null
	chmod 444 $2 >/dev/null 2>&1
}

color_blocks() {
	colors=(
		"\e[48;5;0m   \e[0m" "\e[48;5;1m   \e[0m" "\e[48;5;2m   \e[0m" "\e[48;5;3m   \e[0m"
		"\e[48;5;4m   \e[0m" "\e[48;5;5m   \e[0m" "\e[48;5;6m   \e[0m" "\e[48;5;7m   \e[0m"
		"\e[48;5;8m   \e[0m" "\e[48;5;9m   \e[0m" "\e[48;5;10m   \e[0m" "\e[48;5;11m   \e[0m"
		"\e[48;5;12m   \e[0m" "\e[48;5;13m   \e[0m" "\e[48;5;14m   \e[0m" "\e[48;5;15m   \e[0m"
	)

	for ((i = 0; i < ${#colors[@]}; i += 8)); do
		for ((j = i; j < i + 8; j++)); do
			echo -ne "${colors[$j]}"
		done
		echo
	done
}

# Usage: menu_value_tune "prompt comment" <path> <max value> <min value> <increment/decrement by ..>
menu_value_tune() {
	echo
	echo -e "$1" | fold -s -w $LINE
	echo -e "\nUse ( ↑ ↓ ) to increase or decrease value\nUse HOME or END to exit.\n"

	number=$(cat ${2})
	local x=${5}

	print_number() {
		printf "\r%s%s" "value: " "$number   "
	}

	while true; do
		print_number
		read -r -sN3 t
		case "${t:2:1}" in
		A)
			if ((number < ${3})); then
				((number += x))
			fi
			;;
		B)
			if ((number > ${4})); then
				((number -= x))
			fi
			;;
		H | F) break ;;
		esac

		apply $number $2
	done
}

print_existing_folders() {
	directory="$1"
	shift

	existing_folders=()

	for folder in "$@"; do
		if [ -d "$directory/$folder" ]; then
			existing_folders+=("$folder")
		fi
	done

	if [ ! ${#existing_folders[@]} -eq 0 ]; then
		echo "${existing_folders[*]}"
	fi
}

braille_throbber=(
	$'\u2839'
	$'\u2838'
	$'\u2834'
	$'\u2826'
	$'\u2807'
	$'\u280F'
	$'\u2819'
)

throbber() {
	while true; do
		for char in "${braille_throbber[@]}"; do
			echo -ne "\e[0;32m$char\e[0m $1\r"
			sleep 0.1
		done
	done
}

start_throbber() {
	throbber "$1" &
	THROBBER_PID=$!
}

stop_throbber() {
	kill "$THROBBER_PID" 2>/dev/null
	wait "$THROBBER_PID" 2>/dev/null
	echo -ne "\r\033[K" # Clear the line
}

open_link() {
	if [ $ANDROID ]; then
		/system/bin/am start -a android.intent.action.VIEW -d "$1" >/dev/null 2>&1 &
	else
		xdg-open "$1" >/dev/null 2>&1 &
	fi
}

unset_headvar() {
	unset options
	unset header_info
}
