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

mtk_cpufreq_cci_mode() {
	if [[ $1 == "-exec" ]]; then
		local selected=$2
	else
		local selected=$(fzf_select "Normal Performance" "Mediatek CPU CCI mode: ")
		command2db cpu.mtk.cci_mode "mtk_cpufreq_cci_mode -exec $selected" FALSE
	fi

	case $selected in
	Performance) apply 1 /proc/cpufreq/cpufreq_cci_mode ;;
	Normal) apply 0 /proc/cpufreq/cpufreq_cci_mode ;;
	esac
}

mtk_cpufreq_power_mode() {
	if [[ $1 == "-exec" ]]; then
		local selected=$2
	else
		local selected=$(fzf_select "Normal Low-power Make Performance" "Mediatek CPU Power mode: ")
		command2db cpu.mtk.power_mode "mtk_cpufreq_power_mode -exec $selected" FALSE
	fi

	case $selected in
	Performance) apply 3 /proc/cpufreq/cpufreq_power_mode ;;
	Low-power) apply 1 /proc/cpufreq/cpufreq_power_mode ;;
	Make) apply 2 /proc/cpufreq/cpufreq_power_mode ;;
	Normal) apply 0 /proc/cpufreq/cpufreq_power_mode ;;
	esac
}

mtk_ppm_policy() {
	if [[ $1 == "-exec" ]]; then
		if [[ $2 == "policy" ]]; then
			apply "$3 $4" /proc/ppm/policy_status
		else
			apply $2 /proc/ppm/enabled
		fi
	else
		tput cuu 1
		echo -e "\e[38;2;254;228;208m[] Performance and Power Management Menu\033[0m"

		while true; do
			case $(cat /proc/ppm/enabled | awk '{print $3}') in
			"enabled") local selected=$(fzy_select "PPM $(awk '{print $3}' /proc/ppm/enabled)\n \n$(grep 'PPM_' /proc/ppm/policy_status)\n \nBack to the main menu" "") ;;
			"disabled") local selected=$(fzy_select "PPM $(awk '{print $3}' /proc/ppm/enabled)\n \nBack to the main menu" "") ;;
			esac

			case $selected in
			"Back to the main menu") break ;;
			"PPM enabled" | "PPM disabled")
				case "$(awk '{print $3}' /proc/ppm/enabled)" in
				enabled)
					apply 0 /proc/ppm/enabled
					command2db cpu.mtk.enable_ppm "mtk_ppm_policy -exec 0" FALSE
					;;
				disabled)
					apply 1 /proc/ppm/enabled
					command2db cpu.mtk.enable_ppm "mtk_ppm_policy -exec 1" FALSE
					;;
				esac
				;;
			" ") ;;
			*)
				idx=$(echo "$selected" | awk '{print $1}' | awk -F'[][]' '{print $2}')
				current_status=$(echo $selected | awk '{print $3}')

				if [[ $current_status == *enabled* ]]; then
					new_status=0
				else
					new_status=1
				fi

				apply "$idx $new_status" /proc/ppm/policy_status
				command2db cpu.mtk.ppm_policy$idx "mtk_ppm_policy -exec policy $idx $new_status" FALSE
				;;
			esac
			unset options
		done
	fi
}

mtk_cpu_volt_offset() {
	if [[ $1 == "-exec" ]]; then
		local offset=$2
		local selected=$3
		apply $offset /proc/eem/$selected/eem_offset
	else
		local path=()
		for dir in /proc/eem/EEM_DET_*; do
			if [[ $dir != *GPU* ]] && [ -f $dir/eem_offset ]; then
				path+=($(basename $dir))
			fi
		done
		local selected=$(fzf_select "$(echo ${path[@]})" "Select CPU Part to voltage offset: ")
		menu_value_tune "Offset Voltage for CPU $selected\nOffset will take original voltage from Operating Performance Point (OPP) and add or subtract the given voltage, you can use it for Overvolting or Undervolting.\nOne tick is equal to 6,25mV." /proc/eem/$selected/eem_offset 50 -50 1
		local offset=$number
		command2db cpu.mtk.volt_offset "mtk_cpu_volt_offset -exec $offset $selected" TRUE
		unset path
	fi
}

mtk_sched_boost() {
	if [[ $1 == "-exec" ]]; then
		local selected=$2
	else
		local selected=$(fzf_select "Disabled Foreground Boost-all" "Mediatek sched boost: ")
		command2db cpu.mtk.sched_boost "mtk_sched_boost -exec $selected" FALSE
	fi

	case $selected in
	Disabled) apply 0 /sys/devices/system/cpu/sched/sched_boost ;;
	Foreground) apply 1 /sys/devices/system/cpu/sched/sched_boost ;;
	Boost-all) apply 2 /sys/devices/system/cpu/sched/sched_boost ;;
	esac
}
