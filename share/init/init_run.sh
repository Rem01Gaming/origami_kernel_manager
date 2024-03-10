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

# CPU info
export chipset=$(grep "Hardware" /proc/cpuinfo | uniq | cut -d ':' -f 2 | sed 's/^[ \t]*//')

if [ -z "$chipset" ]; then
	export chipset=$(getprop "ro.hardware")
fi

case $chipset in
*mt* | *MT*) export soc=Mediatek ;;
*sm* | *qcom* | *SM* | *QCOM*) export soc=Qualcomm ;;
*exynos*) export soc=Exynos ;;
*) export soc=unknown ;;
esac

cores=$(($(nproc --all) - 1))

policy_folders=($(ls -d /sys/devices/system/cpu/cpufreq/policy* | sort -V))
export nr_clusters=$(echo ${#policy_folders[@]})

if [ $nr_clusters -gt 1 ]; then
	export is_big_little=1
	export cluster0=$(cat $(echo ${policy_folders[0]})/related_cpus 2>/dev/null)
	export cluster1=$(cat $(echo ${policy_folders[1]})/related_cpus 2>/dev/null)
	export cluster2=$(cat $(echo ${policy_folders[2]})/related_cpus 2>/dev/null)
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

# Kernel version
export kernelverc=$(uname -r | cut -d'.' -f1,2 | sed 's/\.//')
