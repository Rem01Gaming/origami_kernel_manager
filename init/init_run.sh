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

if [ -f /sys/devices/system/cpu/cputopo/is_big_little ]; then
	export is_big_little=1

	# Get the number of clusters
	nr_clusters=$(cat /sys/devices/system/cpu/cputopo/nr_clusters)

    # Associative array to store CPUs in clusters
    declare -A clusters

    # Loop through each CPU core
    for cpu_dir in /sys/devices/system/cpu/cpu[0-${cores}]*; do
	    core_id=$(basename "$cpu_dir")
	    chmod 0644 ${cpu_dir}/online
	    echo 1 > ${cpu_dir}/online
	    if [ -f "$cpu_dir/topology/physical_package_id" ]; then
		    core_cluster=$(chmod +r "$cpu_dir/topology/physical_package_id" && cat "$cpu_dir/topology/physical_package_id")
		    clusters[$core_cluster]+=" $core_id"
	    else
		    echo "error: Cannot determine cluster for $core_id" && exit 1
	    fi
    done

    export cluster0=${clusters[0]}
    export cluster1=${clusters[1]}
    if [[ $nr_clusters == 3 ]]; then
	    export cluster2=${clusters[2]}
    fi
else
	export is_big_little=0
fi

# GPU info
gpu=$(dumpsys SurfaceFlinger | grep GLES | awk -F ': ' '{print $2}')

if [ ! -d /sys/kernel/gpu ] && [ ! -d /proc/gpufreq ]; then
is_gpu_unsupported=1
fi
