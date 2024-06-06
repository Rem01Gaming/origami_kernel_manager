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

mtk_gpufreqv2_lock_freq() {
	local freq=$(fzf_select "$gpu_available_freqs" "Set frequency for GPU (NO DVFS): ")
	local voltage=$(cat /proc/gpufreqv2/gpu_working_opp_table | awk -v freq="$freq" '$0 ~ freq {gsub(/.*, volt: /, ""); gsub(/,.*/, ""); print}')
	apply "$freq $voltage" /proc/gpufreqv2/fix_custom_freq_volt
}

mtk_gpufreqv2_lock_volt() {
	if [[ $(cat /proc/gpufreqv2/fix_custom_freq_volt) == *disabled* ]]; then
		echo -e "\n\033[38;5;196merror:\033[0m Set fixed freq first !"
		read -r -s
		return 1
	fi
	apply "$(cat /proc/gpufreqv2/fix_custom_freq_volt | awk '{print $4}')" "$(fzf_select "$(cat /proc/gpufreqv2/gpu_working_opp_table | awk '{print $5}' | sed 's/,//g' | sort -n | awk '!seen[$0]++ {print}')" "Select GPU voltage: ")" /proc/gpufreq/gpufreq_fixed_freq_volt
}

mtk_gpufreqv2_reset_dvfs() {
	apply "0 0" /proc/gpufreqv2/fix_custom_freq_volt
}

mtk_gpufreqv2_menu() {
	gpu_available_freqs="$(cat /proc/gpufreqv2/gpu_working_opp_table | awk '{print $3}' | sed 's/,//g' | sort -n)"

	while true; do
		gpu_max_freq="$(cat /sys/module/ged/parameters/gpu_cust_upbound_freq)"
		gpu_min_freq="$(cat /sys/module/ged/parameters/gpu_cust_boost_freq)"

		clear
		echo -e "\e[30;48;2;254;228;208;38;2;0;0;0m Origami Kernel Manager ${VERSION}$(yes " " | sed $((LINE - 30))'q' | tr -d '\n')\033[0m"
		echo -e "\e[38;2;254;228;208m"
		echo -e "    _________      [] GPU: ${gpu}" | cut -c 1-${LINE}
		echo -e "   /        /\\     [] GPU Scalling freq: ${gpu_min_freq}KHz - ${gpu_max_freq}KHz" | cut -c 1-${LINE}
		echo -e "  /        /  \\    [] Fixed freq & volt: $(if [ $(cat /proc/gpufreqv2/fix_custom_freq_volt | awk '{print $2}') == "fix" ]; then echo "Disabled"; else echo "Enabled"; fi)"
		echo -e " /        /    \\   [] GPU DVFS: $(cat /sys/module/ged/parameters/gpu_dvfs_enable)"
		echo -e "/________/      \\  [ϟ] GED Boosting: $(cat /sys/module/ged/parameters/ged_boost_enable)"
		echo -e '\        \      /  '
		echo -e ' \        \    /   '
		echo -e '  \        \  /    '
		echo -e '   \________\/     '
		echo -e "\n//////////////"
		echo -e "$(yes "─" | sed ${LINE}'q' | tr -d '\n')\n"
		echo -e "[] GPU Control\033[0m"

		tput civis

		case $(fzy_select "Set max freq\nSet min freq\nLock freq (NO DVFS)\nLock voltage (NO DVFS)\nReset DVFS\nGED GPU DVFS\nGED Boost\nGED GPU boost\nBack to main menu" "") in
		"Set max freq") ged_max_freq ;;
		"Set min freq") ged_min_freq ;;
		"Lock freq (NO DVFS)") mtk_gpufreqv2_lock_freq ;;
		"Lock voltage (NO DVFS)") mtk_gpufreqv2_lock_volt ;;
		"Reset DVFS") mtk_gpufreqv2_reset_dvfs ;;
		"GED GPU DVFS") mtk_ged_dvfs ;;
		"GED Boost") mtk_ged_boost ;;
		"GED GPU boost") mtk_ged_gpu_boost ;;
		"Back to main menu") clear && return 0 ;;
		esac
	done
}
