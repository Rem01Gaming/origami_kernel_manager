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

if [[ $soc == "Mediatek" ]]; then
	source /data/data/com.termux/files/usr/share/origami-kernel/utils/memory/mtk_dram.sh
fi

memory_drop_cache() {
	echo $(fzf_select "0 1 2 3" "Memory drop cache mode: ") >/proc/sys/vm/drop_caches
}

memory_swappiness() {
	menu_value_tune "Swappiness\ndetermines how often the operating system swaps data from RAM to the swap space on the disk." /proc/sys/vm/swappiness 200 0 1
}

memory_min_free_kbytes() {
	menu_value_tune "Minimum amount of free memory\nminimum amount of free memory (in kilobytes) that should always be available to the system." /proc/sys/vm/min_free_kbytes 22520 128 8
}

memory_extra_free_kbytes() {
	menu_value_tune "Extra free kbytes\nadditional buffer of free memory (in kilobytes) reserved for critical system tasks." /proc/sys/vm/extra_free_kbytes 100520 128 24
}

memory_vfs_cache_pressure() {
	menu_value_tune "VFS Cache pressure\naggressively the system reclaims memory used for file system metadata." /proc/sys/vm/vfs_cache_pressure 1024 8 2
}

memory_overcommit_ratio() {
	menu_value_tune "Overcommit ratio\ninfluences the system's willingness to allocate more memory than physically available." /proc/sys/vm/overcommit_ratio 100 0 1
}

memory_dirty_ratio() {
	menu_value_tune "Dirty ratio\nmaximum percentage of system memory that can be filled with "dirty" pages." /proc/sys/vm/dirty_ratio 100 0 1
}

memory_dirty_background_ratio() {
	menu_value_tune "Dirty background ratio\nmaximum percentage of system memory that can be filled with "dirty" pages before the background process starts writing them to the disk." /proc/sys/vm/dirty_background_ratio 100 0 1
}

memory_dirty_writeback_centisecs() {
	menu_value_tune "Dirty writeback centisecs\ndetermines the interval in centiseconds between background processes checking and writing "dirty" data (modified but unsaved) to the disk." /proc/sys/vm/dirty_writeback_centisecs 10000 10 10
}

memory_dirty_expire_centisecs() {
	menu_value_tune "Dirty expire centisecs\nmaximum age in centiseconds for "dirty" pages (modified but unsaved data) in the system." /proc/sys/vm/dirty_expire_centisecs 10000 10 10
}

laptop_mode() {
	echo $(fzf_select "0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15" "Laptop mode: ") >/proc/sys/vm/laptop_mode
}

oom_kill_alloc() {
	case $(fzf_select "Yes No" "Kill allocating task: ") in
	Yes) echo 1 >/proc/sys/vm/oom_kill_allocating_task ;;
	No) echo 0 >/proc/sys/vm/oom_kill_allocating_task ;;
	esac
}

slmk_minfree() {
	menu_value_tune "Simple LMK minfree\nfree at least this much memory per reclaim." /sys/module/simple_lmk/parameters/slmk_minfree 512 8 2
}

slmk_timeout() {
	menu_value_tune "Simple LMK timeout\nwait until all of the victims it kills have their memory freed." /sys/module/simple_lmk/parameters/slmk_timeout 1000 50 2
}

memory_menu() {
	while true; do
		memory_menu_options="Memory drop cache\nSwappiness\nMinimum amount of free memory\nExtra free kbytes\nVFS Cache pressure\nOvercommit ratio\nDirty ratio\nDirty background ratio\nDirty writeback centisecs\nDirty expire centisecs\nKill allocating task\nLaptop mode\nForce DRAM to maximum freq\n"

		if [ -d /sys/kernel/mm/lru_gen ]; then
			memory_menu_info="[] MGLRU mode: $(cat /sys/kernel/mm/lru_gen)\n"
			memory_menu_options="${memory_menu_options}MGLRU mode\nMGLRU time-to-live\n"
		fi

		if [ -d /sys/module/simple_lmk ]; then
			memory_menu_options="${memory_menu_options}Simple LMK minfree\nSimple LMK timeout\n"
		fi

		if [[ $soc == "Mediatek" ]]; then
			memory_menu_options="${memory_menu_options}MTK DRAM Control\n"
		fi

		clear
		echo -e "\e[30;48;2;254;228;208;38;2;0;0;0m Origami Kernel Manager ${VERSION}$(yes " " | sed $((LINE - 30))'q' | tr -d '\n')\033[0m"
		echo -e "\e[38;2;254;228;208m"
		echo -e "    _________      [] Memory Total: $(sed -n 1p /proc/meminfo | awk '{print $2}') kB" | cut -c 1-${LINE}
		echo -e "   /        /\\     [] Laptop mode: $(cat /proc/sys/vm/laptop_mode)"
		echo -e "  /        /  \\    [] Swappiness: $(cat /proc/sys/vm/swappiness)%"
		echo -e " /        /    \\   [] Dirty Ratio: $(cat /proc/sys/vm/dirty_ratio)%"
		echo -e "/________/      \\  $(echo "$memory_menu_info" | awk -F '//' '{print $1}')"
		echo -e "\\        \\      /  $(echo "$memory_menu_info" | awk -F '//' '{print $2}')"
		echo -e " \\        \\    /   $(echo "$memory_menu_info" | awk -F '//' '{print $3}')"
		echo -e "  \\        \\  /    $(echo "$memory_menu_info" | awk -F '//' '{print $4}')"
		echo -e "   \\________\\/     $(echo "$memory_menu_info" | awk -F '//' '{print $5}')"
		echo -e "\n//////////////"
		echo -e "$(yes "─" | sed ${LINE}'q' | tr -d '\n')\n"
		echo -e "[] Memory Settings\033[0m"

		tput civis

		case $(fzy_select "$(echo -e "$memory_menu_options")\nBack to main menu" "") in
		"MTK DRAM Control") mtk_dram_menu ;;
		"Memory drop cache") memory_drop_cache ;;
		"Swappiness") memory_swappiness ;;
		"Minimum amount of free memory") memory_min_free_kbytes ;;
		"Extra free kbytes") memory_extra_free_kbytes ;;
		"VFS Cache pressure") memory_vfs_cache_pressure ;;
		"Overcommit ratio") memory_overcommit_ratio ;;
		"Dirty ratio") memory_dirty_ratio ;;
		"Dirty background ratio") memory_dirty_background_ratio ;;
		"Dirty writeback centisecs") memory_dirty_writeback_centisecs ;;
		"Dirty expire centisecs") memory_dirty_expire_centisecs ;;
		"Kill allocating task") oom_kill_alloc ;;
		"Laptop mode") laptop_mode ;;
		"Simple LMK minfree") slmk_minfree ;;
		"Simple LMK timeout") slmk_timeout ;;
		"Back to main menu") clear && main_menu ;;
		esac
	done
}
