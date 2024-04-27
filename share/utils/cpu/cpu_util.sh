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

cpu_set_gov() {
	local gov_selected=$(fzf_select "$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors)" "Select CPU Governor: ")
	for ((cpu = 0; cpu < cores; cpu++)); do
		cpu_dir="/sys/devices/system/cpu/cpu${cpu}"
		if [ -d "$cpu_dir" ]; then
			chmod 0644 "${cpu_dir}/cpufreq/scaling_governor"
			echo "$gov_selected" >"${cpu_dir}/cpufreq/scaling_governor"
		fi
	done
}

cpu_set_freq() {
	if [[ $soc == Mediatek ]] && [ -d /proc/ppm ]; then
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

	if [[ $is_big_little == 1 ]]; then
		if [[ $nr_clusters == 2 ]]; then
			local cluster_selected=$(fzf_select "little big" "Select cpu cluster: ")
		elif [[ $nr_clusters == 3 ]]; then
			local cluster_selected=$(fzf_select "little big prime" "Select cpu cluster: ")
		fi

		case $cluster_selected in
		little) local cluster_need_set=0 ;;
		big) local cluster_need_set=1 ;;
		prime) local cluster_need_set=2 ;;
		esac

		case $cluster_need_set in
		0)
			local first_cpu_oncluster=$(echo ${cluster0} | awk '{print $1}')
			local cpus_cluster_selected=${cluster0}
			;;
		1)
			local first_cpu_oncluster=$(echo ${cluster1} | awk '{print $1}')
			local cpus_cluster_selected=${cluster1}
			;;
		2)
			local first_cpu_oncluster=$(echo ${cluster2} | awk '{print $1}')
			local cpus_cluster_selected=${cluster2}
			;;
		esac

		if [[ $soc == Mediatek ]] && [ -d /proc/ppm ]; then
			echo ${cluster_need_set} $(fzf_select "$(cat /sys/devices/system/cpu/cpufreq/policy${first_cpu_oncluster}/scaling_available_frequencies)" "Select ${1} CPU freq for ${cluster_selected} cluster: ") >/proc/ppm/policy/hard_userlimit_${1}_cpu_freq
		else
			local freq=$(fzf_select "$(cat /sys/devices/system/cpu/cpufreq/policy${first_cpu_oncluster}/scaling_available_frequencies)" "Select ${1} CPU freq for ${cluster_selected} cluster: ")
			echo $freq >/sys/devices/system/cpu/cpufreq/policy${first_cpu_oncluster}/scaling_${1}_freq
		fi
	else
		if [[ $soc == Mediatek ]] && [ -d /proc/ppm ]; then
			echo 0 $(fzf_select "$(cat /sys/devices/system/cpu/cpufreq/policy0/scaling_available_frequencies)" "Select ${1} CPU frequency: ") >/proc/ppm/policy/hard_userlimit_${1}_cpu_freq
		else
			local freq=$(fzf_select "$(cat /sys/devices/system/cpu/cpufreq/policy0/scaling_available_frequencies)" "Select ${1} CPU frequency: ")
			echo $freq >/sys/devices/system/cpu/cpufreq/policy0/scaling_${1}_freq
		fi
	fi
}

cpu_core_ctrl() {
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
			echo "${new_status}" >"${cpu_dir}/cpu${cpu_number}/online"
			;;
		esac
	done
}

mtk_cpufreq_cci_mode() {
	case $(fzf_select "Normal Performance" "Mediatek CPU CCI mode: ") in
	Performance) echo 1 >/proc/cpufreq/cpufreq_cci_mode ;;
	Normal) echo 0 >/proc/cpufreq/cpufreq_cci_mode ;;
	esac
}

mtk_cpufreq_power_mode() {
	case $(fzf_select "Normal Low-power Make Performance" "Mediatek CPU Power mode: ") in
	Performance) echo 3 >/proc/cpufreq/cpufreq_power_mode ;;
	Low-power) echo 1 >/proc/cpufreq/cpufreq_power_mode ;;
	Make) echo 2 >/proc/cpufreq/cpufreq_power_mode ;;
	Normal) echo 0 >/proc/cpufreq/cpufreq_power_mode ;;
	esac
}

cpu_gov_param() {
	governor_now="/sys/devices/system/cpu/cpufreq/$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)"
	[ ! -d $governor_now ] && echo -e "\n[-] '$(basename ${governor_now})' is not tuneable\n[*] Hit enter to back to main menu" && read -r -s && return 0
	echo -e "\nSelect Governor parameter:"
	gov_param=$(fzy_select "$(ls $governor_now)" "")
	tput cuu 1
	if [[ $gov_param == *freq* ]]; then
		local freq=$(fzf_select "0 $(cat /sys/devices/system/cpu/cpufreq/policy0/scaling_available_frequencies)" "Tune $gov_param parameter: ")
		echo $freq >/sys/devices/system/cpu/cpufreq/$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)/$gov_param
	else
		tput cuu 1
		menu_value_tune "Tune $gov_param parameter" "/sys/devices/system/cpu/cpufreq/$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)/$gov_param" "100000000" "0" "1"
	fi
}

mtk_ppm_policy() {
	tput cuu 1
	tput el
	echo -e "\e[38;2;254;228;208m[] Performance and Power Management Menu\033[0m"

	while true; do
		options=(
			"PPM $(cat /proc/ppm/enabled | awk '{print $3}')"
			" "
			"$(sed -n 1p /proc/ppm/policy_status | sed -e 's/\[//g; s/\] /) /g' | tr -d ':')"
			"$(sed -n 2p /proc/ppm/policy_status | sed -e 's/\[//g; s/\] /) /g' | tr -d ':')"
			"$(sed -n 3p /proc/ppm/policy_status | sed -e 's/\[//g; s/\] /) /g' | tr -d ':')"
			"$(sed -n 4p /proc/ppm/policy_status | sed -e 's/\[//g; s/\] /) /g' | tr -d ':')"
			"$(sed -n 5p /proc/ppm/policy_status | sed -e 's/\[//g; s/\] /) /g' | tr -d ':')"
			"$(sed -n 6p /proc/ppm/policy_status | sed -e 's/\[//g; s/\] /) /g' | tr -d ':')"
			"$(sed -n 7p /proc/ppm/policy_status | sed -e 's/\[//g; s/\] /) /g' | tr -d ':')"
			"$(sed -n 8p /proc/ppm/policy_status | sed -e 's/\[//g; s/\] /) /g' | tr -d ':')"
			"$(sed -n 9p /proc/ppm/policy_status | sed -e 's/\[//g; s/\] /) /g' | tr -d ':')"
			"$(sed -n 10p /proc/ppm/policy_status | sed -e 's/\[//g; s/\] /) /g' | tr -d ':')"
			" "
			"Back to the main menu"
		)

		selected=$(printf '%s\n' "${options[@]}" | fzy -l 15 -p "")

		if [[ $selected == "Back to the main menu" ]]; then
			break
		elif [[ "$(echo $selected | awk '{print $1}')" == "PPM" ]]; then
			case "$(cat /proc/ppm/enabled | awk '{print $3}')" in
			enabled) echo 0 >/proc/ppm/enabled ;;
			disabled) echo 1 >/proc/ppm/enabled ;;
			esac
		elif [[ $selected != " " ]]; then
			idx=$(echo "$selected" | awk '{print $1}' | tr -d ')')
			current_status=$(echo $selected | awk '{print $3}')

			if [[ $current_status == *enabled* ]]; then
				new_status=0
			else
				new_status=1
			fi

			echo "$idx $new_status" >/proc/ppm/policy_status
		fi
		unset options
	done
}

mtk_cpu_volt_offset() {
	case $(fzf_select_n "Little cluster\nBig cluster\nCache Coherent Interconnect (CCI)" "Select CPU Part to voltage offset: ") in
	"Little cluster") menu_value_tune "Offset Voltage for CPU Little cluster\nOffset will take original voltage from Operating Performance Point (OPP) and add or subtract the given voltage, you can use it for Overvolting or Undervolting." /proc/eem/EEM_DET_L/eem_offset 50 -50 1 ;;
	"Big cluster") menu_value_tune "Offset Voltage for CPU Big cluster\nOffset will take original voltage from Operating Performance Point (OPP) and add or subtract the given voltage, you can use it for Overvolting or Undervolting." /proc/eem/EEM_DET_B/eem_offset 50 -50 1 ;;
	"Cache Coherent Interconnect (CCI)") menu_value_tune "Offset Voltage for CPU CCI\nOffset will take original voltage from Operating Performance Point (OPP) and add or subtract the given voltage, you can use it for Overvolting or Undervolting." /proc/eem/EEM_DET_CCI/eem_offset 50 -50 1 ;;
	esac
}

cpu_menu() {
	while true; do
		if [[ $is_big_little == 1 ]]; then
			cpu_menu_info="[] big.LITTLE Clusters: ${nr_clusters}//[] Little Scaling freq: $(cat /sys/devices/system/cpu/cpu$(echo ${cluster0} | awk '{print $1}')/cpufreq/scaling_min_freq)KHz - $(cat /sys/devices/system/cpu/cpu$(echo ${cluster0} | awk '{print $1}')/cpufreq/scaling_max_freq)KHz//[] Big Scaling freq: $(cat /sys/devices/system/cpu/cpu$(echo ${cluster1} | awk '{print $1}')/cpufreq/scaling_min_freq)KHz - $(cat /sys/devices/system/cpu/cpu$(echo ${cluster1} | awk '{print $1}')/cpufreq/scaling_max_freq)KHz//"
			if [[ $nr_clusters == 3 ]]; then
				cpu_menu_info="${cpu_menu_info}[] Prime Scaling freq: $(cat /sys/devices/system/cpu/$(echo ${cluster2} | awk '{print $1}')/cpufreq/scaling_min_freq)KHz - $(cat /sys/devices/system/cpu/cpu$(echo ${cluster2} | awk '{print $1}')/cpufreq/scaling_max_freq)KHz//"
			fi
		else
			cpu_menu_info="[] Scaling freq: $(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq)KHz - $(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq)KHz//"
		fi

		cpu_menu_options="Set Governor\nGovernor parameter\nSet max freq\nSet min freq\nCPU Core control\n"

		if [[ $soc == Mediatek ]] && [ -d /proc/ppm ]; then
			cpu_menu_info="${cpu_menu_info}[] Mediatek PPM: $(cat /proc/ppm/enabled | awk '{print $3}')//[] CPU Power mode: $(cat /proc/cpufreq/cpufreq_power_mode)//[] CPU CCI mode: $(cat /proc/cpufreq/cpufreq_cci_mode)//"
			cpu_menu_options="$(echo "$cpu_menu_options")Mediatek Performance and Power Management\nMediatek CCI mode\nMediatek Power mode\n"
		fi

		if [[ $soc == Mediatek ]] && [ -d /proc/eem ]; then
			cpu_menu_options="$(echo "$cpu_menu_options")CPU Voltage offset\n"
		fi

		clear
		echo -e "\e[30;48;2;254;228;208;38;2;0;0;0m Origami Kernel Manager ${VERSION}$(yes " " | sed $((LINE - 30))'q' | tr -d '\n')\033[0m"
		echo -e "\e[38;2;254;228;208m"
		echo -e "    _________      [] CPU: ${chipset}"
		echo -e "   /        /\\     [] Governor: $(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)"
		echo -e "  /        /  \\    [] big.LITTLE: ${is_big_little}"
		echo -e " /        /    \\   $(echo "$cpu_menu_info" | awk -F '//' '{print $1}')"
		echo -e "/________/      \\  $(echo "$cpu_menu_info" | awk -F '//' '{print $2}')"
		echo -e "\\        \\      /  $(echo "$cpu_menu_info" | awk -F '//' '{print $3}')"
		echo -e " \\        \\    /   $(echo "$cpu_menu_info" | awk -F '//' '{print $4}')"
		echo -e "  \\        \\  /    $(echo "$cpu_menu_info" | awk -F '//' '{print $5}')"
		echo -e "   \\________\\/     $(echo "$cpu_menu_info" | awk -F '//' '{print $6}')"
		echo -e "\n//////////////"
		echo -e "$(yes "─" | sed ${LINE}'q' | tr -d '\n')\n"
		echo -e "[] CPU Control\033[0m"

		tput civis

		case $(fzy_select "$(echo -e "$cpu_menu_options")\nBack to main menu" "") in
		"Set Governor") cpu_set_gov ;;
		"Governor parameter") cpu_gov_param ;;
		"Set max freq") cpu_set_freq max ;;
		"Set min freq") cpu_set_freq min ;;
		"CPU Core control") cpu_core_ctrl ;;
		"Mediatek Performance and Power Management") mtk_ppm_policy ;;
		"Mediatek CCI mode") mtk_cpufreq_cci_mode ;;
		"Mediatek Power mode") mtk_cpufreq_power_mode ;;
		"CPU Voltage offset") mtk_cpu_volt_offset ;;
		"Back to main menu") clear && return 0 ;;
		esac

		unset cpu_menu_info cpu_menu_options
	done
}
