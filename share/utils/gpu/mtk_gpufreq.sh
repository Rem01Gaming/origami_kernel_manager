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

source $PREFIX/share/origami-kernel/utils/gpu/mtk_ged.sh

mtk_gpufreq_lock_freq() {
	local freq=$(fzf_select "0 $gpu_available_freqs" "Set frequency for GPU (NO DVFS): ")
	apply $freq $gpu_freq_path
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
		*"Ignore GPU Overcurrent protect"*) apply "ignore_batt_oc $((1 - state))" /proc/gpufreq/gpufreq_power_limited ;;
		*"Ignore GPU Low batt percentage limit"*) apply "ignore_batt_percent $((1 - state))" /proc/gpufreq/gpufreq_power_limited ;;
		*"Ignore GPU Low battery limit"*) apply "ignore_low_batt $((1 - state))" /proc/gpufreq/gpufreq_power_limited ;;
		*"Ignore GPU Thermal protect"*) apply "ignore_thermal_protect $((1 - state))" /proc/gpufreq/gpufreq_power_limited ;;
		*"Ignore GPU Power Budget limitter"*) apply "ignore_pbm_limited $((1 - state))" /proc/gpufreq/gpufreq_power_limited ;;
		"Back to main menu") break ;;
		esac
	done
}

mtk_gpufreq_menu() {
	gpu_available_freqs="$(grep -o 'freq = [0-9]*' /proc/gpufreq/gpufreq_opp_dump | sed 's/freq = //' | sort -nu)"
	gpu_freq_path="/proc/gpufreq/gpufreq_opp_freq"

	while true; do
		unset_headvar
		header_info=(
			"[] GPU: ${gpu}"
			"[] GPU Scalling freq: $(cat /sys/module/ged/parameters/gpu_cust_boost_freq)KHz - $(cat /sys/module/ged/parameters/gpu_cust_upbound_freq)KHz"
			"[] Fixed freq: $(sed -n 1p /proc/gpufreq/gpufreq_opp_freq | awk '{print $5}')"
			"[] GPU DVFS: $(cat /sys/module/ged/parameters/gpu_dvfs_enable)"
			"[ϟ] GED Boosting: $(cat /sys/module/ged/parameters/ged_boost_enable)"
			"[ϟ] GED Game mode: $(cat /sys/module/ged/parameters/gx_game_mode)"
		)

		if [ -f /proc/gpufreq/gpufreq_power_limited ]; then
			options="GPU Power limit settings"
		fi

		header "GPU Control"
		selected="$(fzy_select "Set max freq\nSet min freq\nLock freq (NO DVFS)\nGED GPU DVFS\nGED Boost\nGED Extra Boost\nGED GPU boost\nGED Game Mode\n$options\nBack to main menu" "")"

		case "$selected" in
		"Set max freq") ged_max_freq ;;
		"Set min freq") ged_min_freq ;;
		"Lock freq (NO DVFS)") mtk_gpufreq_lock_freq ;;
		"GED GPU DVFS") mtk_ged_dvfs ;;
		"GED Boost") mtk_ged_boost ;;
		"GED Extra Boost") mtk_ged_extra_boost ;;
		"GED GPU boost") mtk_ged_gpu_boost ;;
		"GED Game Mode") mtk_ged_game_mode ;;
		"GPU Power limit settings") mtk_gpu_power_limit ;;
		"Back to main menu") break ;;
		esac
	done
}
