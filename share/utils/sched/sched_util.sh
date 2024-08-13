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

sys_kernel="/proc/sys/kernel"

sched_param_tune() {
	if [[ $1 == "-exec" ]]; then
		apply "$3" "$2"
	else
		local param=$1
		local bool_param=(
			sched_big_task_rotation
			sched_child_runs_first
			sched_cstate_aware
			sched_isolation_hint
			sched_tunable_scaling
			sched_schedstats
			sched_use_walt_util_min
			sched_use_walt_task_util
		)

		if [[ "${bool_param[@]}" == *$param* ]]; then
			local selected=$(fzf_select "Enable Disable" "$param:  ")
			command2db scheduler.$1 "sched_param_tune -exec $param $selected" FALSE
			case $selected in
			Enable) apply "1" $sys_kernel/$param ;;
			Disable) apply "0" $sys_kernel/$param ;;
			esac
		else
			menu_value_tune "$param" $sys_kernel/$param 9999999 0 1
			command2db scheduler.$1 "sched_param_tune -exec $param $number" FALSE
		fi
	fi
}

sched_menu() {
	options="$(find /proc/sys/kernel/ -type f -name "sched_*" -exec basename {} \;)"
	while true; do
		unset header_info
		header_info=()

		if [ -f $sys_kernel/sched_big_task_rotation ]; then
			header_info+=("[] sched_big_task_rotation: $(cat $sys_kernel/sched_big_task_rotation)")
		fi

		if [ -f $sys_kernel/sched_child_runs_first ]; then
			header_info+=("[] sched_child_runs_first: $(cat $sys_kernel/sched_child_runs_first)")
		fi

		if [ -f $sys_kernel/sched_cstate_aware ]; then
			header_info+=("[] sched_cstate_aware: $(cat $sys_kernel/sched_cstate_aware)")
		fi

		if [ -f $sys_kernel/sched_isolation_hint ]; then
			header_info+=("[] sched_isolation_hint: $(cat $sys_kernel/sched_isolation_hint)")
		fi

		if [ -f $sys_kernel/sched_schedstats ]; then
			header_info+=("[] sched_schedstats: $(cat $sys_kernel/sched_schedstats)")
		fi

		if [ -f $sys_kernel/sched_tunable_scaling ]; then
			header_info+=("[] sched_tunable_scaling: $(cat $sys_kernel/sched_tunable_scaling)")
		fi

		clear
		echo -e "\e[30;48;2;254;228;208m Origami Kernel Manager ${VERSION}$(printf '%*s' $((LINE - 30)) '')\033[0m"
		echo -e "\e[38;2;254;228;208m"
		echo -e "    _________      ${header_info[0]}"
		echo -e "   /        /\\     ${header_info[1]}"
		echo -e "  /        /  \\    ${header_info[2]}"
		echo -e " /        /    \\   ${header_info[3]}"
		echo -e "/________/      \\  ${header_info[4]}"
		echo -e "\\        \\      /  ${header_info[5]}"
		echo -e " \\        \\    /   ${header_info[6]}"
		echo -e "  \\        \\  /    ${header_info[7]}"
		echo -e "   \\________\\/     ${header_info[8]}"
		echo -e "\n//////////////"
		echo -e "$(printf '─%.0s' $(seq 1 $LINE))\n"
		echo -e "[] Scheduler Settings\033[0m"

		tput civis

		selected="$(fzy_select "$options\nBack to main menu" "")"
		case $selected in
		"Back to main menu") break ;;
		*) sched_param_tune $selected ;;
		esac
	done
}
