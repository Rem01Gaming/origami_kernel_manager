#!/data/data/com.termux/files/usr/bin/bash

fzf_select() {
	options=($(echo $1))
	selected_option=$(printf "%s\n" "${options[@]}" | fzf --reverse --cycle --prompt "$2")
	echo $selected_option
}

fzy_select() {
	selected_option=$(echo -e "${1}" | fzy -l 15 -p "$2")
	echo $selected_option
}

color_blocks() {
	colors=(
		"\e[48;5;0m   \e[0m" "\e[48;5;1m   \e[0m" "\e[48;5;2m   \e[0m" "\e[48;5;3m   \e[0m"
		"\e[48;5;4m   \e[0m" "\e[48;5;5m   \e[0m" "\e[48;5;6m   \e[0m" "\e[48;5;7m   \e[0m"
		"\e[48;5;8m   \e[0m" "\e[48;5;9m   \e[0m" "\e[48;5;10m   \e[0m" "\e[48;5;11m   \e[0m"
		"\e[48;5;12m   \e[0m" "\e[48;5;13m   \e[0m" "\e[48;5;14m   \e[0m" "\e[48;5;15m   \e[0m"
	)

	for ((i=0; i<${#colors[@]}; i+=8)); do
		for ((j=i; j<i+8; j++)); do
			echo -ne "${colors[$j]}"
		done
		echo
	done
}

# Usage: menu_value_tune "prompt comment" <max value> <min value> <increment/decrement by ..>
menu_value_tune() {
    echo
	echo -e "${1}" | fold -s -w ${LINE}
	echo -e "\nUse ( ↑ ↓ ) to increase or decrease value\nUse HOME or END to exit\n"

	number=$(cat ${2})
	x=${5}

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
			*) break ;;
		esac

		echo $number > ${2} 2>/dev/null
	done
}

clear() {
echo -e "\033[H\033[2J\033[3J$"
tput cuu 1
}
