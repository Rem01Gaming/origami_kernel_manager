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

source /data/data/com.termux/files/usr/share/origami-kernel/utils/dram/mtk_dram.sh
source /data/data/com.termux/files/usr/share/origami-kernel/utils/dram/dram_devfreq.sh

dram_menu() {
	if [ ! -z $dram_devfreq_path ]; then
		dram_devfreq_menu
	elif [ ! -z $mtk_dram_path ]; then
		mtk_dram_menu
	else
		echo -e "\n[-] Interface (sysfs or procfs) of your DRAM is not supported"
		echo "[*] Hit enter to back to main menu"
		read -r -s
		clear && return 0
	fi
}
