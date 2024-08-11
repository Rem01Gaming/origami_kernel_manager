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

qcom_cpubus_set_freq() {
	local cpubus_path=/sys/devices/system/cpu/bus_dcvs
	if [[ $1 == "-exec" ]]; then
		local freq=$2
		local max_min=$3
		local cpubus_selected=$4
	else
		local max_min=$1
		local cpubus_selected=$2
		local freq=$(fzf_select "$(cat $cpubus_path/$cpubus_selected/available_frequencies)" "Select $max_min freq: ")
		command2db qcom.cpubus.$cpubus_selected.${max_min}_freq "qcom_cpubus_set_freq -exec $freq $max_min $cpubus_selected" FALSE
	fi
	for path in $cpubus_path/$cpubus_selected/*/${max_min}_freq; do
		apply $freq $path
	done
}

qcom_cpubus() {
	local cpubus_path=/sys/devices/system/cpu/bus_dcvs
	local cpubus_selected=$(ls $cpubus_path | fzf --reverse --cycle --prompt "Select CPU Bus Component: ")

	while true; do
		for i in $cpubus_path/$cpubus_selected/*/min_freq; do
			local min_freq=$(cat $i)
			break
		done

		for i in $cpubus_path/$cpubus_selected/*/max_freq; do
			local max_freq=$(cat $i)
			break
		done

		clear
		echo -e "\e[30;48;2;254;228;208;38;2;0;0;0m Origami Kernel Manager ${VERSION}$(yes " " | sed $((LINE - 30))'q' | tr -d '\n')\033[0m"
		echo -e "\e[38;2;254;228;208m"
		echo -e "    _________      [] $cpubus_selected Scalling freq: ${min_freq}KHz - ${max_freq}KHz" | cut -c 1-${LINE}
		echo -e "   /        /\\     "
		echo -e "  /        /  \\    "
		echo -e " /        /    \\   "
		echo -e "/________/      \\  "
		echo -e "\\        \\      /  "
		echo -e " \\        \\    /   "
		echo -e "  \\        \\  /    "
		echo -e "   \\________\\/     "
		echo -e "\n//////////////"
		echo -e "$(yes "─" | sed ${LINE}'q' | tr -d '\n')\n"
		echo -e "\e[38;2;254;228;208m[] $cpubus_selected Bus control\033[0m"

		tput civis

		case $(fzy_select "Set max freq\nSet min freq\nBack to main menu" "") in
		"Set max freq") qcom_cpubus_set_freq max $cpubus_selected ;;
		"Set min freq") qcom_cpubus_set_freq min $cpubus_selected ;;
		"Back to main menu") break ;;
		esac
	done
}
