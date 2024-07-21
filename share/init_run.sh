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

echo -e "\33[2K\r\033[1;34m[*] Gathering information about your hardware...\033[0m"

# CPU info
chipset=$(grep "Hardware" /proc/cpuinfo | uniq | cut -d ':' -f 2 | sed 's/^[ \t]*//')

if [ -z "$chipset" ]; then
	chipset=$(getprop "ro.board.platform")
fi

case $chipset in
*mt* | *MT*) soc=Mediatek ;;
*sm* | *qcom* | *SM* | *QCOM* | *Qualcomm*) soc=Qualcomm ;;
*exynos*) soc=Exynos ;;
*gs*) soc=Google ;;
*) soc=unknown ;;
esac

cores=$(($(nproc --all) - 1))

policy_folders=($(ls -d /sys/devices/system/cpu/cpufreq/policy* | sort -V))
nr_clusters=${#policy_folders[@]}

if [ $nr_clusters -gt 1 ]; then
	is_big_little=1
	cluster0=$(cat $(echo ${policy_folders[0]})/related_cpus 2>/dev/null)
	cluster1=$(cat $(echo ${policy_folders[1]})/related_cpus 2>/dev/null)
	cluster2=$(cat $(echo ${policy_folders[2]})/related_cpus 2>/dev/null)

	if [ $(cat /sys/devices/system/cpu/cpufreq/policy$(echo ${cluster0} | awk '{print $1}')/scaling_available_frequencies | awk '{print $1}') -gt $(cat /sys/devices/system/cpu/cpufreq/policy$(echo ${cluster1} | awk '{print $1}')/scaling_available_frequencies | awk '{print $1}') ]; then
		# If the frequency of cluster0 (little cpu) is bigger than cluster1 (big cpu)
		# then there's a chance if it's swapped due to kernel issues
		# correct it.
		cluster0=$(cat $(echo ${policy_folders[1]})/related_cpus 2>/dev/null)
		cluster1=$(cat $(echo ${policy_folders[0]})/related_cpus 2>/dev/null)
	fi
fi

# GPU info
gpu=$(dumpsys SurfaceFlinger | grep GLES | awk -F ': ' '{print $2}' | tr -d '\n')

gpu_devfreq_paths_array=(
	"$(find /sys/class/devfreq/ -type d -iname "*.mali" -print -quit 2>/dev/null)"
	"$(find /sys/devices/platform/ -type d -iname "*.mali" -print -quit 2>/dev/null)"
	"/sys/class/devfreq/dfrgx"
	"/sys/devices/platform/dfrgx/devfreq/dfrgx"
	"/sys/class/kgsl/kgsl-3d0/devfreq"
	"$(find /sys/class/devfreq/ -type d -iname "*kgsl-3d0" -print -quit 2>/dev/null)"
)

for path in ${gpu_devfreq_paths_array[@]}; do
	if [ ! -z $path] && [ -d $path ] && [ -f $path/available_governors ]; then
		gpu_devfreq_path="$path"
		break
	fi
done

if [ -d /proc/gpufreq ]; then
	gpu_node_id=1
elif [ -d /proc/gpufreqv2 ]; then
	gpu_node_id=2
elif [ -d $gpu_devfreq_path ]; then # Compensate for Mediatek devices. Mali devfreq interface still exists on Mediatek devices, it just don't fucking work because they injected gpufreq and ged trash into mali driver.
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
fi

# DRAM info
# Check for Devfreq DRAM path
dram_devfreq_paths_array=(
	"/sys/class/devfreq/mtk-dvfsrc-devfreq"
	"$(find /sys/devices/platform/soc/ -type d -iname "*.dvfsrc" -print -quit 2>/dev/null)/mtk-dvfsrc-devfreq/devfreq/mtk-dvfsrc-devfreq"
	"/sys/class/devfreq/soc:qcom,cpu-llcc-ddr-bw"
)

for path in ${dram_devfreq_paths_array[@]}; do
	if [ ! -z $path] && [ -d $path ] && [ -f $path/governor ]; then
		dram_devfreq_path="$path"
		break
	fi
done

# Check for Qualcomm DRAM path
if [[ $soc == "Qualcomm" ]] && [ -z $dram_devfreq_path ]; then
	dram_qcom_paths_array=(
		"/sys/devices/system/cpu/bus_dcvs/DDR"
		"/sys/devices/system/cpu/bus_dcvs/DDRQOS"
	)

	for path in ${dram_qcom_paths_array[@]}; do
		if [ -d $path ]; then
			qcom_dram_path="$path"
			break
		fi
	done
fi

# Check for Mediatek's DRAM implementation
if [[ $soc == "Mediatek" ]] && [ -z $dram_devfreq_path ]; then
	mtk_dram_paths_array=(
		"$(find /sys/devices/platform/ -type d -iname "*.dvfsrc" -print -quit 2>/dev/null)/helio-dvfsrc"
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
