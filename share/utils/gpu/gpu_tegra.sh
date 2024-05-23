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
	case $1 in
	max) local node_path=$gpu_max_freq_path ;;
	min) local node_path=$gpu_min_freq_path ;;
	esac
	apply $(fzf_select "$gpu_available_freqs" "Select ${1} freq: ") $node_path
}

gpu_tegra_menu() {
	gpu_available_freqs="$(cat /sys/kernel/tegra_gpu/gpu_available_rates)"
	gpu_min_freq_path="/sys/kernel/tegra_gpu/gpu_floor_rate"
	gpu_max_freq_path="/sys/kernel/tegra_gpu/gpu_cap_rate"

	while true; do
		clear
		echo -e "\e[30;48;2;254;228;208;38;2;0;0;0m Origami Kernel Manager ${VERSION}$(yes " " | sed $((LINE - 30))'q' | tr -d '\n')\033[0m"
		echo -e "\e[38;2;254;228;208m"
		echo -e "    _________      [] GPU: ${gpu}" | cut -c 1-${LINE}
		echo -e "   /        /\\     [] GPU Scalling freq: $(cat $gpu_min_freq_path) - $(cat $gpu_max_freq_path)"
		echo -e '  /        /  \    '
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

		case $(fzy_select "Set max freq\nSet min freq\nBack to main menu" "") in
		"Set max freq") gpu_tegra_set_freq max ;;
		"Set min freq") gpu_tegra_set_freq min ;;
		"Back to main menu") clear && return 0 ;;
		esac
	done
}
