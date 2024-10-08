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

		header "GPU Control"
		selected="$(fzy_select "Set max freq\nSet min freq\nSet Governor\nBack to main menu" "")"

		case "$selected" in
		"Set max freq") gpu_tensor_set_freq max ;;
		"Set min freq") gpu_tensor_set_freq min ;;
		"Set Governor") gpu_tensor_set_gov ;;
		"Back to main menu") break ;;
		esac
	done
}
