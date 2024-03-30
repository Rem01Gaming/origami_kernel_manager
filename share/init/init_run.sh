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
	chipset=$(getprop "ro.hardware")
fi

case $chipset in
*mt* | *MT*) soc=Mediatek ;;
*sm* | *qcom* | *SM* | *QCOM* | *Qualcomm*) soc=Qualcomm ;;
*exynos*) soc=Exynos ;;
*) soc=unknown ;;
esac

cores=$(($(nproc --all) - 1))

policy_folders=($(ls -d /sys/devices/system/cpu/cpufreq/policy* | sort -V))
nr_clusters=$(echo ${#policy_folders[@]})

if [ $nr_clusters -gt 1 ]; then
	is_big_little=1
	cluster0=$(cat $(echo ${policy_folders[0]})/related_cpus 2>/dev/null)
	cluster1=$(cat $(echo ${policy_folders[1]})/related_cpus 2>/dev/null)
	cluster2=$(cat $(echo ${policy_folders[2]})/related_cpus 2>/dev/null)
fi

# GPU info
gpu=$(dumpsys SurfaceFlinger | grep GLES | awk -F ': ' '{print $2}' | tr -d '\n')

if [ -d /proc/gpufreq ]; then
	gpu_node_id=1
elif [ -d /proc/gpufreqv2 ]; then
	gpu_node_id=2
elif [ -d /sys/devices/platform/kgsl-2d0.0/kgsl ]; then
	gpu_node_id=3
elif [ -d /sys/devices/platform/kgsl-3d0.0/kgsl ]; then
	gpu_node_id=4
elif [ -d /sys/class/kgsl/kgsl-3d0 ]; then
	gpu_node_id=5
elif [ -d /sys/devices/platform/omap/pvrsrvkm.0 ]; then
	gpu_node_id=6
elif [ -d /sys/kernel/tegra_gpu ]; then
	gpu_node_id=7
elif [ -d /sys/devices/platform/dfrgx/devfreq ]; then
	gpu_node_id=8
elif [ -d /sys/kernel/gpu ]; then
	gpu_node_id=9
else
	is_gpu_unsupported=1
fi

# DRAM info

if [[ $soc == "Mediatek" ]]; then
	# Check for DRAM path, whatever it's devfreq or Mediatek's Gibberish.
	mtk_dram_devfreq_paths_array=(
		"/sys/class/devfreq/mtk-dvfsrc-devfreq"
		"/sys/devices/platform/soc/1c00f000.dvfsrc/mtk-dvfsrc-devfreq/devfreq/mtk-dvfsrc-devfreq"
	)

	for path in ${mtk_dram_devfreq_paths_array[@]}; do
		if [ -d $path ]; then
			mtk_dram_devfreq_path="$path"
			break
		fi
	done

	if [ -z $mtk_dram_devfreq_path ]; then
		mtk_dram_paths_array=(
			"/sys/devices/platform/10012000.dvfsrc/helio-dvfsrc"
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
fi
