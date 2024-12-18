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

# CPU info
chipset=$(grep "Hardware" /proc/cpuinfo | uniq | cut -d ':' -f 2 | sed 's/^[ \t]*//')
if [ -z "$chipset" ]; then
	chipset=$(grep "model\sname" /proc/cpuinfo | uniq | cut -d ':' -f 2 | sed 's/^[ \t]*//')
fi
if [ -z "$chipset" ] && [ $ANDROID ]; then
	chipset="$(getprop ro.board.platform) $(getprop ro.hardware)"
fi

case "$chipset" in
*mt* | *MT*) soc=Mediatek ;;
*sm* | *qcom* | *SM* | *QCOM* | *Qualcomm*) soc=Qualcomm ;;
*exynos*) soc=Exynos ;;
*Unisoc* | *unisoc*) soc=Unisoc ;;
*gs*) soc=Google ;;
*intel* | *Intel*) soc=Intel ;;
*) soc=unknown ;;
esac

if [[ $soc == unknown ]] && [ -f /sys/devices/soc0/machine ] && [ ! -d /sys/kernel/gpu ]; then
	soc=Qualcomm
fi

chipset="$(echo $chipset | tr ' ' '\n' | sort -u | tr '\n' ' ')"

cores=$(($(nproc --all) - 1))
ARCH=$(uname -m)

# Normalize architecture names
case "$ARCH" in
x86_64) ARCH="x86_64" ;;               # 64-bit x86
i686 | i386) ARCH="x86" ;;             # 32-bit x86
aarch64) ARCH="arm64" ;;               # 64-bit ARM
armv7* | armv8* | armhf) ARCH="arm" ;; # 32-bit ARM
*) ARCH="unknown" ;;                   # Default case if unknown
esac

if [[ "$ARCH" == *arm* ]]; then
	policy_folders=($(ls -d /sys/devices/system/cpu/cpufreq/policy* | sort -V))
	nr_clusters=${#policy_folders[@]}

	if [ $nr_clusters -gt 1 ]; then
		is_big_little=1
		cluster0=$(cat ${policy_folders[0]}/related_cpus 2>/dev/null)
		cluster1=$(cat ${policy_folders[1]}/related_cpus 2>/dev/null)
		cluster2=$(cat ${policy_folders[2]}/related_cpus 2>/dev/null)

		if [ $(cat /sys/devices/system/cpu/cpufreq/policy$(echo ${cluster0} | awk '{print $1}')/scaling_available_frequencies | awk '{print $1}') -gt $(cat /sys/devices/system/cpu/cpufreq/policy$(echo ${cluster1} | awk '{print $1}')/scaling_available_frequencies | awk '{print $1}') ]; then
			# If the frequency of cluster0 (little cpu) is bigger than cluster1 (big cpu)
			# then there's a chance if it's swapped, correct it.
			cluster0=$(cat ${policy_folders[1]}/related_cpus 2>/dev/null)
			cluster1=$(cat ${policy_folders[0]}/related_cpus 2>/dev/null)
		fi
	fi
else
	is_big_little=0
fi

# GPU info
gpu_devfreq_paths_array=(
	"$(find /sys/class/devfreq/ -iname "*.mali" -print -quit 2>/dev/null)"
	"$(find /sys/class/devfreq/ -iname "*.gpu" -print -quit 2>/dev/null)"
	"/sys/class/devfreq/dfrgx"
	"/sys/devices/platform/dfrgx/devfreq/dfrgx"
	"/sys/class/kgsl/kgsl-3d0/devfreq"
	"$(find /sys/class/devfreq/ -iname "*kgsl-3d0" -print -quit 2>/dev/null)"
)

for path in ${gpu_devfreq_paths_array[@]}; do
	if [ ! -z $path ] && [ -d $path ] && [ -f $path/available_governors ]; then
		gpu_devfreq_path="$path"
		break
	fi
done

gpu_mali_path="$(find /sys/devices/platform/ -iname "*.mali" -print -quit 2>/dev/null)"

if [ -f $gpu_mali_path/scaling_max_freq ]; then
	gpu_node_id=8
	gpu=$(cat $gpu_mali_path/gpuinfo)
elif [ -d /proc/gpufreq ]; then
	gpu_node_id=1
	[ -f $gpu_mali_path/gpuinfo ] && gpu=$(cat $gpu_mali_path/gpuinfo)
elif [ -d /proc/gpufreqv2 ]; then
	gpu_node_id=2
	[ -f $gpu_mali_path/gpuinfo ] && gpu=$(cat $gpu_mali_path/gpuinfo)
elif [ ! -z $gpu_devfreq_path ] && [ -d $gpu_devfreq_path ]; then # Compensate for Mediatek devices. Mali devfreq interface still exists on Mediatek devices, it just don't fucking work because they injected gpufreq and ged trash into mali driver.
	gpu_node_id=0
elif [ -d /sys/devices/platform/kgsl-2d0.0/kgsl ]; then
	gpu_node_id=3
elif [ -d /sys/devices/platform/kgsl-3d0.0/kgsl ]; then
	gpu_node_id=4
elif [ -d /sys/devices/platform/omap/pvrsrvkm.0 ]; then
	gpu_node_id=5
elif [ -d /sys/kernel/tegra_gpu ]; then
	gpu_node_id=6
elif [ -d /sys/kernel/gpu ]; then
	gpu_node_id=7
	gpu=$(cat /sys/kernel/gpu/gpu_model)
fi

[ -z "$gpu" ] && [ $ANDROID ] && [[ ! $soc == "Mediatek" ]] && gpu=$(dumpsys SurfaceFlinger | grep GLES | awk -F ': ' '{print $2}' | tr -d '\n')

if [ -z "$gpu" ]; then
	gpu="Unknown"
	[ ! -z $gpu_node_id ] && gpu="Unknown ($gpu_node_id)"
fi

# DRAM info
# Check for Devfreq DRAM path
dram_devfreq_paths_array=(
	"/sys/class/devfreq/mtk-dvfsrc-devfreq"
	"$(find /sys/devices/platform/soc/ -iname "*.dvfsrc" -print -quit 2>/dev/null)/mtk-dvfsrc-devfreq/devfreq/mtk-dvfsrc-devfreq"
	"/sys/class/devfreq/soc:qcom,cpu-llcc-ddr-bw"
)

for path in ${dram_devfreq_paths_array[@]}; do
	if [ ! -z $path ] && [ -d $path ] && [ -f $path/governor ]; then
		dram_devfreq_path="$path"
		break
	fi
done

# Check for Mediatek's DRAM implementation
if [[ $soc == "Mediatek" ]] && [ -z $dram_devfreq_path ]; then
	mtk_dram_paths_array=(
		"$(find /sys/devices/platform/ -iname "*.dvfsrc" -print -quit 2>/dev/null)/helio-dvfsrc"
		"/sys/kernel/helio-dvfsrc"
	)

	for path in ${mtk_dram_paths_array[@]}; do
		if [ -d $path ]; then
			mtk_dram_path="$path"
			break
		fi
	done

	mtk_dram_opp_table_paths_array=(
		"${mtk_dram_path}/dvfsrc_opp_table"
	)
	mtk_dram_opp_req_paths_array=(
		"${mtk_dram_path}/dvfsrc_req_ddr_opp"
		"${mtk_dram_path}/dvfsrc_force_vcore_dvfs_opp"
	)

	for path in ${mtk_dram_opp_table_paths_array[@]}; do
		if [ -f $path ]; then
			mtk_dram_opp_table_path="$path"
			break
		fi
	done

	for path in ${mtk_dram_opp_req_paths_array[@]}; do
		if [ -f $path ]; then
			mtk_dram_req_opp_path="$path"
			break
		fi
	done
fi

# DT2W
dt2w_path_search=(
	"/sys/touchpanel/double_tap"
	"/sys/class/sec/tsp/dt2w_enable"
	"/proc/touchpanel/double_tap_enable"
	"/proc/tp_gesture"
	"/sys/android_touch/doubletap2wake"
	"/sys/android_touch/doubletap_wake"
)

for path in ${dt2w_path_search[@]}; do
	if [ -f $path ]; then
		dt2w_path="$path"
		break
	fi
done
