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

thermal_gov_set() {
	chmod 0644 /sys/class/thermal/thermal_zone0/available_policies
	local thermal_policy=$(fzf_select "$(cat /sys/class/thermal/thermal_zone0/available_policies)" "Select Thermal governor (apply globally): ")
	for thermal in $(ls /sys/class/thermal); do
		if [ -f /sys/class/thermal/${thermal}/policy ]; then
			apply $thermal_policy /sys/class/thermal/${thermal}/policy
		fi
	done &
}

io_sched_set() {
	local block_target=$(fzf_select "$(print_existing_folders /sys/block mmcblk0 mmcblk1 $(echo sd{a..z}) dm-0)" "Select block you wanted to change I/O sched: ")
	apply $(fzf_select "$(cat /sys/block/${block_target}/queue/scheduler | sed 's/\[//g; s/\]//g')" "Select I/O Scheduler: ") /sys/block/${block_target}/queue/scheduler
}

dt2w_switch() {
	case $(fzf_select "Enable Disable" "Double tap to wake: ") in
	Enable) apply 1 $dt2w_path ;;
	Disable) apply 0 $dt2w_path ;;
	esac
}

selinux_switch() {
	case $(fzf_select "enforcing permissive" "Selinux mode: ") in
	enforcing) setenforce 1 ;;
	permissive) setenforce 0 ;;
	esac
}

touchpanel_game_mode() {
	case $(fzf_select "Enable Disable" "Touchpanel Game mode: ") in
	Enable) apply 1 /proc/touchpanel/game_switch_enable ;;
	Disable) apply 0 /proc/touchpanel/game_switch_enable ;;
	esac
}

touchpanel_limit() {
	case $(fzf_select "Enable Disable" "Touchpanel limit: ") in
	Enable) apply 1 /proc/touchpanel/oplus_tp_limit_enable ;;
	Disable) apply 0 /proc/touchpanel/oplus_tp_limit_enable ;;
	esac
}

touchpanel_direction_fix() {
	case $(fzf_select "Enable Disable" "Touchpanel direction fix: ") in
	Enable) apply 1 /proc/touchpanel/oplus_tp_direction ;;
	Disable) apply 0 /proc/touchpanel/oplus_tp_direction ;;
	esac
}

mtk_vibrator_ctrl() {
	menu_value_tune "Mediatek Vibrator control\nSet strength of vibration globally on Mediatek devices" /sys/kernel/thunderquake_engine/level $(cat /sys/kernel/thunderquake_engine/max) $(cat /sys/kernel/thunderquake_engine/min) 1
}

mtk_pbm_switch() {
	case $(fzf_select "Enable Disable" "Mediatek Power Budget Management:  ") in
	Enable) apply "stop 0" /proc/pbm/pbm_stop ;;
	Disable) apply "stop 1" /proc/pbm/pbm_stop ;;
	esac
}

mtk_apu_set_freq() {
	opp_selected=$(fzf_select_n "$(seq -1 $(cat /sys/module/mmdvfs_pmqos/parameters/dump_setting | grep -o '\[[^]]*\]' | grep -oE '[+-]?[0-9]+' | sort -n | tail -n 1))" "Select frequency for APUs (NO DVFS) :  ")
	apply $opp_selected /sys/module/mmdvfs_pmqos/parameters/force_step
}

mtk_batoc_current_limit() {
	case $(fzf_select "Enable Disable" "Mediatek's batoc Current limit:  ") in
	Enable) apply "stop 0" /proc/mtk_batoc_throttling/battery_oc_protect_stop ;;
	Disable) apply "stop 1" /proc/mtk_batoc_throttling/battery_oc_protect_stop ;;
	esac
}

mtk_eara_thermal_switch() {
	case $(fzf_select "Enable Disable" "Enable Eara thermal:  ") in
	Enable) apply "1" /sys/kernel/eara_thermal/enable ;;
	Disable) apply "0" /sys/kernel/eara_thermal/enable ;;
	esac
}

mtk_eara_thermal_fake_throttle() {
	case $(fzf_select "Enable Disable" "Fake throttle Eara thermal:  ") in
	Enable) apply "1" /sys/kernel/eara_thermal/fake_throttle ;;
	Disable) apply "0" /sys/kernel/eara_thermal/fake_throttle ;;
	esac
}

misc_menu() {
	while true; do
		header_info=()

		if [ ! -z $dt2w_path ]; then
			header_info+=("[] DT2W: $(cat $dt2w_path)")
			options="Double tap to wake\n"
		fi

		if [[ $soc == Mediatek ]] && [ -d /sys/kernel/thunderquake_engine ]; then
			header_info+=("[ϟ] Vibrator strength: $(cat /sys/kernel/thunderquake_engine/level)")
			options="${options}Vibration strength level\n"
		fi

		if [ -f /proc/touchpanel/game_switch_enable ]; then
			header_info+=("[ϟ] Touchpanel game mode: $(cat /proc/touchpanel/game_switch_enable)")
			options="${options}Touchpanel game mode\n"
		fi

		if [ -f /proc/touchpanel/oplus_tp_limit_enable ]; then
			header_info+=("[] Touchpanel limit: $(cat /proc/touchpanel/oplus_tp_limit_enable)")
			options="${options}Touchpanel limit\n"
		fi

		if [ -f /proc/touchpanel/oplus_tp_direction ]; then
			header_info+=("[] Touchpanel direction fix: $(cat /proc/touchpanel/oplus_tp_direction)")
			options="${options}Touchpanel direction fix\n"
		fi

		if [ -d /ppm/pbm ]; then
			header_info+=("[] MTK Power Budged: $(cat /proc/pbm/pbm_stop | awk '{print $3}')")
			options="${options}MTK Power Budged\n"
		fi

		if [ -d /proc/mtk_batoc_throttling ]; then
			header_info+=("[] MTK batoc Current limit: $(cat /proc/mtk_batoc_throttling/battery_oc_protect_stop)")
			options="${options}MTK batoc Current limit\n"
		fi

		if [ -d /sys/kernel/eara_thermal ]; then
			header_info+=("[] MTK Eara thermal: $(cat /sys/kernel/eara_thermal/enable)")
			options="${options}Enable Eara thermal\nFake throttle Eara thermal\n"
		fi

		if [ -d /sys/module/mmdvfs_pmqos ]; then
			options="${options}Set APUs freq (NO DVFS)\n"
		fi

		clear
		echo -e "\e[30;48;2;254;228;208;38;2;0;0;0m Origami Kernel Manager ${VERSION}$(yes " " | sed $((LINE - 30))'q' | tr -d '\n')\033[0m"
		echo -e "\e[38;2;254;228;208m"
		echo -e "    _________      [] Thermal Governor: $(chmod 0644 /sys/class/thermal/thermal_zone0/policy && cat /sys/class/thermal/thermal_zone0/policy)"
		echo -e "   /        /\\     [] SELINUX: $(getenforce)"
		echo -e "  /        /  \\    ${header_info[0]}"
		echo -e " /        /    \\   ${header_info[1]}"
		echo -e "/________/      \\  ${header_info[2]}"
		echo -e "\\        \\      /  ${header_info[3]}"
		echo -e " \\        \\    /   ${header_info[4]}"
		echo -e "  \\        \\  /    ${header_info[5]}"
		echo -e "   \\________\\/     ${header_info[6]}"
		echo -e "\n//////////////"
		echo -e "$(yes "─" | sed ${LINE}'q' | tr -d '\n')\n"
		echo -e "[] Miscellaneous Settings\033[0m"

		options="Set I/O Scheduler\nSet Thermal Governor\nSelinux mode\n$(echo $options)"

		tput civis
		unset header_info

		case $(fzy_select "$options\nBack to main menu" "") in
		"Set I/O Scheduler") io_sched_set ;;
		"Set Thermal Governor") thermal_gov_set ;;
		"Selinux mode") selinux_switch ;;
		"Double tap to wake") dt2w_switch ;;
		"Vibration strength level") mtk_vibrator_ctrl ;;
		"Touchpanel game mode") touchpanel_game_mode ;;
		"Touchpanel limit") touchpanel_limit ;;
		"Touchpanel direction fix") touchpanel_direction_fix ;;
		"MTK Power Budged") mtk_pbm_switch ;;
		"Set APUs freq (NO DVFS)") mtk_apu_set_freq ;;
		"MTK batoc Current limit") mtk_batoc_current_limit ;;
		"Enable Eara thermal") mtk_eara_thermal_switch ;;
		"Fake throttle Eara thermal") mtk_eara_thermal_fake_throttle ;;
		"Back to main menu") break ;;
		esac

		unset options
	done
}
