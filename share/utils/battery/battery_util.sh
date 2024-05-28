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

# Battery node
battery_node_path="/sys/class/power_supply/battery"
current_now_node="${battery_node_path}/current_now"
status_node="${battery_node_path}/status"
battery_capacity_node="${battery_node_path}/charge_full"
battery_level_node="${battery_node_path}/capacity"
battery_health_node="${battery_node_path}/health"
battery_type_node="${battery_node_path}/technology"

# Origami battery data path
chg_switches_path="/data/origami-kernel/chg_switches"
use_chg_switch_path="/data/origami-kernel/use_chg_switch"

# get charging current_now
# if current unit is microamps (μA), divine with 1000
get_charging_current_now() {
	if [[ $current_unit_microamps == 1 ]]; then
		echo "$(expr $(cat $current_now_node | tr -d '-') / 1000)"
	else
		echo "$(cat $current_now_node | tr -d '-')"
	fi
}

test_chg_switches() {
	echo -e "\n[*] Charging switches tester started..."

	# format: node normal_chg_value idle_chg_value
	switches=(
		"${battery_node_path}/batt_slate_mode 0 1"
		"${battery_node_path}/battery_input_suspend 0 1"
		"${battery_node_path}/bd_trickle_cnt 0 1"
		"${battery_node_path}/device/Charging_Enable 1 0"
		"${battery_node_path}/charging_enabled 1 0"
		"${battery_node_path}/op_disable_charge 0 1"
		"${battery_node_path}/store_mode 0 1"
		"${battery_node_path}/test_mode 2 1"
		"${battery_node_path}/battery_ext/smart_charging_interruption 0 1"
		"${battery_node_path}/siop_level 100 0"
		"${battery_node_path}/battery_charging_enabled 1 0"
		"/sys/class/hw_power/charger/charge_data/enable_charger 1 0"
		"/sys/class/qcom-battery/input_suspend 0 1"
		"/sys/devices/platform/huawei_charger/enable_charger 1 0"
		"/sys/devices/platform/lge-unified-nodes/charging_completed 0 1"
		"/sys/devices/platform/lge-unified-nodes/charging_enable 1 0"
		"/sys/devices/platform/mt-battery/disable_charger 0 1"
		"/sys/devices/platform/soc/soc:google,charger/charge_disable 0 1"
		"/sys/kernel/debug/google_charger/chg_suspend 0 1"
		"/sys/kernel/debug/google_charger/input_suspend 0 1"
		"/sys/kernel/nubia_charge/charger_bypass off on"
		"/proc/mtk_battery_cmd/current_cmd 0::0 0::1"
		"${battery_node_path}/mmi_charging_enable 1 0"
		"${battery_node_path}/stop_charging_enable 0 1"
		"${battery_node_path}/store_mode 0 1"
	)

	if [[ $(cat $status_node) != *Charging* ]]; then
		echo "[-] Please connect device to charger first !"
		read -r -s
	else
		# Nuke tested switches before test
		rm -f "$chg_switches_path"
		rm -f "$use_chg_switch_path"

		if [ $(cat $current_now_node | tr -d '-') -gt 10000 ]; then
			# current unit is microamps
			current_unit_microamps=1
		fi

		for switch in "${switches[@]}"; do
			local node_path=$(echo "$switch" | awk '{print $1}')
			local normal_val=$(echo "$switch" | awk '{print $2}' | sed 's/::/ /g')
			local idle_val=$(echo "$switch" | awk '{print $3}' | sed 's/::/ /g')
			if [ -f $node_path ]; then
				echo "[*] Testing switch: ${switch}"
				chmod +x $node_path
				echo $idle_val >$node_path 2>/dev/null
				sleep 2

				current_samples=()
				for i in {1..15}; do
					current_now=$(get_charging_current_now)
					echo "[*] Current now: ${current_now} mA"
					current_samples+=("$current_now")
					sleep 1
					tput cuu 1
					tput el
				done

				average_current=$(echo "${current_samples[@]}" | awk '{ sum += $1; n++ } END { if (n > 0) print sum / n; else print "0" }')
				unset current_samples

				if ((average_current <= 52)); then
					echo -e "[+] Switch $node_path is working !"
					echo -e "$(cat "$chg_switches_path" 2>/dev/null)\n${switch}" >"$chg_switches_path"
				else
					echo -e "[-] Switch $node_path is not working !"
				fi
				echo $normal_val >$node_path 2>/dev/null
			fi
		done
		if [ ! -f "$chg_switches_path" ]; then
			echo -e "[-] No working charging switch was found :("
		else
			sed -i '/^$/d' "$chg_switches_path" # Remove empty lines
		fi
		echo -e "[*] Charging switches tester finished\n[*] Hit enter to back to main menu"
		read -r -s
	fi
}

do_idle_chg() {
	if [ ! -f "$chg_switches_path" ]; then
		echo -e "\n[-] Charging switch not defined, please run 'Test charging switches'"
		echo "[*] Hit enter to back to main menu"
		read -r -s
	else
		if [ ! -f "$use_chg_switch_path" ]; then
			echo $(cat "$chg_switches_path" | fzf --reverse --cycle --prompt "Select a charging switch for first time: ") >"$use_chg_switch_path"
		fi

		local use_chg_switch=$(cat "$use_chg_switch_path")
		local node_path=$(echo $use_chg_switch | awk '{print $1}')
		local normal_val=$(echo $use_chg_switch | awk '{print $2}' | sed 's/::/ /g')
		local idle_val=$(echo $use_chg_switch | awk '{print $3}' | sed 's/::/ /g')
		chmod +x $node_path

		case $(fzf_select "enable disable" "Enable or Disable Idle charging: ") in
		enable) echo $idle_val >$node_path 2>/dev/null ;;
		disable) echo $normal_val >$node_path 2>/dev/null ;;
		esac
	fi
}

change_use_chg_switch() {
	if [ ! -f "$chg_switches_path" ]; then
		echo -e "\n[-] Charging switch not defined, please run 'Test charging switches'"
		echo "[*] Hit enter to back to main menu"
		read -r -s
	else
		if [ -f "$use_chg_switch_path" ]; then
			local use_chg_switch=$(cat "$use_chg_switch_path")
			local node_path=$(echo $use_chg_switch | awk '{print $1}')
			local normal_val=$(echo $use_chg_switch | awk '{print $2}' | sed 's/::/ /g')
			chmod +x $node_path
			echo $normal_val >$node_path 2>/dev/null
		fi
		echo $(cat "$chg_switches_path" | fzf --reverse --cycle --prompt "Select a charging switch: ") >"$use_chg_switch_path"
	fi
}

is_idle_chg_enabled() {
	if [ ! -f "$chg_switches_path" ] || [ ! -f "$use_chg_switch_path" ]; then
		echo "[ϟ] Idle charging: Undefined"
	else
		local use_chg_switch=$(cat "$use_chg_switch_path")
		local node_path=$(echo $use_chg_switch | awk '{print $1}')
		local normal_val=$(echo $use_chg_switch | awk '{print $2}' | sed 's/::/ /g')
		local idle_val=$(echo $use_chg_switch | awk '{print $3}' | sed 's/::/ /g')

		case "$(cat $node_path)" in
		"$idle_val") echo "[ϟ] Idle charging: Enabled" ;;
		"$normal_val") echo "[ϟ] Idle charging: Disabled" ;;
		*) echo "[ϟ] Idle charging: Undefined" ;;
		esac
	fi
}

batt_menu() {
	while true; do
		clear
		echo -e "\e[30;48;2;254;228;208;38;2;0;0;0m Origami Kernel Manager ${VERSION}$(yes " " | sed $((LINE - 30))'q' | tr -d '\n')\033[0m"
		echo -e "\e[38;2;254;228;208m"
		echo -e "    _________      [] Battery level: $(cat $battery_level_node) %"
		echo -e "   /        /\\     [] Battery capacity: $(cat $battery_capacity_node | cut -c 1-4) mAh"
		echo -e "  /        /  \\    [] Battery health: $(cat $battery_health_node)"
		echo -e " /        /    \\   [] Battery type: $(cat $battery_type_node)"
		echo -e "/________/      \\  [] Battery status: $(cat $status_node)"
		echo -e "\\        \\      /  $(is_idle_chg_enabled)"
		echo -e ' \        \    /   '
		echo -e '  \        \  /    '
		echo -e '   \________\/     '
		echo -e "\n//////////////"
		echo -e "$(yes "─" | sed ${LINE}'q' | tr -d '\n')\n"
		echo -e "[] Charging Control\033[0m"

		tput civis

		case $(fzy_select "Test charging switches\nEnable idle charging\nChange charging switch\nBack to main menu" "") in
		"Test charging switches") test_chg_switches ;;
		"Enable idle charging") do_idle_chg ;;
		"Change charging switch") change_use_chg_switch ;;
		"Back to main menu") clear && return 0 ;;
		esac
	done
}
