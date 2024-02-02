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

test_chg_switches() {
	echo -e "\n[*] Charging switches tester started..."

	# format: node normal_chg_value idle_chg_value
	switches=(
		"/sys/devices/platform/charger/power_supply/battery/batt_slate_mode 0 1"
		"/sys/devices/platform/charger/power_supply/battery/battery_input_suspend 0 1"
		"/sys/devices/platform/charger/power_supply/battery/bd_trickle_cnt 0 1"
		"/sys/devices/platform/charger/power_supply/battery/device/Charging_Enable 1 0"
		"/sys/devices/platform/charger/power_supply/battery/op_disable_charge 0 1"
		"/sys/devices/platform/charger/power_supply/battery/store_mode 0 1"
		"/sys/devices/platform/charger/power_supply/battery/test_mode 2 1"
		"/sys/devices/platform/charger/power_supply/battery_ext/smart_charging_interruption 0 1"
		"/sys/devices/platform/charger/power_supply/battery/siop_level 100 0"
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
		"/sys/devices/platform/charger/power_supply/battery/mmi_charging_enable 1 0"
		"/sys/devices/platform/charger/power_supply/battery/stop_charging_enable 0 1"
		"/sys/devices/platform/charger/power_supply/battery/store_mode 0 1"
	)

	# Nuke tested switches before test
	rm -f /data/data/com.termux/files/usr/share/origami-kernel/chg_switches
	rm -f /data/data/com.termux/files/usr/share/origami-kernel/use_chg_switch

	if [[ ! $(cat /sys/devices/platform/charger/power_supply/battery/status) == *Charging* ]]; then
		echo -e "[-] \033[38;5;196merror:\033[0m Please connect device to charger first !"
		read -r -s
	else
		for switch in "${switches[@]}"; do
			node_path=$(echo "$switch" | awk '{print $1}')
			normal_val=$(echo "$switch" | awk '{print $2}' | sed 's/::/ /g')
			idle_val=$(echo "$switch" | awk '{print $3}' | sed 's/::/ /g')
			if [ -f $node_path ]; then
				echo -e "[+] Testing switch: ${switch}"
				echo $idle_val >$node_path
				sleep 3
				current_now=$(cat /sys/devices/platform/charger/power_supply/battery/current_now)
				if ((current_now >= -30 && current_now <= 30)); then
					echo -e "[+] Switch $node_path is working !"
					echo -e "$(cat /data/data/com.termux/files/usr/share/origami-kernel/chg_switches 2>/dev/null)\n${switch}" >/data/data/com.termux/files/usr/share/origami-kernel/chg_switches
				else
					echo -e "[-] Switch $node_path is not working !"
				fi
				echo $normal_val >$node_path
			fi
		done
		if [ ! -f /data/data/com.termux/files/usr/share/origami-kernel/chg_switches ]; then
			echo -e "[-] No working charging switch was found :("
		else
			sed -i '/^$/d' /data/data/com.termux/files/usr/share/origami-kernel/chg_switches # Remove empty lines
		fi
		echo -e "[*] Charging switches tester finished\n[*] Hit enter to back to main menu"
		read -r -s
	fi
}

do_idle_chg() {
	if [ ! -f /data/data/com.termux/files/usr/share/origami-kernel/chg_switches ]; then
		echo -e "\nerror: Charging switch not defined, please run 'Test charging switches'"
		read -r -s
	else
		if [ ! -f /data/data/com.termux/files/usr/share/origami-kernel/use_chg_switch ]; then
			echo $(cat /data/data/com.termux/files/usr/share/origami-kernel/chg_switches | fzf --reverse --cycle --prompt "Select a charging switch for first time: ") >/data/data/com.termux/files/usr/share/origami-kernel/use_chg_switch
		fi

		use_chg_switch=$(cat /data/data/com.termux/files/usr/share/origami-kernel/use_chg_switch)
		node_path=$(echo $use_chg_switch | awk '{print $1}')
		normal_val=$(echo $use_chg_switch | awk '{print $2}' | sed 's/::/ /g')
		idle_val=$(echo $use_chg_switch | awk '{print $3}' | sed 's/::/ /g')

		case $(fzf_select "enable disable" "Enable or Disable Idle charging: ") in
		enable) echo $idle_val >$node_path ;;
		disable) echo $normal_val >$node_path ;;
		esac
	fi
}

change_use_chg_switch() {
	if [ ! -f /data/data/com.termux/files/usr/share/origami-kernel/chg_switches ]; then
		echo -e "\nerror: Charging switch not defined, please run 'Test charging switches'"
		read -r -s
	else
		echo $(cat /data/data/com.termux/files/usr/share/origami-kernel/chg_switches | fzf --reverse --cycle --prompt "Select a charging switch for first time: ") >/data/data/com.termux/files/usr/share/origami-kernel/use_chg_switch
	fi
}

is_idle_chg_enabled() {
	if [ ! -f /data/data/com.termux/files/usr/share/origami-kernel/chg_switches ] || [ ! -f /data/data/com.termux/files/usr/share/origami-kernel/use_chg_switch ]; then
		echo "[ϟ] Idle charging: Undefined"
	else
		use_chg_switch=$(cat /data/data/com.termux/files/usr/share/origami-kernel/use_chg_switch)
		node_path=$(echo $use_chg_switch | awk '{print $1}')
		normal_val=$(echo $use_chg_switch | awk '{print $2}' | sed 's/::/ /g')
		idle_val=$(echo $use_chg_switch | awk '{print $3}' | sed 's/::/ /g')

		if [ "$(cat $node_path)" == "$idle_val" ]; then
			echo "[ϟ] Idle charging: Enabled"
		elif [ "$(cat $node_path)" == "$normal_val" ]; then
			echo "[ϟ] Idle charging: Disabled"
		else
			echo "[ϟ] Idle charging: Undefined"
		fi
	fi
}

batt_menu() {
	while true; do
		clear
		echo -e "\e[30;48;2;254;228;208;38;2;0;0;0m Origami Kernel Manager ${VERSION}$(yes " " | sed $((LINE - 30))'q' | tr -d '\n')\033[0m"
		echo -e "\e[38;2;254;228;208m"
		echo -e "    _________      [] Battery level: $(cat /sys/devices/platform/charger/power_supply/battery/capacity)"
		echo -e "   /        /\\     [] Battery capacity: $(cat /sys/devices/platform/charger/power_supply/battery/charge_full) mAh"
		echo -e "  /        /  \\    [] Battery health: $(cat /sys/devices/platform/charger/power_supply/battery/health)"
		echo -e " /        /    \\   [] Battery type: $(cat /sys/devices/platform/charger/power_supply/battery/technology)"
		echo -e "/________/      \\  $(is_idle_chg_enabled)"
		echo -e "\\        \\      /  "
		echo -e " \\        \\    /   "
		echo -e "  \\        \\  /    "
		echo -e "   \\________\\/     "
		echo -e "\n//////////////"
		echo -e "$(yes "─" | sed ${LINE}'q' | tr -d '\n')\n"
		echo -e "[] Charging Control\033[0m"

		tput civis

		case $(fzy_select "Test charging switches\nEnable idle charging\nChange charging switch\nBack to main menu" "") in
		"Test charging switches") test_chg_switches ;;
		"Enable idle charging") do_idle_chg ;;
		"Change charging switch") change_use_chg_switch ;;
		"Back to main menu") clear && main_menu ;;
		esac
	done
}