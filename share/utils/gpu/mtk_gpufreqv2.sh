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

source $PREFIX/share/origami-kernel/utils/gpu/mtk_ged.sh

mtk_gpufreqv2_lock_freq() {
	local freq=$(fzf_select "$gpu_available_freqs" "Set frequency for GPU (NO DVFS): ")
	local index=$(grep $freq /proc/gpufreqv2/gpu_working_opp_table | awk -F'[][]' '{print $2}')
	apply "$index" /proc/gpufreqv2/fix_target_opp_index
}

mtk_gpufreqv2_reset_dvfs() {
	apply "-1" /proc/gpufreqv2/fix_target_opp_index
}

mtk_gpufreqv2_menu() {
	gpu_available_freqs="$(awk '{print $3}' /proc/gpufreqv2/gpu_working_opp_table | sed 's/,//g' | sort -n)"

	while true; do
		unset_headvar
		header_info=(
			"[] GPU: ${gpu}"
			"[] GPU Scalling freq: $(cat /sys/module/ged/parameters/gpu_cust_boost_freq)KHz - $(cat /sys/module/ged/parameters/gpu_cust_upbound_freq)KHz"
			"[] Fixed freq & volt: $(if [[ $(awk '{print $2}' /proc/gpufreqv2/fix_target_opp_index) == "fix" ]]; then echo "Enabled"; else echo "Disabled"; fi)"
			"[] GPU DVFS: $(cat /sys/module/ged/parameters/gpu_dvfs_enable)"
			"[ϟ] GED Boosting: $(cat /sys/module/ged/parameters/ged_boost_enable)"
		)

		header "GPU Control"
		selected="$(fzy_select "Set max freq\nSet min freq\nLock freq (NO DVFS)\nReset DVFS\nGED GPU DVFS\nGED Boost\nGED GPU boost\nBack to main menu" "")"

		case "$selected" in
		"Set max freq") ged_max_freq ;;
		"Set min freq") ged_min_freq ;;
		"Lock freq (NO DVFS)") mtk_gpufreqv2_lock_freq ;;
		"Reset DVFS") mtk_gpufreqv2_reset_dvfs ;;
		"GED GPU DVFS") mtk_ged_dvfs ;;
		"GED Boost") mtk_ged_boost ;;
		"GED GPU boost") mtk_ged_gpu_boost ;;
		"Back to main menu") break ;;
		esac
	done
}
