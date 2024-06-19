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

source /data/data/com.termux/files/usr/share/origami-kernel/utils/gpu/simple_gpu_algo.sh
source /data/data/com.termux/files/usr/share/origami-kernel/utils/gpu/adreno_idler.sh

gpu_devfreq_set_freq() {
	if [[ $1 == "-exec" ]]; then
		local freq=$2
		local max_min=$3
	else
		local max_min=$1
		local freq=$(fzf_select "$(cat ${gpu_devfreq_path}/available_frequencies)" "Select $max_min freq: ")
		command2db gpu.generic.${max_min}_freq "gpu_devfreq_set_freq -exec $freq $max_min" FALSE
	fi
	apply $freq ${gpu_devfreq_path}/${max_min}_freq
}

gpu_devfreq_set_gov() {
	if [[ $1 == "-exec" ]]; then
		local selected_gov=$2
	else
		local selected_gov=$(fzf_select "$(cat ${gpu_devfreq_path}/available_governors)" "Select Governor: ")
		command2db gpu.devfreq.governor "gpu_devfreq_set_gov -exec $selected_gov" FALSE
	fi
	apply ${gpu_devfreq_path}/governor
}

gpu_devfreq_menu() {
	while true; do
		header_info=(
			"[] GPU: ${gpu}"
			"[] GPU Scalling freq: $(cat ${gpu_devfreq_path}/max_freq)KHz - $(cat ${gpu_devfreq_path}/min_freq)KHz"
			"[] GPU Governor: $(cat ${gpu_devfreq_path}/governor)"
		)
		options="Set max freq\nSet min freq\nSet Governor\n"

		if [ -d /sys/module/simple_gpu_algorithm ]; then
			options="${options}Enable Simple GPU Algorithm\nSimple GPU Laziness\nSimple GPU Ramp threshold\n"
		fi

		if [ -d /sys/module/adreno_idler/parameters ]; then
			options="${options}Enable Adreno Idler\nAdreno Idle Workload\nAdreno Wait Idle\nAdreno Idle Differential\n"
			header_info+=(
				"[] Adreno Idler: $(cat /sys/module/adreno_idler/parameters/adreno_idler_active)"
				"[] Adreno Idle Workload: $(cat /sys/module/adreno_idler/parameters/adreno_idler_idleworkload)"
			)
		fi

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
		unset header_info

		case $(fzy_select "$options\nBack to main menu" "") in
		"Set max freq") gpu_devfreq_set_freq max ;;
		"Set min freq") gpu_devfreq_set_freq min ;;
		"Set Governor") gpu_devfreq_set_gov ;;
		"Enable Simple GPU Algorithm") simple_gpu_switch ;;
		"Simple GPU Laziness") simple_gpu_laziness ;;
		"Simple GPU Ramp threshold") simple_gpu_ramp_threshold ;;
		"Enable Adreno Idler") adreno_idler_switch ;;
		"Adreno Idle Workload") adreno_idler_workload ;;
		"Adreno Wait Idle") adreno_idler_wait ;;
		"Adreno Idle Differential") adreno_idler_down_diferential ;;
		"Back to main menu") break ;;
		esac

		unset options
	done
}
