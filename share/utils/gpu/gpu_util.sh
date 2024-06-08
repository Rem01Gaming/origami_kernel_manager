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

source /data/data/com.termux/files/usr/share/origami-kernel/utils/gpu/gpu_devfreq.sh
source /data/data/com.termux/files/usr/share/origami-kernel/utils/gpu/mtk_gpufreq.sh
source /data/data/com.termux/files/usr/share/origami-kernel/utils/gpu/mtk_gpufreqv2.sh
source /data/data/com.termux/files/usr/share/origami-kernel/utils/gpu/gpu_tegra.sh
source /data/data/com.termux/files/usr/share/origami-kernel/utils/gpu/gpu_omap.sh
source /data/data/com.termux/files/usr/share/origami-kernel/utils/gpu/gpu_qcom_kgsl2.sh
source /data/data/com.termux/files/usr/share/origami-kernel/utils/gpu/gpu_qcom_kgsl3.sh
source /data/data/com.termux/files/usr/share/origami-kernel/utils/gpu/gpu_qcom_kgsl3-devfreq.sh
source /data/data/com.termux/files/usr/share/origami-kernel/utils/gpu/gpu_powervr.sh
source /data/data/com.termux/files/usr/share/origami-kernel/utils/gpu/gpu_generic.sh

gpu_menu() {
	if [ -z $gpu_node_id ]; then
		echo -e "\n[-] Interface (sysfs or procfs) of your GPU is not supported"
		echo "[*] Hit enter to back to main menu"
		read -r -s
		clear && main_menu
	else
		case $gpu_node_id in
		0) gpu_devfreq_menu ;;
		1) mtk_gpufreq_menu ;;
		2) mtk_gpufreqv2_menu ;;
		3) gpu_qcom_kgsl2_menu ;;
		4) gpu_qcom_kgsl3_menu ;;
		5) gpu_qcom_kgsl3-devfreq_menu ;;
		6) gpu_omap_menu ;;
		7) gpu_tegra_menu ;;
		8) gpu_powervr_menu ;;
		9) gpu_generic_menu ;;
		esac
	fi
}
