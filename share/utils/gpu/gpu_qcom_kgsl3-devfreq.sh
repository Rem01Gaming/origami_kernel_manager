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

gpu_qcom_kgsl3-devfreq_set_freq() {
	local node_path="gpu_${1}_freq_path"
	local freq_selected="$(fzf_select "$gpu_available_freqs" "Select ${1} freq: ")"

	for path in $node_path; do
		echo $freq_selected >$path
	done
}

gpu_qcom_kgsl3-devfreq_set_gov() {
	echo $(fzf_select "$gpu_available_governors" "Select Governor: ") >$gpu_governor_path
}

gpu_qcom_kgsl3-devfreq_menu() {
	gpu_available_freqs="$(cat /sys/class/kgsl/kgsl-3d0/gpu_available_frequencies)"
	gpu_min_freq_path="/sys/class/kgsl/kgsl-3d0/devfreq/min_freq /sys/class/kgsl/kgsl-3d0/min_clock_mhz"
	gpu_max_freq_path="/sys/class/kgsl/kgsl-3d0/max_gpuclk"
	gpu_available_governors="$(cat /sys/class/kgsl/kgsl-3d0/devfreq/available_governors)"
	gpu_governor_path="/sys/class/kgsl/kgsl-3d0/devfreq/governor"

	gpu_menu_options="Set max freq\nSet min freq\nSet Governor\n"

	while true; do
		if [ -d /sys/module/simple_gpu_algorithm ]; then
			gpu_menu_options="${gpu_menu_options}Enable Simple GPU Algorithm\nSimple GPU Laziness\nSimple GPU Ramp threshold\n"
			gpu_menu_info="[] Simple GPU: $(cat /sys/module/simple_gpu_algorithm/parameters/simple_gpu_activate)//[] Simple GPU Laziness: $(cat /sys/module/simple_gpu_algorithm/parameters/simple_laziness)//[] Simple GPU Ramp threshold: $(cat /sys/module/simple_gpu_algorithm/parameters/simple_ramp_threshold)//"
		fi

		if [ -d /sys/module/adreno_idler/parameters ]; then
			gpu_menu_options="${gpu_menu_options}Enable Adreno Idler\nAdreno Idle Workload\nAdreno Wait Idle\nAdreno Idle Differential\n"
			gpu_menu_info="[] Adreno Idler: $(cat /sys/module/adreno_idler/parameters/adreno_idler_active)//[] Adreno Idle Workload: $(cat /sys/module/adreno_idler/parameters/adreno_idler_idleworkload)//"
		fi

		clear
		echo -e "\e[30;48;2;254;228;208;38;2;0;0;0m Origami Kernel Manager ${VERSION}$(yes " " | sed $((LINE - 30))"q" | tr -d "\n")\033[0m"
		echo -e "\e[38;2;254;228;208m"
		echo -e "    _________      [] GPU: ${gpu}" | cut -c 1-${LINE}
		echo -e "   /        /\\     [] GPU Scalling freq: $(cat $gpu_min_freq_path | head -n 1) - $(cat $gpu_max_freq_path)"
		echo -e "  /        /  \\    [] GPU Governor: $(cat $gpu_governor_path)"
		echo -e " /        /    \   $(echo "$gpu_menu_info" | awk -F "//" "{print $1}")"
		echo -e "/________/      \  $(echo "$gpu_menu_info" | awk -F "//" "{print $2}")"
		echo -e "\        \      /  $(echo "$gpu_menu_info" | awk -F "//" "{print $3}")"
		echo -e " \        \    /   $(echo "$gpu_menu_info" | awk -F "//" "{print $4}")"
		echo -e "  \        \  /    $(echo "$gpu_menu_info" | awk -F "//" "{print $5}")"
		echo -e "   \________\/     $(echo "$gpu_menu_info" | awk -F "//" "{print $6}")"
		echo -e "\n//////////////"
		echo -e "$(yes "─" | sed ${LINE}"q" | tr -d "\n")\n"
		echo -e "[] GPU Control\033[0m"

		tput civis

		case $(fzy_select "$(echo -e "$gpu_menu_options")\nBack to main menu" "") in
		"Set max freq") gpu_qcom_kgsl3-devfreq_set_freq max ;;
		"Set min freq") gpu_qcom_kgsl3-devfreq_set_freq min ;;
		"Set Governor") gpu_qcom_kgsl3-devfreq_set_gov ;;
		"Enable Simple GPU Algorithm") simple_gpu_switch ;;
		"Simple GPU Laziness") simple_gpu_laziness ;;
		"Simple GPU Ramp threshold") simple_gpu_ramp_threshold ;;
		"Enable Adreno Idler") adreno_idler_switch ;;
		"Adreno Idle Workload") adreno_idler_workload ;;
		"Adreno Wait Idle") adreno_idler_wait ;;
		"Adreno Idle Differential") adreno_idler_down_diferential ;;
		"Back to main menu") clear && return 0 ;;
		esac

		unset gpu_menu_info gpu_menu_options
	done
}
