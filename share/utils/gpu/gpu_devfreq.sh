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
# Copyright (C) 2023-2024 Rem01Gaming

source $PREFIX/share/origami-kernel/utils/gpu/simple_gpu_algo.sh
source $PREFIX/share/origami-kernel/utils/gpu/adreno_idler.sh

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
	apply $selected_gov ${gpu_devfreq_path}/governor
}

gpu_devfreq_menu() {
	while true; do
		unset_headvar
		header_info=(
			"[] GPU: ${gpu}"
			"[] GPU Scalling freq: $(cat ${gpu_devfreq_path}/min_freq)KHz - $(cat ${gpu_devfreq_path}/max_freq)KHz"
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

		header "GPU Control"
		selected="$(fzy_select "$options\nBack to main menu" "")"

		case "$selected" in
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
	done
}
