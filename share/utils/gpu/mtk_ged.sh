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

ged_max_freq() {
	if [[ $gpu_node_id == 1 ]]; then
		index=$(grep "$(fzf_select "$gpu_available_freqs" "Maximum GPU Frequency: ")" /proc/gpufreq/gpufreq_opp_dump | awk '{print $1}')
	elif [[ $gpu_node_id == 2 ]]; then
		index=$(grep "$(fzf_select "$gpu_available_freqs" "Maximum GPU Frequency: ")" /proc/gpufreqv2/gpu_working_opp_table | awk '{print $1}')
	fi

	apply ${index:1:-1} /sys/kernel/ged/hal/custom_upbound_gpu_freq
}

ged_min_freq() {
	if [[ $gpu_node_id == 1 ]]; then
		index=$(grep "$(fzf_select "$gpu_available_freqs" "Maximum GPU Frequency: ")" /proc/gpufreq/gpufreq_opp_dump | awk '{print $1}')
	elif [[ $gpu_node_id == 2 ]]; then
		index=$(grep "$(fzf_select "$gpu_available_freqs" "Maximum GPU Frequency: ")" /proc/gpufreqv2/gpu_working_opp_table | awk '{print $1}')
	fi

	apply ${index:1:-1} /sys/kernel/ged/hal/custom_boost_gpu_freq
}

mtk_ged_dvfs() {
	case $(fzf_select "Enable Disable" "GPU DVFS:  ") in
	Enable) apply 1 /sys/module/ged/parameters/gpu_dvfs_enable ;;
	Disable) apply 0 /sys/module/ged/parameters/gpu_dvfs_enable ;;
	esac
}

mtk_ged_boost() {
	case $(fzf_select "Enable Disable" "GED Boosting: ") in
	Enable) apply 1 /sys/module/ged/parameters/ged_boost_enable ;;
	Disable) apply 0 /sys/module/ged/parameters/ged_boost_enable ;;
	esac
}

mtk_ged_extra_boost() {
	case $(fzf_select "Enable Disable" "GED Boost extra: ") in
	Enable) apply 1 /sys/module/ged/parameters/boost_extra ;;
	Disable) apply 0 /sys/module/ged/parameters/boost_extra ;;
	esac
}

mtk_ged_gpu_boost() {
	case $(fzf_select "Enable Disable" "GED GPU Boost: ") in
	Enable) apply 1 /sys/module/ged/parameters/boost_gpu_enable ;;
	Disable) apply 0 /sys/module/ged/parameters/boost_gpu_enable ;;
	esac
}

mtk_ged_game_mode() {
	case $(fzf_select "Enable Disable" "GED Game mode: ") in
	Enable) apply 1 /sys/module/ged/parameters/gx_game_mode ;;
	Disable) apply 0 /sys/module/ged/parameters/gx_game_mode ;;
	esac
}
