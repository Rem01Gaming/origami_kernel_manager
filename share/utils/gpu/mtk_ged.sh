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

ged_max_freq() {
	if [[ $1 == "-exec" ]]; then
		local index=$2
	else
		if [[ $gpu_node_id == 1 ]]; then
			local index=$(grep "$(fzf_select "$gpu_available_freqs" "Maximum GPU Frequency: ")" /proc/gpufreq/gpufreq_opp_dump | awk '{print $1}')
		elif [[ $gpu_node_id == 2 ]]; then
			local index=$(grep "$(fzf_select "$gpu_available_freqs" "Maximum GPU Frequency: ")" /proc/gpufreqv2/gpu_working_opp_table | awk '{print $1}')
		fi
		local index=${index:1:-1}
		command2db gpu.ged.max_freq "ged_max_freq -exec $index" FALSE
	fi

	apply $index /sys/kernel/ged/hal/custom_upbound_gpu_freq
}

ged_min_freq() {
	if [[ $1 == "-exec" ]]; then
		local index=$2
	else
		if [[ $gpu_node_id == 1 ]]; then
			index=$(grep "$(fzf_select "$gpu_available_freqs" "Minimum GPU Frequency: ")" /proc/gpufreq/gpufreq_opp_dump | awk '{print $1}')
		elif [[ $gpu_node_id == 2 ]]; then
			index=$(grep "$(fzf_select "$gpu_available_freqs" "Minimum GPU Frequency: ")" /proc/gpufreqv2/gpu_working_opp_table | awk '{print $1}')
		fi
		local index=${index:1:-1}
		command2db gpu.ged.min_freq "ged_min_freq -exec $index" FALSE
	fi

	apply $index /sys/kernel/ged/hal/custom_boost_gpu_freq
}

mtk_ged_dvfs() {
	if [[ $1 == "-exec" ]]; then
		local selected=$2
	else
		local selected=$(fzf_select "Enable Disable" "GPU DVFS:  ")
		command2db gpu.ged.dvfs "mtk_ged_dvfs -exec $selected" FALSE
	fi
	case $selected in
	Enable) apply 1 /sys/module/ged/parameters/gpu_dvfs_enable ;;
	Disable) apply 0 /sys/module/ged/parameters/gpu_dvfs_enable ;;
	esac
}

mtk_ged_boost() {
	if [[ $1 == "-exec" ]]; then
		local selected=$2
	else
		local selected=$(fzf_select "Enable Disable" "GED Boosting: ")
		command2db gpu.ged.boost "mtk_ged_boost -exec $selceted" FALSE
	fi
	case $selected in
	Enable) apply 1 /sys/module/ged/parameters/ged_boost_enable ;;
	Disable) apply 0 /sys/module/ged/parameters/ged_boost_enable ;;
	esac
}

mtk_ged_extra_boost() {
	if [[ $1 == "-exec" ]]; then
		local selected=$2
	else
		local selected=$(fzf_select "Enable Disable" "GED Boost extra: ")
		command2db gpu.ged.extra_boost "mtk_ged_extra_boost -exec $selected" FALSE
	fi
	case $selected in
	Enable) apply 1 /sys/module/ged/parameters/boost_extra ;;
	Disable) apply 0 /sys/module/ged/parameters/boost_extra ;;
	esac
}

mtk_ged_gpu_boost() {
	if [[ $1 == "-exec" ]]; then
		local selected=$2
	else
		local selected=$(fzf_select "Enable Disable" "GED GPU Boost: ")
		command2db gpu.ged.gpu_boost "mtk_ged_gpu_boost -exec $selected" FALSE
	fi
	case $selected in
	Enable) apply 1 /sys/module/ged/parameters/boost_gpu_enable ;;
	Disable) apply 0 /sys/module/ged/parameters/boost_gpu_enable ;;
	esac
}

mtk_ged_game_mode() {
	if [[ $1 == "-exec" ]]; then
		local selected=$2
	else
		local selected=$(fzf_select "Enable Disable" "GED Game mode: ")
		command2db gpu.ged.game_mode "mtk_ged_game_mode -exec $selceted" FALSE
	fi
	case $selected in
	Enable) apply 1 /sys/module/ged/parameters/gx_game_mode ;;
	Disable) apply 0 /sys/module/ged/parameters/gx_game_mode ;;
	esac
}

mtk_ged_dcs_mode() {
	if [[ $1 == "-exec" ]]; then
		local selected=$2
	else
		local selected=$(fzf_select "Enable Disable" "DCS Policy mode: ")
		command2db gpu.ged.dcs_mode "mtk_ged_dcs_mode -exec $selceted" FALSE
	fi
	case $selected in
	Enable) apply 1 /sys/kernel/ged/hal/dcs_mode ;;
	Disable) apply 0 /sys/kernel/ged/hal/dcs_mode ;;
	esac
}
