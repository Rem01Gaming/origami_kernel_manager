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

	local cpubus_list=()
	for dir in $cpubus_path/*; do
		if [ -d $dir ]; then
			cpubus_list+=($(basename $dir))
		fi
	done

	local cpubus_selected=$(fzf_select "${cpubus_list[@]}" "Select CPU Bus Component: ")
	unset cpubus_list

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
		echo -e "\e[30;48;2;254;228;208m Origami Kernel Manager ${VERSION}$(printf '%*s' $((LINE - 30)) '')\033[0m"
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
		echo -e "$(printf '─%.0s' $(seq 1 $LINE))\n"
		echo -e "\e[38;2;254;228;208m[] $cpubus_selected Bus control\033[0m"

		tput civis

		case $(fzy_select "Set max freq\nSet min freq\nBack to main menu" "") in
		"Set max freq") qcom_cpubus_set_freq max $cpubus_selected ;;
		"Set min freq") qcom_cpubus_set_freq min $cpubus_selected ;;
		"Back to main menu") break ;;
		esac
	done
}
