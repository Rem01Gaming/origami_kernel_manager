#!/data/data/com.termux/files/usr/bin/bash

gpu_universal_set_freq() {
echo $(fzf_select "$(cat /sys/kernel/gpu/gpu_freq_table)" "Select ${1} freq: ") > /sys/kernel/gpu/gpu_${1}_clock
}

gpu_universal_set_gov() {
echo $(fzf_select "$(cat /sys/kernel/gpu/gpu_available_governor)" "Select Governor: ") > /sys/kernel/gpu/gpu_governor
}

mtk_gpu_freq_set() {
export freq=$(fzf_select "$(cat /proc/gpufreq/gpufreq_opp_dump | grep -o 'freq = [0-9]*' | sed 's/freq = //' | sort -n)" "Set frequency for GPU (NO DVFS): ")
export voltage=$(cat /proc/gpufreq/gpufreq_opp_dump | awk -v freq="$freq" '$0 ~ freq {gsub(/.*, volt = /, ""); gsub(/,.*/, ""); print}')
echo $freq $voltage > /proc/gpufreq/gpufreq_fixed_freq_volt
}

mtk_gpu_volt_set() {
if [[ $(cat /proc/gpufreq/gpufreq_fixed_freq_volt) == *disabled* ]]; then
echo -e "\nerror: Set fixed freq first !"
read -r -s
return 1
fi

echo "$(sed -n 2p /proc/gpufreq/gpufreq_fixed_freq_volt | awk '{print $3}' )" "$(fzf_select "$(cat /proc/gpufreq/gpufreq_opp_dump | grep -o 'volt = [0-9]*' | sed 's/volt = //' | sort -n | awk '!seen[$0]++ {print}')" "Select GPU voltage: ")" > /proc/gpufreq/gpufreq_fixed_freq_volt
}

mtk_gpu_reset_dvfs() {
echo 0 0 > /proc/gpufreq/gpufreq_fixed_freq_volt
}

mtk_gpu_mali_power_policy() {
	echo $(fzf_select "$(cat /sys/devices/platform/13040000.mali/power_policy | sed 's/\[//g; s/\]//g')" "Select GPU power policy: ") > /sys/devices/platform/13040000.mali/power_policy
}

mtk_gpu_mali_serialize_jobs() {
	echo $(fzf_select "$(cat /sys/devices/platform/13040000.mali/scheduling/serialize_jobs | sed 's/\(\[[^]]*\]\)\([^[:space:]]\)/\1 \2/g; s/\[\|\]//g')" "Select GPU power policy: ") > /sys/devices/platform/13040000.mali/scheduling/serialize_jobs
}

mtk_ged_dvfs() {
	case $(fzf_select "Enable Disable" "GPU DVFS:  ") in
		Enable) echo 1 > /sys/module/ged/parameters/gpu_dvfs_enable ;;
		Disable) echo 0 > /sys/module/ged/parameters/gpu_dvfs_enable ;;
	esac
}

mtk_ged_boost() {
	case $(fzf_select "Enable Disable" "GED Boosting: ") in
		Enable) echo 1 > /sys/module/ged/parameters/ged_boost_enable ;;
		Disable) echo 0 > /sys/module/ged/parameters/ged_boost_enable ;;
	esac
}

mtk_ged_extra_boost() {
	case $(fzf_select "Enable Disable" "GED Boost extra: ") in
		Enable) echo 1 > /sys/module/ged/parameters/boost_extra ;;
		Disable) echo 0 > /sys/module/ged/parameters/boost_extra ;;
	esac
}

mtk_ged_gpu_boost() {
	case $(fzf_select "Enable Disable" "GED GPU Boost: ") in
		Enable) echo 1 > /sys/module/ged/parameters/boost_gpu_enable ;;
		Disable) echo 0 > /sys/module/ged/parameters/boost_gpu_enable ;;
	esac
}

mtk_ged_game_mode() {
	case $(fzf_select "Enable Disable" "GED Game mode: ") in
		Enable) echo 1 > /sys/module/ged/parameters/gx_game_mode ;;
		Disable) echo 0 > /sys/module/ged/parameters/gx_game_mode ;;
	esac
}

gpu_menu() {

if [[ $is_gpu_unsupported == 1 ]]; then
echo -e "\ninterface (sysfs or procfs) of your GPU is not supported :("
read -r -s
clear && main_menu
fi

	while true; do
        gpu_menu_info="[] Governor: $(cat /sys/kernel/gpu/gpu_governor 2>/dev/null)//[] GPU Scaling freq: $(cat /sys/kernel/gpu/gpu_min_clock 2>/dev/null) - $(cat /sys/kernel/gpu/gpu_max_clock 2>/dev/null)//"
        
        
        if [[ $soc == Mediatek ]]; then
            gpu_menu_info="$(echo $gpu_menu_info)[] Fixed freq & volt: $(cat /proc/gpufreq/gpufreq_fixed_freq_volt | awk '{print $7}') //"
            gpu_menu_options="Set freq (NO DVFS)\nSet voltage (NO DVFS)\nReset DVFS\nGED GPU DVFS\nGED Boost\nGED Extra Boost\nGED GPU boost\nGED Game Mode\n"
        else
            gpu_menu_options="Set Governor\nSet max freq\nSet min freq\n"
        fi
        
        if [[ $soc == Mediatek ]] && [ -d /sys/devices/platform/13040000.mali ]; then
            gpu_menu_info="$(echo $gpu_menu_info)[] Power policy: $(cat /sys/devices/platform/13040000.mali/power_policy | grep -o '\[.*\]' | tr -d '[]')//[] Serialize jobs: $(cat /sys/devices/platform/13040000.mali/scheduling/serialize_jobs | grep -o '\[.*\]' | tr -d '[]')//"
            gpu_menu_options="$(echo $gpu_menu_options)Mali Serialize Job\nMali Power Policy\n"
        fi
        
		if [[ $soc == Mediatek ]] && [ -d /sys/module/ged ]; then
            gpu_menu_info="$(echo $gpu_menu_info)[] Enable GPU DVFS: $(cat /sys/module/ged/parameters/gpu_dvfs_enable)//[ϟ] GED Game mode: $(cat /sys/module/ged/parameters/gx_game_mode)//[ϟ] GED Boosting: $(cat /sys/module/ged/parameters/ged_boost_enable)//"
        fi

		clear
		echo -e "\e[30;48;2;254;228;208;38;2;0;0;0m Origami Kernel Manager v1.0.1$(yes " " | sed $(($LINE - 30))'q' | tr -d '\n')\033[0m"
		echo -e "\e[38;2;254;228;208m"
		echo -e "    _________      [] GPU: ${gpu}" | cut -c 1-${LINE}
		echo -e "   /        /\\     $(echo "$gpu_menu_info" | awk -F '//' '{print $1}')"
		echo -e "  /        /  \\    $(echo "$gpu_menu_info" | awk -F '//' '{print $2}')"
		echo -e " /        /    \\   $(echo "$gpu_menu_info" | awk -F '//' '{print $3}')"
		echo -e "/________/      \\  $(echo "$gpu_menu_info" | awk -F '//' '{print $4}')"
		echo -e "\\        \\      /  $(echo "$gpu_menu_info" | awk -F '//' '{print $5}')"
		echo -e " \\        \\    /   $(echo "$gpu_menu_info" | awk -F '//' '{print $6}')"
		echo -e "  \\        \\  /    $(echo "$gpu_menu_info" | awk -F '//' '{print $7}')"
		echo -e "   \\________\\/     $(echo "$gpu_menu_info" | awk -F '//' '{print $8}')"
		echo -e "\n//////////////"
		echo -e "$(yes "─" | sed ${LINE}'q' | tr -d '\n')\n"
		echo -e "[] GPU Control\033[0m"

		tput civis

		case $(fzy_select "$(echo -e "$gpu_menu_options")\nBack to main menu" "") in
			"Set Governor") cpu_set_gov ;;
			"Set freq (NO DVFS)") mtk_gpu_freq_set ;;
			"Set voltage (NO DVFS)") mtk_gpu_volt_set ;;
			"Reset DVFS") mtk_gpu_reset_dvfs ;;
			"Set max freq") gpu_universal_set_freq max ;;
			"Set min freq") gpu_universal_set_freq min ;;
			"Mali Serialize Job") mtk_gpu_mali_serialize_jobs ;;
			"Mali Power Policy") mtk_gpu_mali_power_policy ;;
			"GED GPU DVFS") mtk_ged_dvfs ;;
			"GED Boost") mtk_ged_boost ;;
			"GED Extra Boost") mtk_ged_extra_boost ;;
			"GED GPU boost") mtk_ged_gpu_boost ;;
			"GED Game Mode") mtk_ged_game_mode ;;
			"Back to main menu") clear && main_menu ;;
		esac
	done
}
