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

gpu_tegra_set_freq() {
	if [[ $1 == "-exec" ]]; then
		local freq=$2
		local max_min=$3
	else
		local max_min=$1
		local freq=$(fzf_select "$gpu_available_freqs" "Select $max_min freq: ")
		command2db gpu.tegra.${max_min}_freq "gpu_tegra_set_freq -exec $freq $max_min" FALSE
	fi
	case $max_min in
	max) local node_path=$gpu_max_freq_path ;;
	min) local node_path=$gpu_min_freq_path ;;
	esac
	apply $freq $node_path
}

gpu_tegra_menu() {
	gpu_available_freqs="$(cat /sys/kernel/tegra_gpu/gpu_available_rates)"
	gpu_min_freq_path="/sys/kernel/tegra_gpu/gpu_floor_rate"
	gpu_max_freq_path="/sys/kernel/tegra_gpu/gpu_cap_rate"

	while true; do
		unset_headvar
		header_info=(
			"[] GPU: ${gpu}"
			"[] GPU Scalling freq: $(cat $gpu_min_freq_path)KHz - $(cat $gpu_max_freq_path)KHz"
		)

		header "GPU Control"
		selected="$(fzy_select "Set max freq\nSet min freq\nBack to main menu" "")"

		case "$selected" in
		"Set max freq") gpu_tegra_set_freq max ;;
		"Set min freq") gpu_tegra_set_freq min ;;
		"Back to main menu") break ;;
		esac
	done
}
