#!/bin/env bash
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
# Copyright (C) 2023-present Rem01Gaming

if [[ $soc == Mediatek ]]; then
	source $PREFIX/share/origami-kernel/utils/cpu/mtk_cpumisc.sh
elif [[ $soc == Qualcomm ]]; then
	source $PREFIX/share/origami-kernel/utils/cpu/qcom_cpubus.sh
fi

# https://askubuntu.com/questions/1064269/cpufrequtils-available-frequencies
intel_scaling_available_frequencies() {
	NumSteps=$(cat /sys/devices/system/cpu/intel_pstate/num_pstates)
	MinFreq=$(cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_min_freq)
	MaxFreq=$(cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq)
	LastFreq=$MinFreq
	StepRate=$((($MaxFreq - $MinFreq) / $NumSteps))
	for ((n = 0; n <= $NumSteps; n++)); do
		echo $LastFreq
		LastFreq=$(($LastFreq + $StepRate))
	done
}

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
			cpu_cluster_handle $cluster_selected
			local gov_selected=$(fzf_select "$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors)" "Select CPU Governor: ")
			command2db cpu.$cluster_selected.governor "cpu_set_gov -exec $gov_selected $cluster_selected" FALSE
		fi

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
	if [[ $soc == Mediatek ]] && [ ! -d /sys/devices/system/cpu/cpufreq/mtk ] && [ -d /proc/ppm ] && [[ $1 != "-exec" ]]; then
		if [[ "$(cat /proc/ppm/enabled)" != "ppm is enabled" ]]; then
			echo -e "\n[-] Enable Performance and Power Management First"
			echo "[*] Hit enter to back to main menu"
			read -r -s
			return 1
		elif [[ "$(grep "PPM_POLICY_HARD_USER_LIMIT" /proc/ppm/policy_status)" != *enabled* ]]; then
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
			cpu_cluster_handle $cluster_selected
			max_min=$1
			local freq=$(fzf_select "$(cat /sys/devices/system/cpu/cpufreq/policy${first_cpu_oncluster}/scaling_available_frequencies)" "Select $max_min CPU freq for $cluster_selected cluster: ")
			command2db cpu.$cluster_selected.${max_min}_freq "cpu_set_freq -exec $freq $cluster_selected $max_min" FALSE
		fi

		if [[ $soc == Mediatek ]] && [ -d /sys/devices/system/cpu/cpufreq/mtk ]; then
			case $cluster_selected in
			little) apply $freq /sys/devices/system/cpu/cpufreq/mtk/lcluster_${max_min}_freq ;;
			big) apply $freq /sys/devices/system/cpu/cpufreq/mtk/bcluster_${max_min}_freq ;;
			prime) apply $freq /sys/devices/system/cpu/cpufreq/mtk/pcluster_${max_min}_freq ;;
			esac
		elif [[ $soc == Mediatek ]] && [ -d /proc/ppm ]; then
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

			if [[ $soc == "Intel" ]]; then
				local available_freq="$(intel_scaling_available_frequencies)"
			else
				local available_freq="$(cat /sys/devices/system/cpu/cpufreq/policy0/scaling_available_frequencies)"
			fi

			local freq=$(fzf_select "$available_freq" "Select $max_min CPU frequency: ")
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

			selected=$(fzf_select_n "$(printf '%s\n' "${options[@]}")" "CPU Core Control: ")

			case "$selected" in
			"Back to the main menu") break ;;
			" " | *system*) ;;
			*)
				cpu_number=${selected:3:1}
				new_status=$((1 - $(<"${cpu_dir}/cpu${cpu_number}/online")))
				apply "$new_status" "${cpu_dir}/cpu${cpu_number}/online"
				command2db cpu.core_ctl.cpu$cpu_number "cpu_core_ctrl -exec $new_status $cpu_number" FALSE
				;;
			esac
		done
	fi
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

cpu_block_thermal_interface() {
	if [[ $1 == "-exec" ]]; then
		local selected=$2
	else
		local selected=$(fzf_select "Allow Disallow" "Prohibit CPU thermal access: ")
		command2db cpu.block_thermal_interface "cpu_block_thermal_interface -exec $selected" FALSE
	fi

	case $selected in
	Allow) chmod 644 /sys/devices/virtual/thermal/thermal_message/cpu_limits ;;
	Disallow) for path in /sys/devices/system/cpu/cpufreq/policy*; do
		cpu_maxfreq="$(cat $path/cpuinfo_max_freq)"
		apply "cpu$(awk '{print $1}' $path/affected_cpus) $cpu_maxfreq" /sys/devices/virtual/thermal/thermal_message/cpu_limits
		apply "$cpu_maxfreq" $path/scaling_max_freq
	done ;;
	esac
}

cpu_menu() {
	while true; do
		unset_headvar
		header_info=(
			"[] CPU: $chipset"
			"[] big.LITTLE: $is_big_little"
		)

		if [ $is_big_little -eq 1 ]; then
			header_info+=(
				"[] big.LITTLE Clusters: $nr_clusters"
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
			header_info+=("[] Scaling freq: $(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq)KHz - $(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq)KHz"
			"[] Governor: $(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)")
		fi

		options="Set Governor\nGovernor parameter\nSet max freq\nSet min freq\nCPU Core control"

		if [ -f /sys/devices/virtual/thermal/thermal_message/cpu_limits ]; then
			options="$options\nProhibit CPU thermal access"
		fi

		if [[ $soc == Mediatek ]]; then
			if [ -d /proc/ppm ]; then
				header_info+=("[] Mediatek PPM: $(awk '{print $3}' /proc/ppm/enabled)")
				options="$options\nMediatek Performance and Power Management"
			fi

			if [ -f /proc/cpufreq/cpufreq_power_mode ]; then
				header_info+=("[] CPU Power mode: $(cat /proc/cpufreq/cpufreq_power_mode)")
				options="$options\nMediatek CCI mode"
			fi

			if [ -f /proc/cpufreq/cpufreq_cci_mode ]; then
				header_info+=(
					"[] CPU CCI mode: $(cat /proc/cpufreq/cpufreq_cci_mode)")
				options="$options\nMediatek Power mode"
			fi

			if [ -f /sys/devices/system/cpu/sched/sched_boost ]; then
				options="$options\nMediatek Sched Boost"
			fi

			if [ -d /proc/eem ]; then
				options="$options\nCPU Voltage offset (EEM)"
			elif [ -d /proc/eemg ]; then
				options="$options\nCPU Voltage offset (EEMG)"
			fi
		fi

		if [[ $soc == Qualcomm ]]; then
			if [ -d /sys/devices/system/cpu/bus_dcvs ]; then
				options="$options\nCPU Bus Control"
			fi
		fi

		header "CPU Control"
		selected="$(fzy_select "$options\nBack to main menu" "")"

		case "$selected" in
		"Set Governor") cpu_set_gov ;;
		"Governor parameter") cpu_gov_param ;;
		"Set max freq") cpu_set_freq max ;;
		"Set min freq") cpu_set_freq min ;;
		"CPU Core control") cpu_core_ctrl ;;
		"Prohibit CPU thermal access") cpu_block_thermal_interface ;;
		"Mediatek Performance and Power Management") mtk_ppm_policy ;;
		"Mediatek CCI mode") mtk_cpufreq_cci_mode ;;
		"Mediatek Power mode") mtk_cpufreq_power_mode ;;
		"Mediatek Sched Boost") mtk_sched_boost ;;
		"CPU Voltage offset (EEM)") mtk_cpu_volt_offset ;;
		"CPU Voltage offset (EEMG)") mtk_cpu_volt_offset2 ;;
		"CPU Bus Control") qcom_cpubus ;;
		"Back to main menu") break ;;
		esac
	done
}
