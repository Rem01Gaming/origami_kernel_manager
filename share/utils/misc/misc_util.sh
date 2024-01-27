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
export thermal_policy=$(fzf_select "$(chmod 0644 /sys/class/thermal/thermal_zone0/available_policies && cat /sys/class/thermal/thermal_zone0/available_policies)" "Select Thermal governor (apply globally): ")
for thermal in /sys/class/thermal/thermal_zone*; do
chmod 0644 ${thermal}/policy
echo $thermal_policy > ${thermal}/policy
done &
}

io_sched_set() {
	export block_target=$(fzf_select "mmcblk0 mmcblk1 dm-0" "Select block you wanted to change I/O sched: ")
	echo $(fzf_select "$(cat /sys/block/${block_target}/queue/scheduler | sed 's/\[//g; s/\]//g')" "Select I/O Scheduler: ") > /sys/block/${block_target}/queue/scheduler
}

dt2w_switch() {
	case $(fzf_select "Enable Disable" "Double tap to wake: ") in
		Enable) echo 1 > /proc/touchpanel/double_tap_enable ;;
		Disable) echo 0 > /proc/touchpanel/double_tap_enable ;;
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
	      Enable) echo 1 > /proc/touchpanel/game_switch_enable ;;
		  Disable) echo 0 > /proc/touchpanel/game_switch_enable ;;
	esac
}

touchpanel_limit() {
    case $(fzf_select "Enable Disable" "Touchpanel limit: ") in
	      Enable) echo 1 > /proc/touchpanel/oplus_tp_limit_enable ;;
		  Disable) echo 0 > /proc/touchpanel/oplus_tp_limit_enable ;;
	esac
}

touchpanel_direction_fix() {
    case $(fzf_select "Enable Disable" "Touchpanel direction fix: ") in
	      Enable) echo 1 > /proc/touchpanel/oplus_tp_direction ;;
		  Disable) echo 0 > /proc/touchpanel/oplus_tp_direction ;;
	esac
}

mtk_vibrator_ctrl() {
menu_value_tune "Mediatek Vibrator control\nSet strength of vibration globally on Mediatek devices" /sys/kernel/thunderquake_engine/level $(cat /sys/kernel/thunderquake_engine/max) $(cat /sys/kernel/thunderquake_engine/min) 1 
}

misc_menu() {
	while true; do

        if [ -f /proc/touchpanel/double_tap_enable ]; then
            misc_menu_info="[] DT2W: $(cat /proc/touchpanel/double_tap_enable)//"
            misc_menu_options="Double tap to wake\n"
        fi

        if [[ $soc == Mediatek ]] && [ -d /sys/kernel/thunderquake_engine ]; then
            misc_menu_info="${misc_menu_info}[ϟ] Vibrator strength: $(cat /sys/kernel/thunderquake_engine/level)//"
            misc_menu_options="${misc_menu_options}Vibration strength level\n"
        fi

        if [ -f /proc/touchpanel/game_switch_enable ]; then
            misc_menu_info="${misc_menu_info}[ϟ] Touchpanel game mode: $(cat /proc/touchpanel/game_switch_enable)//"
            misc_menu_options="${misc_menu_options}Touchpanel game mode\n"
        fi

        if [ -f /proc/touchpanel/oplus_tp_limit_enable ]; then
            misc_menu_info="${misc_menu_info}[] Touchpanel limit: $(cat /proc/touchpanel/oplus_tp_limit_enable)//"
            misc_menu_options="${misc_menu_options}Touchpanel limit\n"
        fi

        if [ -f /proc/touchpanel/oplus_tp_direction ]; then
            misc_menu_info="${misc_menu_info}[] Touchpanel direction fix: $(cat /proc/touchpanel/oplus_tp_direction)//"
            misc_menu_options="${misc_menu_options}Touchpanel direction fix\n"
        fi

		clear
		echo -e "\e[30;48;2;254;228;208;38;2;0;0;0m Origami Kernel Manager v1.0.1$(yes " " | sed $(($LINE - 30))'q' | tr -d '\n')\033[0m"
		echo -e "\e[38;2;254;228;208m"
		echo -e "    _________      [] Thermal Governor: $(chmod 0644 /sys/class/thermal/thermal_zone0/policy && cat /sys/class/thermal/thermal_zone0/policy)"
		echo -e "   /        /\\     [] SELINUX: $(getenforce)"
		echo -e "  /        /  \\    $(echo "$misc_menu_info" | awk -F '//' '{print $1}')"
		echo -e " /        /    \\   $(echo "$misc_menu_info" | awk -F '//' '{print $2}')"
		echo -e "/________/      \\  $(echo "$misc_menu_info" | awk -F '//' '{print $3}')"
		echo -e "\\        \\      /  $(echo "$misc_menu_info" | awk -F '//' '{print $4}')"
		echo -e " \\        \\    /   $(echo "$misc_menu_info" | awk -F '//' '{print $5}')"
		echo -e "  \\        \\  /    $(echo "$misc_menu_info" | awk -F '//' '{print $6}')"
		echo -e "   \\________\\/     $(echo "$misc_menu_info" | awk -F '//' '{print $7}')"
		echo -e "\n//////////////"
		echo -e "$(yes "─" | sed ${LINE}'q' | tr -d '\n')\n"
		echo -e "[] Miscellaneous Settings\033[0m"

        misc_menu_options="Set I/O Scheduler\nSet Thermal Governor\nSelinux mode\n$(echo $misc_menu_options)"

		tput civis

		case $(fzy_select "$(echo -e "$misc_menu_options")\nBack to main menu" "") in
			"Set I/O Scheduler") io_sched_set ;;
			"Set Thermal Governor") thermal_gov_set ;;
			"Selinux mode") selinux_switch ;;
			"Double tap to wake") dt2w_switch ;;
			"Vibration strength level") mtk_vibrator_ctrl ;;
			"Touchpanel game mode") touchpanel_game_mode ;;
			"Touchpanel limit") touchpanel_limit ;;
			"Touchpanel direction fix") touchpanel_direction_fix ;;
			"Back to main menu") clear && main_menu ;;
		esac
	done
}
