#!/bin/env bash
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
# Copyright (C) 2023-present Rem01Gaming

tcp_congestion_change() {
	if [[ $1 == "-exec" ]]; then
		local selected=$2
	else
		local selected=$(fzf_select "$(cat /proc/sys/net/ipv4/tcp_available_congestion_control)" "Select TCP Congestion: ")
		command2db net.ipv4.tcp_congestion_control "tcp_congestion_change -exec $selected" FALSE
	fi
	apply $selected /proc/sys/net/ipv4/tcp_congestion_control
}

tcp_syncookies() {
	if [[ $1 == "-exec" ]]; then
		local selected=$2
	else
		local selected=$(fzf_select "Enable Disable" "SYN Cookies: ")
		command2db net.ipv4.tcp_syncookies "tcp_syncookies -exec $selected" FALSE
	fi
	case $selected in
	Enable) apply 1 /proc/sys/net/ipv4/tcp_syncookies ;;
	Disable) apply 0 /proc/sys/net/ipv4/tcp_syncookies ;;
	esac
}

tcp_max_syn_backlog() {
	if [[ $1 == "-exec" ]]; then
		apply $2 /proc/sys/net/ipv4/tcp_max_syn_backlog
	else
		menu_value_tune "TCP Max SYN Backlog\ndetermines the maximum number of pending connection requests (SYN requests) that can be held in the queue before the system starts rejecting new connection attempts." /proc/sys/net/ipv4/tcp_max_syn_backlog 32400 128 2
		command2db net.ipv4.tcp_max_syn_backlog "tcp_max_syn_backlog -exec $number" FALSE
	fi
}

tcp_keepalive_time() {
	if [[ $1 == "-exec" ]]; then
		apply $2 /proc/sys/net/ipv4/tcp_keepalive_time
	else
		menu_value_tune "TCP Keepalive time\nDetermine how long a TCP connection should remain idle before the operating system sends a keepalive probe to check if the connection is still active." /proc/sys/net/ipv4/tcp_keepalive_time 32400 128 2
		command2db net.ipv4.tcp_keepalive_time "tcp_keepalive_time -exec $number" FALSE
	fi
}

tcp_reuse_socket() {
	if [[ $1 == "-exec" ]]; then
		local selected=$2
	else
		local selected=$(fzf_select "Enable Disable enable-for-loopback-traffic-only" "TCP Reuse socket: ")
		command2db net.ipv4.tcp_tw_reuse "tcp_reuse_socket -exec $selected" FALSE
	fi
	case $selected in
	Enable) apply 1 /proc/sys/net/ipv4/tcp_tw_reuse ;;
	Disable) apply 0 /proc/sys/net/ipv4/tcp_tw_reuse ;;
	enable-for-loopback-traffic-only) apply 2 /proc/sys/net/ipv4/tcp_tw_reuse ;;
	esac
}

tcp_ecn() {
	if [[ $1 == "-exec" ]]; then
		local selected=$2
	else
		local selected=$(fzf_select "0 1 2" "TCP Explicit Congestion Notification (ECN): ")
		command2db net.ipv4.tcp_ecn "tcp_ecn -exec $selected" FALSE
	fi
	apply $selected /proc/sys/net/ipv4/tcp_ecn
}

tcp_fastopen() {
	if [[ $1 == "-exec" ]]; then
		local selected=$2
	else
		local selected=$(fzf_select "0 1 2 3" "TCP Fastopen (TFO): ")
		command2db net.ipv4.tcp_fastopen "tcp_fastopen -exec $selected" FALSE
	fi
	apply $selected /proc/sys/net/ipv4/tcp_fastopen
}

tcp_sack() {
	if [[ $1 == "-exec" ]]; then
		local selected=$2
	else
		local selected=$(fzf_select "Disable Enable" "TCP Select Acknowledgments (SACK): ")
		command2db net.ipv4.tcp_sack "tcp_sack -exec $selected" FALSE
	fi
	case $selected in
	Disable) apply 0 /proc/sys/net/ipv4/tcp_sack ;;
	Enable) apply 1 /proc/sys/net/ipv4/tcp_sack ;;
	esac
}

tcp_timestamps() {
	if [[ $1 == "-exec" ]]; then
		local selected=$2
	else
		local selected=$(fzf_select "0 1 2" "TCP Timestamps: ")
		command2db net.ipv4.tcp_timestamps "tcp_timestamps -exec $selected" FALSE
	fi
	apply $selected /proc/sys/net/ipv4/tcp_timestamps
}

bpf_jit_harden() {
	if [[ $1 == "-exec" ]]; then
		local selected=$2
	else
		local selected=$(fzf_select "Disable enable-for-unprivileged-users enable-for-all-users" "BPF JIT harden: ")
		command2db net.core.bpf_jit_harden "bpf_jit_harden -exec $selected" FALSE
	fi
	case $selected in
	enable-for-all-users) apply 2 /proc/sys/net/core/bpf_jit_harden ;;
	enable-for-unprivileged-users) apply 1 /proc/sys/net/core/bpf_jit_harden ;;
	Disable) apply 0 /proc/sys/net/core/bpf_jit_harden ;;
	esac
}

net_menu() {
	while true; do
		unset_headvar
		options="Change TCP Congestion algorithm\nTCP Max SYN backlog\nTCP Keep alive time"
		header_info=("[] TCP Congestion: $(cat /proc/sys/net/ipv4/tcp_congestion_control)")
		
		if [ -f /proc/sys/net/ipv4/tcp_syncookies ]; then
			header_info+=("[] TCP SYN Cookies: $(cat /proc/sys/net/ipv4/tcp_syncookies)")
			options="$options\nTCP SYN Cookies"
		fi
		
		if [ -f /proc/sys/net/ipv4/tcp_tw_reuse ]; then
			header_info+=("[] TCP Reuse socket: $(cat /proc/sys/net/ipv4/tcp_tw_reuse)")
			options="$options\nTCP Reuse socket"
		fi
		
		if [ -f /proc/sys/net/ipv4/tcp_ecn ]; then
			header_info+=("[] TCP ECN: $(cat /proc/sys/net/ipv4/tcp_ecn)")
			options="$options\nTCP Explicit Congestion Notification"
		fi
		
		if [ -f /proc/sys/net/ipv4/tcp_fastopen ]; then
			header_info+=("[ϟ] TCP Fastopen: $(cat /proc/sys/net/ipv4/tcp_fastopen)")
			options="$options\nTCP Fastopen"
		fi
		
		if [ -f /proc/sys/net/ipv4/tcp_sack ]; then
			header_info+=("[] TCP SACK: $(cat /proc/sys/net/ipv4/tcp_sack)")
			options="$options\nTCP Select Acknowledgments"
		fi
		
		if [ -f /proc/sys/net/ipv4/tcp_timestamps ]; then
			header_info+=("[] TCP Timestamps: $(cat /proc/sys/net/ipv4/tcp_timestamps)")
			options="$options\nTCP Timestamps"
		fi

		if [ -f /proc/sys/net/core/bpf_jit_harden ]; then
			header_info+=("[] BPF JIT harden: $(cat /proc/sys/net/core/bpf_jit_harden)")
			options="$options\nBPF JIT harden"
		fi

		header "Network Settings"
		selected="$(fzy_select "$options\nBack to main menu" "")"

		case "$selected" in
		"Change TCP Congestion algorithm") tcp_congestion_change ;;
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
