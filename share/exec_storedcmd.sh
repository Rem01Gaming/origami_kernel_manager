#!/data/data/com.termux/files/usr/bin/origami-sudo bash
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

execstoredcmd_allow_risky="$(sql_query "SELECT execstoredcmd_risky FROM tb_info;")"

execstoredcmd() {
	while IFS='|' read -r command risky; do
		if [ "$risky" -eq 1 ] && [ "$execstoredcmd_allow_risky" -eq 1 ]; then
			eval "$command"
		elif [ "$risky" -eq 0 ]; then
			eval "$command"
		fi
	done < <(sql_query "SELECT command, risky FROM tb_storecmd;")
}

init_execstoredcmd() {
	read -r -p "Apply previous settings? [Y/n]: " input
	case $input in
	[Yy]*)
		echo "Applying settings..."
		execstoredcmd
		;;
	esac
}
