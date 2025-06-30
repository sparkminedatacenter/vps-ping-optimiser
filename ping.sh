#!/usr/bin/env bash

Author: adamhaton

Ubuntu 22.04 Low-Latency Network Optimization Setup

This script installs dependencies, applies kernel & NIC tuning, and stabilizes latency.

Color definitions

YELLOW=$(tput setaf 3) GREEN=$(tput setaf 2) RESET=$(tput sgr0)

Spinner characters

SPIN_CHARS=("|" "/" "-" "\")

Function to show spinner during background tasks

spinner() { local pid=$1 local delay=0.1 while kill -0 "$pid" 2>/dev/null; do for c in "${SPIN_CHARS[@]}"; do echo -ne "\r${YELLOW}⟳ applying network optimisation and stabilizing latency ${c}${RESET}" sleep $delay done done echo -e "\r${GREEN}✔ Optimization completed!            ${RESET}\n" }

Prompt for ping optimizer

read -p "Do you want to run ping optimizer? [Y/n] " answer case "$answer" in [Nn] ) echo "Exiting without changes."; exit 0; ;;

) echo "Proceeding with optimization..."; ;; esac


Run dependencies installation silently

install_dependencies() { apt-get update -qq apt-get install -y -qq ethtool irqbalance } install_dependencies & deps_pid=$! spinner "$deps_pid"

Main optimization function

run_optimization() {

Sysctl tuning

sysctl -w net.core.default_qdisc=fq sysctl -w net.ipv4.tcp_congestion_control=bbr sysctl -w net.ipv4.tcp_fastopen=3 sysctl -w net.core.rmem_max=16777216 sysctl -w net.core.wmem_max=16777216 sysctl -w net.core.rmem_default=262144 sysctl -w net.core.wmem_default=262144 sysctl -w net.core.somaxconn=4096 sysctl -w net.ipv4.tcp_max_syn_backlog=8192 sysctl -w net.ipv4.tcp_syncookies=1 sysctl -w net.ipv4.ip_local_port_range="2000 65535" sysctl -w net.ipv4.tcp_fin_timeout=15 sysctl -w net.ipv4.tcp_tw_reuse=1 sysctl -w net.ipv4.tcp_tw_recycle=0 sysctl -w net.ipv4.tcp_window_scaling=1 sysctl -w net.ipv4.tcp_sack=1 sysctl -w net.ipv4.tcp_dsack=1 sysctl -w net.ipv4.tcp_ecn=1 sysctl -w net.ipv4.tcp_no_metrics_save=1 sysctl -w net.ipv4.tcp_notsent_lowat=131072 sysctl --system

Persist settings

cat <<EOF >> /etc/sysctl.d/99-gaming.conf net.core.default_qdisc=fq net.ipv4.tcp_congestion_control=bbr net.ipv4.tcp_fastopen=3 net.core.rmem_max=16777216 net.core.wmem_max=16777216 net.core.rmem_default=262144 net.core.wmem_default=262144 net.core.somaxconn=4096 net.ipv4.tcp_max_syn_backlog=8192 net.ipv4.tcp_syncookies=1 net.ipv4.ip_local_port_range=2000 65535 net.ipv4.tcp_fin_timeout=15 net.ipv4.tcp_tw_reuse=1 net.ipv4.tcp_tw_recycle=0 net.ipv4.tcp_window_scaling=1 net.ipv4.tcp_sack=1 net.ipv4.tcp_dsack=1 net.ipv4.tcp_ecn=1 net.ipv4.tcp_no_metrics_save=1 net.ipv4.tcp_notsent_lowat=131072 EOF

Disable NIC offloading (update eth0 if needed)

ethtool -K eth0 gro off ethtool -K eth0 gso off ethtool -K eth0 tso off ethtool -K eth0 lro off

Enable IRQ balancing & set CPU governor to performance

systemctl enable --now irqbalance echo performance | tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor > /dev/null }

Execute optimization with spinner

run_optimization & opt_pid=$! spinner "$opt_pid"

Exit script

exit 0

