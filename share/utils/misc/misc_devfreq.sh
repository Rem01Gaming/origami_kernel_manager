#!/data/data/com.termux/files/usr/bin/bash
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
# Copyright (C) 2023-2024 Rem01Gaming

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
	local devfreq_selected=$(ls $devfreq_path | fzf --reverse --cycle --prompt "Select a Devfreq Component: ")

	while true; do
		clear
		echo -e "\e[30;48;2;254;228;208;38;2;0;0;0m Origami Kernel Manager ${VERSION}$(yes " " | sed $((LINE - 30))'q' | tr -d '\n')\033[0m"
		echo -e "\e[38;2;254;228;208m"
		echo -e "    _________      [] $devfreq_selected Scalling freq: $(cat $devfreq_path/$devfreq_selected/max_freq)KHz - $(cat $devfreq_path/$devfreq_selected/min_freq)KHz" | cut -c 1-${LINE}
		echo -e "   /        /\\     [] $devfreq_selected Governor: $(cat $devfreq_path/$devfreq_selected/governor)"
		echo -e "  /        /  \\    "
		echo -e ' /        /    \   '
		echo -e '/________/      \  '
		echo -e '\        \      /  '
		echo -e ' \        \    /   '
		echo -e '  \        \  /    '
		echo -e '   \________\/     '
		echo -e "\n//////////////"
		echo -e "$(yes "─" | sed ${LINE}'q' | tr -d '\n')\n"
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
