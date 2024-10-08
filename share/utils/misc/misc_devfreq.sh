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

devfreq_set_freq() {
	local devfreq_path=/sys/class/devfreq
	if [[ $1 == "-exec" ]]; then
		local freq=$2
		local max_min=$3
		local devfreq_selected=$4
	else
		local max_min=$1
		local devfreq_selected=$2
		local freq=$(fzf_select "$(cat $devfreq_path/$devfreq_selected/available_frequencies)" "Select $max_min freq: ")
		command2db devfreq.$devfreq_selected.${max_min}_freq "devfreq_set_freq -exec $freq $max_min" FALSE
	fi
	apply $freq $devfreq_path/$devfreq_selected/${max_min}_freq
}

devfreq_set_gov() {
	local devfreq_path=/sys/class/devfreq
	if [[ $1 == "-exec" ]]; then
		local selected_gov=$2
		local devfreq_selected=$3
	else
		local devfreq_selected=$1
		local selected_gov=$(fzf_select "$(cat $devfreq_path/$devfreq_selected/available_governors)" "Select Governor: ")
		command2db devfreq.$devfreq_selected.governor "devfreq_set_gov -exec $selected_gov $selected_devfreq" FALSE
	fi
	apply $selected_gov $devfreq_path/$devfreq_selected/governor
}

devfreq_menu() {
	local devfreq_path=/sys/class/devfreq
	local devfreq_list=()
	for dir in $devfreq_path/*.*; do
		if [ -d $dir ]; then
			devfreq_list+=($(basename $dir))
		fi
	done

	if [ ${#devfreq_list[@]} -eq 0 ]; then
		echo -e "\n[-] Your kernel doesn't have any devfreq devices"
		echo "[*] Hit enter to back to main menu"
		read -r -s
		return 0
	fi

	local devfreq_selected=$(fzf_select "${devfreq_list[@]}" "Select a Devfreq Component: ")
	unset devfreq_list

	while true; do
		clear
		echo -e "\e[30;48;2;254;228;208m Origami Kernel Manager ${VERSION}$(printf '%*s' $((LINE - 30)) '')\033[0m"
		echo -e "\e[38;2;254;228;208m"
		echo -e "    _________      [] $devfreq_selected Scalling freq: $(cat $devfreq_path/$devfreq_selected/min_freq)KHz - $(cat $devfreq_path/$devfreq_selected/max_freq)KHz" | cut -c 1-${LINE}
		echo -e "   /        /\\     [] $devfreq_selected Governor: $(cat $devfreq_path/$devfreq_selected/governor)"
		echo -e "  /        /  \\    "
		echo -e ' /        /    \   '
		echo -e '/________/      \  '
		echo -e '\        \      /  '
		echo -e ' \        \    /   '
		echo -e '  \        \  /    '
		echo -e '   \________\/     '
		echo -e "\n//////////////"
		echo -e "$(printf '─%.0s' $(seq 1 $LINE))\n"
		echo -e "[] $devfreq_selected Devfreq Control\033[0m"

		tput civis

		case $(fzy_select "Set max freq\nSet min freq\nSet Governor\nBack to main menu" "") in
		"Set max freq") devfreq_set_freq max $devfreq_selected ;;
		"Set min freq") devfreq_set_freq min $devfreq_selected ;;
		"Set Governor") devfreq_set_gov $devfreq_selected ;;
		"Back to main menu") break ;;
		esac
	done
}
