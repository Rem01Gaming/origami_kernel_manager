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

gpu_qcom_kgsl2_set_max_freq() {
	if [[ $1 == "-exec" ]]; then
		local freq=$2
	else
		local freq=$(fzf_select "$gpu_available_freqs" "Select max freq: ")
		command2db gpu.qcom.kgsl2.max_freq "gpu_qcom_kgsl2_set_max_freq -exec $freq" FALSE
	fi
	apply $freq $gpu_max_freq_path
}

gpu_qcom_kgsl2_set_gov() {
	if [[ $1 == "-exec" ]]; then
		local selected_gov=$2
	else
		local selected_gov=$(fzf_select "$gpu_available_governors" "Select Governor: ")
		command2db gpu.qcom.kgsl2.governor "gpu_qcom_kgsl2_set_gov -exec $selected_gov" FALSE
	fi
	apply $selected_gov $gpu_governor_path
}

gpu_qcom_kgsl2_menu() {
	gpu_available_freqs="$(cat /sys/devices/platform/kgsl-2d0.0/kgsl/kgsl-2d0/gpu_available_frequencies)"
	gpu_min_freq="$(cat /sys/devices/platform/kgsl-2d0.0/kgsl/kgsl-2d0/gpu_available_frequencies | head -n 1)"
	gpu_max_freq_path="/sys/devices/platform/kgsl-2d0.0/kgsl/kgsl-2d0/max_gpuclk"
	gpu_available_governors="performance powersave ondemand simple conservative"
	gpu_governor_path="/sys/devices/platform/kgsl-2d0.0/kgsl/kgsl-2d0/pwrscale/trustzone/governor"

	while true; do
		unset_headvar
		header_info=(
			"[] GPU: ${gpu}"
			"[] GPU Scalling freq: $(cat $gpu_min_freq)KHz - $(cat $gpu_max_freq_path)KHz"
			"[] GPU Governor: $(cat $gpu_governor_path)"
		)

		header "GPU Control"
		selected="$(fzy_select "Set max freq\nSet min freq\nSet Governor\nBack to main menu" "")"

		case "$selected" in
		"Set max freq") gpu_qcom_kgsl2_set_max_freq ;;
		"Set Governor") gpu_qcom_kgsl2_set_gov ;;
		"Back to main menu") break ;;
		esac
	done
}
