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

cpu_cluster_handle() {
	case $1 in
	little) cluster_need_set=0 ;;
	big) cluster_need_set=1 ;;
	prime) cluster_need_set=2 ;;
	esac

	case $cluster_need_set in
	0)
		first_cpu_oncluster=$(echo ${cluster0} | awk '{print $1}')
		cpus_cluster_selected=${cluster0}
		;;
	1)
		first_cpu_oncluster=$(echo ${cluster1} | awk '{print $1}')
		cpus_cluster_selected=${cluster1}
		;;
	2)
		first_cpu_oncluster=$(echo ${cluster2} | awk '{print $1}')
		cpus_cluster_selected=${cluster2}
		;;
	esac
}

cpu_set_gov() {
	if [ $is_big_little -eq 1 ]; then
		if [[ $1 == "-exec" ]]; then
			gov_selected=$2
			cluster_selected=$3
		else
			case $nr_clusters in
			2) cluster_selected=$(fzf_select "little big" "Select cpu cluster: ") ;;
			3) cluster_selected=$(fzf_select "little big prime" "Select cpu cluster: ") ;;
			esac
			local gov_selected=$(fzf_select "$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors)" "Select CPU Governor: ")
			command2db cpu.$cluster_selected.governor "cpu_set_gov -exec $gov_selected $cluster_selected" FALSE
		fi

		cpu_cluster_handle $cluster_selected

		apply $gov_selected /sys/devices/system/cpu/cpufreq/policy${first_cpu_oncluster}/scaling_governor
	else
		if [[ $1 == "-exec" ]]; then
			gov_selected=$2
		else
			local gov_selected=$(fzf_select "$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors)" "Select CPU Governor: ")
			command2db cpu.governor "cpu_set_gov -exec $gov_selected" FALSE
		fi

		for ((cpu = 0; cpu < cores; cpu++)); do
			cpu_dir="/sys/devices/system/cpu/cpu${cpu}"
			if [ -d "$cpu_dir" ]; then
				apply "$gov_selected" "${cpu_dir}/cpufreq/scaling_governor"
			fi
		done
	fi
}

cpu_set_freq() {
	if [[ $soc == Mediatek ]] && [ -d /proc/ppm ] && [[ $1 != "-exec" ]]; then
		if [[ "$(cat /proc/ppm/enabled)" != "ppm is enabled" ]]; then
			echo -e "\n[-] Enable Performance and Power Management First"
			echo "[*] Hit enter to back to main menu"
			read -r -s
			return 1
		elif [[ "$(cat /proc/ppm/policy_status | grep "PPM_POLICY_HARD_USER_LIMIT")" != *enabled* ]]; then
			echo -e "\n[-] Enable 'PPM_POLICY_HARD_USER_LIMIT' on Performance and Power Management First"
			echo "[*] Hit enter to back to main menu"
			read -r -s
			return 1
		fi
	fi

	if [ $is_big_little -eq 1 ]; then
		if [[ $1 == "-exec" ]]; then
			freq=$2
			cluster_selected=$3
			max_min=$4
		else
			case $nr_clusters in
			2) cluster_selected=$(fzf_select "little big" "Select cpu cluster: ") ;;
			3) cluster_selected=$(fzf_select "little big prime" "Select cpu cluster: ") ;;
			esac
			max_min=$1
			local freq=$(fzf_select "$(cat /sys/devices/system/cpu/cpufreq/policy${first_cpu_oncluster}/scaling_available_frequencies)" "Select $max_min CPU freq for $cluster_selected cluster: ")
			command2db cpu.$cluster_selected.${max_min}_freq "cpu_set_freq -exec $freq $cluster_selected $max_min" FALSE
		fi

		cpu_cluster_handle $cluster_selected

		if [[ $soc == Mediatek ]] && [ -d /proc/ppm ]; then
			apply "$cluster_need_set $freq" /proc/ppm/policy/hard_userlimit_${max_min}_cpu_freq
		else
			apply $freq /sys/devices/system/cpu/cpufreq/policy${first_cpu_oncluster}/scaling_${max_min}_freq
		fi
	else
		if [[ $1 == "-exec" ]]; then
			freq=$2
			max_min=$3
		else
			max_min=$1
			local freq=$(fzf_select "$(cat /sys/devices/system/cpu/cpufreq/policy0/scaling_available_frequencies)" "Select $max_min CPU frequency: ")
			command2db cpu.${max_min}_freq "cpu_set_freq -exec $freq $max_min" FALSE
		fi

		if [[ $soc == Mediatek ]] && [ -d /proc/ppm ]; then
			apply "0 $freq" /proc/ppm/policy/hard_userlimit_${max_min}_cpu_freq
		else
			for ((cpu = 0; cpu < cores; cpu++)); do
				cpu_dir="/sys/devices/system/cpu/cpu${cpu}"
				if [ -d "$cpu_dir" ]; then
					apply "$freq" "${cpu_dir}/cpufreq/scaling_${max_min}_freq"
				fi
			done
		fi
	fi
}

cpu_core_ctrl() {
	if [[ $1 == "-exec" ]]; then
		apply $3 /sys/devices/system/cpu/cpu$2/online
	else
		cpu_dir="/sys/devices/system/cpu"

		while true; do
			options=("cpu0 Online (system essential) ✅")

			# Add options for each CPU core
			for ((cpu = 1; cpu <= cores; cpu++)); do
				online_status=$(<"${cpu_dir}/cpu${cpu}/online")
				if [[ $online_status == 1 ]]; then
					status_label="Online ✅"
				else
					status_label="Offline ❌"
				fi
				options+=("cpu${cpu} $status_label")
			done

			# Add a separator and "Back to the main menu" option
			options+=(" " "Back to the main menu")

			selected=$(printf '%s\n' "${options[@]}" | fzf --reverse --cycle --prompt "CPU core control")

			case $selected in
			"Back to the main menu") break ;;
			" ") ;;
			*)
				cpu_number=$(echo "${selected}" | cut -d' ' -f1 | sed 's/cpu//')
				online_status=$(<"${cpu_dir}/cpu${cpu_number}/online")
				new_status=$((1 - online_status))
				apply "$new_status" "${cpu_dir}/cpu${cpu_number}/online"
				command2db cpu.core_ctl.cpu$cpu_number "cpu_core_ctrl -exec $new_status $cpu_number" FALSE
				;;
			esac
		done
	fi
}

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

cpu_gov_param() {
	if [[ $is_big_little == 1 ]]; then
		case $nr_clusters in
		2) cluster_selected=$(fzf_select "little big" "Select cpu cluster: ") ;;
		3) cluster_selected=$(fzf_select "little big prime" "Select cpu cluster: ") ;;
		esac
		
		cpu_cluster_handle $cluster_selected
		local path_gov_param="/sys/devices/system/cpu/cpufreq/$(cat /sys/devices/system/cpu/cpufreq/policy${first_cpu_oncluster}/scaling_governor)"
		[ ! -d $path_gov_param ] && local path_gov_param="/sys/devices/system/cpu/cpufreq/policy${first_cpu_oncluster}/$(cat /sys/devices/system/cpu/cpufreq/policy${first_cpu_oncluster}/scaling_governor)"
	else
		local path_gov_param="/sys/devices/system/cpu/cpufreq/$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)"
		[ ! -d $path_gov_param ] && local path_gov_param="/sys/devices/system/cpu/cpufreq/policy0/$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)"
	fi

	[ ! -d $path_gov_param ] && echo -e "\n[-] '$(basename ${path_gov_param})' is not tuneable\n[*] Hit enter to back to main menu" && read -r -s && return 0
	gov_param=$(fzf_select "$(ls $path_gov_param)" "Select Governor parameter: ")
	tput cuu 1
	if [[ $gov_param == *freq* ]]; then
		local freq=$(fzf_select "0 $(cat /sys/devices/system/cpu/cpufreq/policy${first_cpu_oncluster}/scaling_available_frequencies)" "Tune $gov_param parameter: ")
		apply $freq $path_gov_param/$gov_param
	else
		tput cuu 1
		menu_value_tune "Tune $gov_param parameter" "$path_gov_param/$gov_param" "100000000" "0" "1"
	fi
}

mtk_ppm_policy() {
	if [[ $1 == "-exec" ]]; then
		if [[ $2 == "policy" ]]; then
			apply "$3 $4" /proc/ppm/policy_status
		else
			apply $3 /proc/ppm/enabled
		fi
	else
		fetch_state() {
			cat /proc/ppm/policy_status | grep 'PPM_' | while read line; do echo $line; done
		}

		tput cuu 1
		echo -e "\e[38;2;254;228;208m[] Performance and Power Management Menu\033[0m"

		while true; do
			selected=$(fzy_select "PPM $(cat /proc/ppm/enabled | awk '{print $3}')\n \n$(fetch_state)\n \nBack to the main menu" "")

			if [[ $selected == "Back to the main menu" ]]; then
				break
			elif [[ "$(echo $selected | awk '{print $1}')" == "PPM" ]]; then
				case "$(cat /proc/ppm/enabled | awk '{print $3}')" in
				enabled)
					apply 0 /proc/ppm/enabled
					command2db cpu.mtk.enable_ppm "mtk_ppm_policy -exec 0" FALSE
					;;
				disabled)
					apply 1 /proc/ppm/enabled
					command2db cpu.mtk.enable_ppm "mtk_ppm_policy -exec 1" FALSE
					;;
				esac
			elif [[ $selected != " " ]]; then
				idx=$(echo "$selected" | awk '{print $1}' | awk -F'[][]' '{print $2}')
				current_status=$(echo $selected | awk '{print $3}')

				if [[ $current_status == *enabled* ]]; then
					new_status=0
				else
					new_status=1
				fi

				apply "$idx $new_status" /proc/ppm/policy_status
				command2db cpu.mtk.ppm_policy$idx "mtk_ppm_policy -exec policy $idx $new_status" FALSE
			fi
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

cpu_menu() {
	while true; do
		unset_headvar
		header_info=(
			"[] CPU: ${chipset}"
			"[] big.LITTLE: ${is_big_little}"
		)

		if [ $is_big_little -eq 1 ]; then
			header_info+=(
				"[] big.LITTLE Clusters: ${nr_clusters}"
				"[] Little Scaling freq: $(cat /sys/devices/system/cpu/cpu$(echo ${cluster0} | awk '{print $1}')/cpufreq/scaling_min_freq)KHz - $(cat /sys/devices/system/cpu/cpu$(echo ${cluster0} | awk '{print $1}')/cpufreq/scaling_max_freq)KHz"
				"[] Big Scaling freq: $(cat /sys/devices/system/cpu/cpu$(echo ${cluster1} | awk '{print $1}')/cpufreq/scaling_min_freq)KHz - $(cat /sys/devices/system/cpu/cpu$(echo ${cluster1} | awk '{print $1}')/cpufreq/scaling_max_freq)KHz"
			)

			if [[ $nr_clusters == 3 ]]; then
				header_info+=("[] Prime Scaling freq: $(cat /sys/devices/system/cpu/cpu$(echo ${cluster2} | awk '{print $1}')/cpufreq/scaling_min_freq)KHz - $(cat /sys/devices/system/cpu/cpu$(echo ${cluster2} | awk '{print $1}')/cpufreq/scaling_max_freq)KHz")
			fi

			for policy in ${policy_folders[@]}; do
				gov_tmp="${gov_tmp}$(cat $policy/scaling_governor) "
			done
			header_info+=("[] Governor: ${gov_tmp}")
			unset gov_tmp
		else
			header_info=("[] Scaling freq: $(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq)KHz - $(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq)KHz")
			cpu_gov_info="[] Governor: $(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)"
		fi

		options="Set Governor\nGovernor parameter\nSet max freq\nSet min freq\nCPU Core control"

		if [[ $soc == Mediatek ]] && [ -d /proc/ppm ]; then
			header_info+=(
				"[] Mediatek PPM: $(cat /proc/ppm/enabled | awk '{print $3}')"
				"[] CPU Power mode: $(cat /proc/cpufreq/cpufreq_power_mode)"
				"[] CPU CCI mode: $(cat /proc/cpufreq/cpufreq_cci_mode)"
			)
			options="$options\nMediatek Performance and Power Management\nMediatek CCI mode\nMediatek Power mode"
		fi

		if [[ $soc == Mediatek ]] && [ -d /proc/eem ]; then
			options="$options\nCPU Voltage offset"
		fi

		clear
		echo -e "\e[30;48;2;254;228;208;38;2;0;0;0m Origami Kernel Manager ${VERSION}$(yes " " | sed $((LINE - 30))'q' | tr -d '\n')\033[0m"
		echo -e "\e[38;2;254;228;208m"
		echo -e "    _________      ${header_info[0]}"
		echo -e "   /        /\\     ${header_info[1]}"
		echo -e "  /        /  \\    ${header_info[2]}"
		echo -e " /        /    \\   ${header_info[3]}" | cut -c 1-${LINE}
		echo -e "/________/      \\  ${header_info[4]}" | cut -c 1-${LINE}
		echo -e "\\        \\      /  ${header_info[5]}" | cut -c 1-${LINE}
		echo -e " \\        \\    /   ${header_info[6]}"
		echo -e "  \\        \\  /    ${header_info[7]}"
		echo -e "   \\________\\/     ${header_info[8]}"
		echo -e "\n//////////////"
		echo -e "$(yes "─" | sed ${LINE}'q' | tr -d '\n')\n"
		echo -e "[] CPU Control\033[0m"

		tput civis

		case $(fzy_select "$options\nBack to main menu" "") in
		"Set Governor") cpu_set_gov ;;
		"Governor parameter") cpu_gov_param ;;
		"Set max freq") cpu_set_freq max ;;
		"Set min freq") cpu_set_freq min ;;
		"CPU Core control") cpu_core_ctrl ;;
		"Mediatek Performance and Power Management") mtk_ppm_policy ;;
		"Mediatek CCI mode") mtk_cpufreq_cci_mode ;;
		"Mediatek Power mode") mtk_cpufreq_power_mode ;;
		"CPU Voltage offset") mtk_cpu_volt_offset ;;
		"Back to main menu") break ;;
		esac
	done
}
