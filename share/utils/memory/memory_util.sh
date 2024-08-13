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

memory_drop_cache() {
	if [[ $1 == "-exec" ]]; then
		local selected=$2
	else
		local selected=$(fzf_select "0 1 2 3" "Memory drop cache mode: ")
		command2db vm.drop_cache "memory_drop_cache -exec $selected" FALSE
	fi
	echo $selected >/proc/sys/vm/drop_caches
}

memory_swappiness() {
	if [[ $1 == "-exec" ]]; then
		apply $2 /proc/sys/vm/swappiness
	else
		menu_value_tune "Swappiness\ndetermines how often the operating system swaps data from RAM to the swap space on the disk." /proc/sys/vm/swappiness 200 0 1
		command2db vm.swappiness "memory_swappiness -exec $number" FALSE
	fi
}

memory_min_free_kbytes() {
	if [[ $1 == "-exec" ]]; then
		apply $2 /proc/sys/vm/min_free_kbytes
	else
		menu_value_tune "Minimum amount of free memory\nminimum amount of free memory (in kilobytes) that should always be available to the system." /proc/sys/vm/min_free_kbytes 22520 128 8
		command2db vm.min_free_kbytes "memory_min_free_kbytes -exec $number" FALSE
	fi
}

memory_extra_free_kbytes() {
	if [[ $1 == "-exec" ]]; then
		apply $2 /proc/sys/vm/extra_free_kbytes
	else
		menu_value_tune "Extra free kbytes\nadditional buffer of free memory (in kilobytes) reserved for critical system tasks." /proc/sys/vm/extra_free_kbytes 100520 128 24
		command2db vm.extra_free_kbytes "memory_extra_free_kbytes -exec $number" FALSE
	fi
}

memory_vfs_cache_pressure() {
	if [[ $1 == "-exec" ]]; then
		apply $2 /proc/sys/vm/vfs_cache_pressure
	else
		menu_value_tune "VFS Cache pressure\naggressively the system reclaims memory used for file system metadata." /proc/sys/vm/vfs_cache_pressure 1024 8 2
		command2db vm.vfs_cache_pressure "memory_vfs_cache_pressure -exec $number" FALSE
	fi
}

memory_overcommit_ratio() {
	if [[ $1 == "-exec" ]]; then
		apply $2 /proc/sys/vm/overcommit_ratio
	else
		menu_value_tune "Overcommit ratio\ninfluences the system's willingness to allocate more memory than physically available." /proc/sys/vm/overcommit_ratio 100 0 1
		command2db vm.overcommit_ratio "memory_overcommit_ratio -exec $number" FALSE
	fi
}

memory_dirty_ratio() {
	if [[ $1 == "-exec" ]]; then
		apply $2 /proc/sys/vm/dirty_ratio
	else
		menu_value_tune "Dirty ratio\nmaximum percentage of system memory that can be filled with "dirty" pages." /proc/sys/vm/dirty_ratio 100 0 1
		command2db vm.dirty_ratio "memory_dirty_ratio -exec $number" FALSE
	fi
}

memory_dirty_background_ratio() {
	if [[ $1 == "-exec" ]]; then
		apply $2 /proc/sys/vm/dirty_background_ratio
	else
		menu_value_tune "Dirty background ratio\nmaximum percentage of system memory that can be filled with "dirty" pages before the background process starts writing them to the disk." /proc/sys/vm/dirty_background_ratio 100 0 1
		command2db vm.dirty_background_ratio "memory_dirty_background_ratio -exec $number" FALSE
	fi
}

memory_dirty_writeback_centisecs() {
	if [[ $1 == "-exec" ]]; then
		apply $2 /proc/sys/vm/dirty_writeback_centisecs
	else
		menu_value_tune "Dirty writeback centisecs\ndetermines the interval in centiseconds between background processes checking and writing "dirty" data (modified but unsaved) to the disk." /proc/sys/vm/dirty_writeback_centisecs 10000 10 10
		command2db vm.dirty_writeback_centisecs "memory_dirty_writeback_centisecs -exec $number" FALSE
	fi
}

memory_dirty_expire_centisecs() {
	if [[ $1 == "-exec" ]]; then
		apply $2 /proc/sys/vm/dirty_expire_centisecs
	else
		menu_value_tune "Dirty expire centisecs\nmaximum age in centiseconds for "dirty" pages (modified but unsaved data) in the system." /proc/sys/vm/dirty_expire_centisecs 10000 10 10
		command2db vm.dirty_expire_centisecs "memory_dirty_expire_centisecs -exec $number" FALSE
	fi
}

laptop_mode() {
	if [[ $1 == "-exec" ]]; then
		local selected=$2
	else
		local selected=$(fzf_select "0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15" "Laptop mode: ")
		command2db vm.laptop_mode "laptop_mode -exec $selected" FALSE
	fi
	apply $selected /proc/sys/vm/laptop_mode
}

oom_kill_alloc() {
	if [[ $1 == "-exec" ]]; then
		local selected=$2
	else
		local selected=$(fzf_select "Yes No" "Kill allocating task: ")
		command2db vm.oom_kill_allocating_task "oom_kill_alloc -exec $selected" FALSE
	fi
	case $selected in
	Yes) apply 1 /proc/sys/vm/oom_kill_allocating_task ;;
	No) apply 0 /proc/sys/vm/oom_kill_allocating_task ;;
	esac
}

slmk_minfree() {
	if [[ $1 == "-exec" ]]; then
		apply $2 /sys/module/simple_lmk/parameters/slmk_minfree
	else
		menu_value_tune "Simple LMK minfree\nfree at least this much memory per reclaim." /sys/module/simple_lmk/parameters/slmk_minfree 512 8 2
		command2db simple_lmk.minfree "slmk_minfree -exec $number" FALSE
	fi
}

slmk_timeout() {
	if [[ $1 == "-exec" ]]; then
		apply $2 /sys/module/simple_lmk/parameters/slmk_timeout
	else
		menu_value_tune "Simple LMK timeout\nwait until all of the victims it kills have their memory freed." /sys/module/simple_lmk/parameters/slmk_timeout 1000 50 2
		command2db simple_lmk.timeout "slmk_timeout -exec $number" FALSE
	fi
}

memory_menu() {
	while true; do
		unset_headvar
		options="Memory drop cache\nSwappiness\nMinimum amount of free memory\nExtra free kbytes\nVFS Cache pressure\nOvercommit ratio\nDirty ratio\nDirty background ratio\nDirty writeback centisecs\nDirty expire centisecs\nKill allocating task\nLaptop mode\n"

		if [ -d /sys/kernel/mm/lru_gen ]; then
			header_info=("[] MGLRU mode: $(cat /sys/kernel/mm/lru_gen)")
			options="${options}MGLRU mode\nMGLRU time-to-live\n"
		fi

		if [ -d /sys/module/simple_lmk ]; then
			options="${options}Simple LMK minfree\nSimple LMK timeout\n"
		fi

		clear
		echo -e "\e[30;48;2;254;228;208m Origami Kernel Manager ${VERSION}$(printf '%*s' $((LINE - 30)) '')\033[0m"
		echo -e "\e[38;2;254;228;208m"
		echo -e "    _________      [] Memory Total: $(sed -n 1p /proc/meminfo | awk '{print $2}') kB" | cut -c 1-${LINE}
		echo -e "   /        /\\     [] Laptop mode: $(cat /proc/sys/vm/laptop_mode)"
		echo -e "  /        /  \\    [] Swappiness: $(cat /proc/sys/vm/swappiness)%"
		echo -e " /        /    \\   [] Dirty Ratio: $(cat /proc/sys/vm/dirty_ratio)%"
		echo -e "/________/      \\  ${header_info[0]}"
		echo -e "\\        \\      /  ${header_info[2]}"
		echo -e " \\        \\    /   ${header_info[3]}"
		echo -e "  \\        \\  /    ${header_info[4]}"
		echo -e "   \\________\\/     ${header_info[5]}"
		echo -e "\n//////////////"
		echo -e "$(printf '─%.0s' $(seq 1 $LINE))\n"
		echo -e "[] Memory Settings\033[0m"

		tput civis
		unset header_info

		case $(fzy_select "$options\nBack to main menu" "") in
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
		"Back to main menu") break ;;
		esac

		unset options
	done
}
