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

database_path="/data/origami-kernel/okm.db"

sql_query() {
	echo "$1" | sqlite3 $database_path
}

if [ ! -f $database_path ]; then
	sql_query "CREATE TABLE tb_storecmd (id TEXT PRIMARY KEY, command TEXT NOT NULL, risky BOOLEAN NOT NULL);"
	sql_query "CREATE TABLE tb_info (risk_acceptence BOOLEAN NOT NULL, execstoredcmd BOOLEAN NOT NULL, execstoredcmd_risky BOOLEAN NOT NULL);"
	sql_query "INSERT INTO tb_info (risk_acceptence, execstoredcmd, execstoredcmd_risky) VALUES (FALSE, FALSE, FALSE);"
	sql_query "PRAGMA auto_vacuum = FULL;"
fi

risk_acceptence() {
	sql_query "SELECT risk_acceptence FROM tb_info;"
}

accept_risk() {
	sql_query "UPDATE tb_info SET risk_acceptence = TRUE;"
}

execstoredcmd_db() {
	sql_query "UPDATE tb_info SET execstoredcmd = $1;"
}

execstoredcmd_risky_db() {
	sql_query "UPDATE tb_info SET execstoredcmd_risky = $1;"
}

# usage: command2db "identifier" "command" "risky (boolean)"
command2db() {
	if [ -f /dev/okm-execstoredcmd ]; then
		sql_query "INSERT INTO tb_storecmd (id, command, risky) VALUES ('$1', '$2', $3) ON CONFLICT(id) DO UPDATE SET command='$2', risky=$3;"
	fi
}
