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

gpu_tensor_set_freq() {
	if [[ $1 == "-exec" ]]; then
		local freq=$2
		local max_min=$3
	else
		local max_min=$1
		local freq=$(fzf_select "$(cat ${gpu_devfreq_path}/available_frequencies)" "Select $max_min freq: ")
		command2db gpu.tensor.${max_min}_freq "gpu_tensor_set_freq -exec $freq $max_min" FALSE
	fi
	apply $freq $gpu_devfreq_path/scaling_${max_min}_freq
}

gpu_tensor_set_gov() {
	if [[ $1 == "-exec" ]]; then
		local selected_gov=$2
	else
		local selected_gov=$(fzf_select "$(cat $gpu_tensor_path/available_governors)" "Select Governor: ")
		command2db gpu.tensor.governor "gpu_tensor_set_gov -exec $selected_gov" FALSE
	fi
	apply $selected_gov $gpu_tensor_path/governor
}

gpu_tensor_menu() {
	while true; do
		unset_headvar
		header_info=(
			"[] GPU: ${gpu}"
			"[] GPU Scalling freq: $(cat ${gpu_devfreq_path}/max_freq)KHz - $(cat ${gpu_devfreq_path}/min_freq)KHz"
			"[] GPU Governor: $(cat ${gpu_devfreq_path}/governor)"
		)
		options="Set max freq\nSet min freq\nSet Governor\n"

		clear
		echo -e "\e[30;48;2;254;228;208;38;2;0;0;0m Origami Kernel Manager ${VERSION}$(yes " " | sed $((LINE - 30))'q' | tr -d '\n')\033[0m"
		echo -e "\e[38;2;254;228;208m"
		echo -e "    _________      ${header_info[0]}" | cut -c 1-${LINE}
		echo -e "   /        /\\     ${header_info[1]}" | cut -c 1-${LINE}
		echo -e "  /        /  \\    ${header_info[2]}"
		echo -e " /        /    \   ${header_info[3]}"
		echo -e "/________/      \  ${header_info[4]}"
		echo -e "\        \      /  ${header_info[5]}"
		echo -e " \        \    /   ${header_info[6]}"
		echo -e "  \        \  /    ${header_info[7]}"
		echo -e "   \________\/     ${header_info[8]}"
		echo -e "\n//////////////"
		echo -e "$(yes "─" | sed ${LINE}'q' | tr -d '\n')\n"
		echo -e "[] GPU Control\033[0m"

		tput civis

		case $(fzy_select "$options\nBack to main menu" "") in
		"Set max freq") gpu_tensor_set_freq max ;;
		"Set min freq") gpu_tensor_set_freq min ;;
		"Set Governor") gpu_tensor_set_gov ;;
		"Back to main menu") break ;;
		esac
	done
}
