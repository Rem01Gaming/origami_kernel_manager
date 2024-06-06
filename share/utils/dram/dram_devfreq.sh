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

dram_devfreq_set_freq() {
	apply $(fzf_select "$(cat ${dram_devfreq_path}/available_frequencies)" "Select ${1} freq: ") ${dram_devfreq_path}/${1}_freq
}

dram_devfreq_set_gov() {
	apply $(fzf_select "$(cat ${dram_devfreq_path}/available_governors)" "Select Governor: ") ${dram_devfreq_path}/governor
}

dram_devfreq_menu() {
	while true; do
		clear
		echo -e "\e[30;48;2;254;228;208;38;2;0;0;0m Origami Kernel Manager ${VERSION}$(yes " " | sed $((LINE - 30))'q' | tr -d '\n')\033[0m"
		echo -e "\e[38;2;254;228;208m"
		echo -e "    _________      [] DRAM Scalling freq: $(cat ${dram_devfreq_path}/max_freq)KHz - $(cat ${dram_devfreq_path}/min_freq)KHz" | cut -c 1-${LINE}
		echo -e "   /        /\\     [] DRAM Governor: $(cat ${dram_devfreq_path}/governor)"
		echo -e "  /        /  \\    "
		echo -e ' /        /    \   '
		echo -e '/________/      \  '
		echo -e '\        \      /  '
		echo -e ' \        \    /   '
		echo -e '  \        \  /    '
		echo -e '   \________\/     '
		echo -e "\n//////////////"
		echo -e "$(yes "─" | sed ${LINE}'q' | tr -d '\n')\n"
		echo -e "[] DRAM Control\033[0m"

		tput civis

		case $(fzy_select "Set max freq\nSet min freq\nSet Governor\nBack to main menu" "") in
		"Set max freq") dram_devfreq_set_freq max ;;
		"Set min freq") dram_devfreq_set_freq min ;;
		"Set Governor") dram_devfreq_set_gov ;;
		"Back to main menu") break ;;
		esac

		unset dram_menu_info dram_menu_options
	done
}
