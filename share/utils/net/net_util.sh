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

tcp_congestion_change() {
	apply $(fzf_select "$(cat /proc/sys/net/ipv4/tcp_available_congestion_control)" "Select TCP Congestion: ") /proc/sys/net/ipv4/tcp_congestion_control
}

tcp_low_latency() {
	case $(fzf_select "Enable Disable" "TCP Low latency mode: ") in
	Enable) apply 1 /proc/sys/net/ipv4/tcp_low_latency ;;
	Disable) apply 0 /proc/sys/net/ipv4/tcp_low_latency ;;
	esac
}

tcp_syncookies() {
	case $(fzf_select "Enable Disable" "SYN Cookies: ") in
	Enable) apply 1 /proc/sys/net/ipv4/tcp_syncookies ;;
	Disable) apply 0 /proc/sys/net/ipv4/tcp_syncookies ;;
	esac
}

tcp_max_syn_backlog() {
	menu_value_tune "TCP Max SYN Backlog\ndetermines the maximum number of pending connection requests (SYN requests) that can be held in the queue before the system starts rejecting new connection attempts." /proc/sys/net/ipv4/tcp_max_syn_backlog 32400 128 2
}

tcp_keepalive_time() {
	menu_value_tune "TCP Keepalive time\nDetermine how long a TCP connection should remain idle before the operating system sends a keepalive probe to check if the connection is still active." /proc/sys/net/ipv4/tcp_keepalive_time 32400 128 2
}

tcp_reuse_socket() {
	case $(fzf_select "Enable Disable enable-for-loopback-traffic-only" "TCP Reuse socket: ") in
	Enable) apply 1 /proc/sys/net/ipv4/tcp_tw_reuse ;;
	Disable) apply 0 /proc/sys/net/ipv4/tcp_tw_reuse ;;
	enable-for-loopback-traffic-only) apply 2 /proc/sys/net/ipv4/tcp_tw_reuse ;;
	esac
}

tcp_ecn() {
	case $(fzf_select "0 1 2" "TCP Explicit Congestion Notification (ECN): ") in
	0) apply 0 /proc/sys/net/ipv4/tcp_ecn ;;
	1) apply 1 /proc/sys/net/ipv4/tcp_ecn ;;
	2) apply 2 /proc/sys/net/ipv4/tcp_ecn ;;
	esac
}

tcp_fastopen() {
	case $(fzf_select "0 1 2 3" "TCP Fastopen (TFO): ") in
	0) apply 0 /proc/sys/net/ipv4/tcp_fastopen ;;
	1) apply 1 /proc/sys/net/ipv4/tcp_fastopen ;;
	2) apply 2 /proc/sys/net/ipv4/tcp_fastopen ;;
	3) apply 3 /proc/sys/net/ipv4/tcp_fastopen ;;
	esac
}

tcp_sack() {
	case $(fzf_select "Disable Enable" "TCP Select Acknowledgments (SACKS): ") in
	Disable) apply 0 /proc/sys/net/ipv4/tcp_sack ;;
	Enable) apply 1 /proc/sys/net/ipv4/tcp_sack ;;
	esac
}

tcp_timestamps() {
	case $(fzf_select "0 1 2" "TCP Timestamps: ") in
	0) apply 0 /proc/sys/net/ipv4/tcp_timestamps ;;
	1) apply 1 /proc/sys/net/ipv4/tcp_timestamps ;;
	2) apply 2 /proc/sys/net/ipv4/tcp_timestamps ;;
	esac
}

bpf_jit_harden() {
	case $(fzf_select "Disable enable-for-unprivileged-users enable-for-all-users" "BPF JIT harden: ") in
	enable-for-all-users) apply 2 /proc/sys/net/core/bpf_jit_harden ;;
	enable-for-unprivileged-users) apply 1 /proc/sys/net/core/bpf_jit_harden ;;
	Disable) apply 0 /proc/sys/net/core/bpf_jit_harden ;;
	esac
}

net_menu() {
	while true; do
		clear
		echo -e "\e[30;48;2;254;228;208;38;2;0;0;0m Origami Kernel Manager ${VERSION}$(yes " " | sed $((LINE - 30))'q' | tr -d '\n')\033[0m"
		echo -e "\e[38;2;254;228;208m"
		echo -e "    _________      [] TCP Congestion: $(cat /proc/sys/net/ipv4/tcp_congestion_control)" | cut -c 1-${LINE}
		echo -e "   /        /\\     [ϟ] TCP Low Latency: $(cat /proc/sys/net/ipv4/tcp_low_latency)"
		echo -e "  /        /  \\    [] TCP SYN Cookies: $(cat /proc/sys/net/ipv4/tcp_syncookies)"
		echo -e " /        /    \\   [] BPF JIT harden: $(cat /proc/sys/net/core/bpf_jit_harden)"
		echo -e "/________/      \\  [] TCP Reuse socket: $(cat /proc/sys/net/ipv4/tcp_tw_reuse)"
		echo -e "\\        \\      /  [] TCP ECN: $(cat /proc/sys/net/ipv4/tcp_ecn)"
		echo -e " \\        \\    /   [ϟ] TCP Fastopen: $(cat /proc/sys/net/ipv4/tcp_fastopen)"
		echo -e "  \\        \\  /    [] TCP SACK: $(cat /proc/sys/net/ipv4/tcp_sack)"
		echo -e "   \\________\\/     [] TCP Timestamps: $(cat /proc/sys/net/ipv4/tcp_timestamps)"
		echo -e "\n//////////////"
		echo -e "$(yes "─" | sed ${LINE}'q' | tr -d '\n')\n"
		echo -e "[] Networking Settings\033[0m"

		tput civis

		case $(fzy_select "Change TCP Congestion algorithm\nTCP Low latency mode\nTCP SYN Cookies\nTCP Max SYN backlog\nTCP Keep alive time\nTCP Reuse socket\nTCP Explicit Congestion Notification\nTCP Fastopen\nTCP Select Acknowledgments\nTCP Timestamps\nBPF JIT harden\nBack to main menu" "") in
		"Change TCP Congestion algorithm") tcp_congestion_change ;;
		"TCP Low latency mode") tcp_low_latency ;;
		"TCP SYN Cookies") tcp_syncookies ;;
		"TCP Max SYN backlog") tcp_max_syn_backlog ;;
		"TCP Keep alive time") tcp_keepalive_time ;;
		"TCP Reuse socket") tcp_reuse_socket ;;
		"TCP Explicit Congestion Notification") tcp_ecn ;;
		"TCP Fastopen") tcp_fastopen ;;
		"TCP Select Acknowledgments") tcp_sack ;;
		"TCP Timestamps") tcp_timestamps ;;
		"BPF JIT harden") bpf_jit_harden ;;
		"Back to main menu") break ;;
		esac
	done
}
