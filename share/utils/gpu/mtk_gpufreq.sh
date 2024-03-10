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

source /data/data/com.termux/files/usr/share/origami-kernel/utils/gpu/mtk_ged.sh

mtk_gpufreq_freq_set() {
	local freq=$(fzf_select "0 $gpu_available_freqs" "Set frequency for GPU (NO DVFS): ")
	echo $freq >$gpu_freq_path 2>/dev/null
}

mtk_gpu_power_limit() {
	while true; do
		options=(
			"Ignore GPU Overcurrent protect $(sed -n 2p /proc/gpufreq/gpufreq_power_limited | awk '{print $3}')"
			"Ignore GPU Low batt percentage limit $(sed -n 3p /proc/gpufreq/gpufreq_power_limited | awk '{print $3}')"
			"Ignore GPU Low battery limit $(sed -n 4p /proc/gpufreq/gpufreq_power_limited | awk '{print $3}')"
			"Ignore GPU Thermal protect $(sed -n 5p /proc/gpufreq/gpufreq_power_limited | awk '{print $3}')"
			"Ignore GPU Power Budget limitter $(sed -n 6p /proc/gpufreq/gpufreq_power_limited | awk '{print $3}')"
			" "
			"Back to main menu"
		)

		selected=$(printf '%s\n' "${options[@]}" | fzy -l 15 -p "")
		state=$(echo $selected | grep -oE '[0-9]+')

		case "$selected" in
		*"Ignore GPU Overcurrent protect"*) echo "ignore_batt_oc $((1 - state))" >/proc/gpufreq/gpufreq_power_limited ;;
		*"Ignore GPU Low batt percentage limit"*) echo "ignore_batt_percent $((1 - state))" >/proc/gpufreq/gpufreq_power_limited ;;
		*"Ignore GPU Low battery limit"*) echo "ignore_low_batt $((1 - state))" >/proc/gpufreq/gpufreq_power_limited ;;
		*"Ignore GPU Thermal protect"*) echo "ignore_thermal_protect $((1 - state))" >/proc/gpufreq/gpufreq_power_limited ;;
		*"Ignore GPU Power Budget limitter"*) echo "ignore_pbm_limited $((1 - state))" >/proc/gpufreq/gpufreq_power_limited ;;
		"Back to main menu") break ;;
		esac
	done
}

mtk_gpufreq_menu() {
	gpu_available_freqs="$(cat /proc/gpufreq/gpufreq_opp_dump | grep -o 'freq = [0-9]*' | sed 's/freq = //' | sort -n)"
	gpu_max_freq="$(cat /proc/gpufreq/gpufreq_opp_dump | grep -o 'freq = [0-9]*' | sed 's/freq = //' | sort -n | head -n 1)"
	gpu_min_freq="$(cat /proc/gpufreq/gpufreq_opp_dump | grep -o 'freq = [0-9]*' | sed 's/freq = //' | sort -nr | head -n 1)"
	gpu_freq_path="/proc/gpufreq/gpufreq_opp_freq"

	while true; do
		clear
		echo -e "\e[30;48;2;254;228;208;38;2;0;0;0m Origami Kernel Manager ${VERSION}$(yes " " | sed $((LINE - 30))'q' | tr -d '\n')\033[0m"
		echo -e "\e[38;2;254;228;208m"
		echo -e "    _________      [] GPU: ${gpu}" | cut -c 1-${LINE}
		echo -e "   /        /\\     [] GPU Scalling freq: $gpu_min_freq - $gpu_max_freq"
		echo -e "  /        /  \\    [] Fixed freq: $(sed -n 1p /proc/gpufreq/gpufreq_opp_freq | awk '{print $5}')"
		echo -e " /        /    \\   [] GPU DVFS: $(cat /sys/module/ged/parameters/gpu_dvfs_enable)"
		echo -e "/________/      \\  [ϟ] GED Boosting: $(cat /sys/module/ged/parameters/ged_boost_enable)"
		echo -e "\\        \\      /  [ϟ] GED Game mode: $(cat /sys/module/ged/parameters/gx_game_mode)"
		echo -e ' \        \    /   '
		echo -e '  \        \  /    '
		echo -e '   \________\/     '
		echo -e "\n//////////////"
		echo -e "$(yes "─" | sed ${LINE}'q' | tr -d '\n')\n"
		echo -e "[] GPU Control\033[0m"

		tput civis

		case $(fzy_select "Set freq (NO DVFS)\nGED GPU DVFS\nGED Boost\nGED Extra Boost\nGED GPU boost\nGED Game Mode\nGPU Power limit settings\nBack to main menu" "") in
		"Set freq (NO DVFS)") mtk_gpufreq_freq_set ;;
		"GED GPU DVFS") mtk_ged_dvfs ;;
		"GED Boost") mtk_ged_boost ;;
		"GED Extra Boost") mtk_ged_extra_boost ;;
		"GED GPU boost") mtk_ged_gpu_boost ;;
		"GED Game Mode") mtk_ged_game_mode ;;
		"GPU Power limit settings") mtk_gpu_power_limit ;;
		"Back to main menu") clear && main_menu ;;
		esac
	done
}
