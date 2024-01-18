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

if [[ $chipset == *MT* || $chipset == *mt* ]]; then
	export soc=Mediatek
elif [[ $chipset == *MSM* || $chipset == *QCOM* || $chipset == *msm* || $chipset == *qcom* ]]; then
	export soc=Qualcomm
elif [[ $chipset == *exynos* ]]; then
	export soc=Exynos
else
	export soc=unknown
fi

cores=$(($(nproc --all) - 1 ))

shopt -s nullglob
policy_folders=(/sys/devices/system/cpu/cpufreq/policy*/)
export nr_clusters=$(echo ${#policy_folders[@]})

if [ $nr_clusters -gt 1 ]; then
export is_big_little=1
cores_dir=($(ls -d /sys/devices/system/cpu/cpufreq/policy* | sort -V))
export cluster0=$(cat $(echo ${cores_dir[0]})/related_cpus 2>/dev/null)
export cluster1=$(cat $(echo ${cores_dir[1]})/related_cpus 2>/dev/null)
export cluster2=$(cat $(echo ${cores_dir[2]})/related_cpus 2>/dev/null)
fi

# GPU info
gpu=$(dumpsys SurfaceFlinger | grep GLES | awk -F ': ' '{print $2}')

if [ ! -d /sys/kernel/gpu ] && [ ! -d /proc/gpufreq ] && [ ! -d /proc/gpufreqv2 ]; then
is_gpu_unsupported=1
fi
