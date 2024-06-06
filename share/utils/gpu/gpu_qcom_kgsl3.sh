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

gpu_qcom_kgsl3_set_max_freq() {
	apply $(fzf_select "$gpu_available_freqs" "Select ${1} freq: ") $gpu_max_freq_path
}

gpu_qcom_kgsl3_set_gov() {
	apply $(fzf_select "$gpu_available_governors" "Select Governor: ") $gpu_governor_path
}

gpu_qcom_kgsl3_menu() {
	gpu_available_freqs="$(cat /sys/devices/platform/kgsl-3d0.0/kgsl/kgsl-3d0/gpu_available_frequencies)"
	gpu_min_freq="$(cat /sys/devices/platform/kgsl-2d0.0/kgsl/kgsl-2d0/gpu_available_frequencies | head -n 1)"
	gpu_max_freq_path="/sys/devices/platform/kgsl-3d0.0/kgsl/kgsl-3d0/max_gpuclk"
	gpu_available_governors="performance powersave ondemand simple conservative"
	gpu_governor_path="/sys/class/kgsl/kgsl-3d0/pwrscale/trustzone/governor"

	while true; do
		clear
		echo -e "\e[30;48;2;254;228;208;38;2;0;0;0m Origami Kernel Manager ${VERSION}$(yes " " | sed $((LINE - 30))'q' | tr -d '\n')\033[0m"
		echo -e "\e[38;2;254;228;208m"
		echo -e "    _________      [] GPU: ${gpu}" | cut -c 1-${LINE}
		echo -e "   /        /\\     [] GPU Scalling freq: $(cat $gpu_min_freq)KHz - $(cat $gpu_max_freq_path)KHz" | cut -c 1-${LINE}
		echo -e "  /        /  \\    [] GPU Governor: $(cat $gpu_governor_path)"
		echo -e ' /        /    \   '
		echo -e '/________/      \  '
		echo -e '\        \      /  '
		echo -e ' \        \    /   '
		echo -e '  \        \  /    '
		echo -e '   \________\/     '
		echo -e "\n//////////////"
		echo -e "$(yes "─" | sed ${LINE}'q' | tr -d '\n')\n"
		echo -e "[] GPU Control\033[0m"

		tput civis

		case $(fzy_select "Set max freq\nSet min freq\nSet Governor\nBack to main menu" "") in
		"Set max freq") gpu_qcom_kgsl3_set_max_freq ;;
		"Set Governor") gpu_qcom_kgsl3_set_gov ;;
		"Back to main menu") break ;;
		esac
	done
}
