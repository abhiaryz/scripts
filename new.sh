#!/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
function getOS() {
	if [ -f /etc/lsb-release ]; then
		os_name=$(lsb_release -s -d)
	elif [ -f /etc/debian_version ]; then
		os_name="Debian $(cat /etc/debian_version)"
	elif [ -f /etc/redhat-release ]; then
		os_name=`cat /etc/redhat-release`
	else
		os_name="$(cat /etc/*release | grep '^PRETTY_NAME=\|^NAME=\|^DISTRIB_ID=' | awk -F\= '{print $2}' | tr -d '"' | tac)"
		if [ -z "$os_name" ]; then
			os_name="$(uname -s)"
		fi
	fi
	echo "$os_name"
}

function cpuSpeed() {
	cpu_speed=$(cat /proc/cpuinfo | grep 'cpu MHz' | awk -F\: '{print $2}' | uniq)
	if [ -z "$cpu_speed" ]; then
		cpu_speed=$(lscpu | grep 'CPU MHz' | awk -F\: '{print $2}' | sed -e 's/^ *//g' -e 's/ *$//g')
	fi
	echo "$cpu_speed"
}

function pingLatency() {
	ping_google="$(ping -B -w 2 -n -c 2 google.com | grep rtt | awk -F '/' '{print $5}')"
	echo "$ping_google"
}

function defaultInterface() {
	interface="$(ip route get 4.2.2.1 | grep dev | awk -F'dev' '{print $2}' | awk '{print $1}')"
	if [ -z $interface ]; then
		interface="$(ip link show | grep 'eth[0-9]' | awk '{print $2}' | tr -d ':' | head -n1)"
	fi
	echo "$interface"
}

function activeConnections() {
	if [ -n "$(command -v ss)" ]; then
		active_connections="$(ss -tun | tail -n +2 | wc -l)"
	else
		active_connections="$(netstat -tun | tail -n +3 | wc -l)"
	fi
	echo "$active_connections"
}


hostname=$(hostname)
kernel=$(uname -r)
time=$(date +%s)
os=$(getOS)
os_arch=`uname -m`","`uname -p`
cpu_model=$(cat /proc/cpuinfo | grep 'model name' | awk -F\: '{print $2}' | uniq)
cpu_cores=$(cat /proc/cpuinfo | grep processor | wc -l)
cpu_speed=$(cpuSpeed)
cpu_load_1=$(cat /proc/loadavg | awk '{print $1}')
cpu_load_2=$(cat /proc/loadavg | awk '{print $2}')
cpu_load_3=$(cat /proc/loadavg | awk '{print $3}')
ram_total=$(free | grep ^Mem: | awk '{print $2}')
ram_usage=$(free | grep ^Mem: | awk '{print $3}')
ram_free=$(free | grep ^Mem: | awk '{print $4}')
ram_caches=$(free | grep ^Mem: | awk '{print $6}')
ram_buffers=0
swap_total=$(cat /proc/meminfo | grep ^SwapTotal: | awk '{print $2}')
swap_free=$(cat /proc/meminfo | grep ^SwapFree: | awk '{print $2}')
swap_usage=$(($swap_total-$swap_free))


file_descriptors_1=$(cat /proc/sys/fs/file-nr | awk '{print $1}')
file_descriptors_2=$(cat /proc/sys/fs/file-nr | awk '{print $2}')
file_descriptors_3=$(cat /proc/sys/fs/file-nr | awk '{print $3}')

ssh_sessions=$(who | wc -l)
uptime=$(cat /proc/uptime | awk '{print $1}')
default_interface=$(defaultInterface)
active_connections=$(activeConnections)
ping_latency=$(pingLatency)

all_interfaces=$(tail -n +3 /proc/net/dev | tr ":" " " | awk '{print $1","$2","$10","$3","$11";"}' | tr -d ':' | tr -d '\n')
sleep 1s
all_interfaces_current=$(tail -n +3 /proc/net/dev | tr ":" " " | awk '{print $1","$2","$10","$3","$11";"}' | tr -d ':' | tr -d '\n')
ipv4_addresses=$(ip -f inet -o addr show | awk '{split($4,a,"/"); print $2","a[1]";"}' | tr -d '\n')
ipv6_addresses=$(ip -f inet6 -o addr show | awk '{split($4,a,"/"); print $2","a[1]";"}' | tr -d '\n')

disks=$(df -P -T -B 1k | grep '^/' | awk '{print $1","$2","$3","$4","$5","$6","$7";"}' | tr -d '\n')
disks_inodes=$(df -P -i | grep '^/' | awk '{print $1","$2","$3","$4","$5","$6";"}' | tr -d '\n')

cpu_info=$(grep -i cpu /proc/stat | awk '{print $1","$2","$3","$4","$5","$6","$7","$8","$9","$10","$11";"}' | tr -d '\n')
sleep 1s
cpu_info_current=$(grep -i cpu /proc/stat | awk '{print $1","$2","$3","$4","$5","$6","$7","$8","$9","$10","$11";"}' | tr -d '\n')



echo -e "{\"hostname\":\""$hostname"\", \"kernal\":\""$kernel"\", \"time\":\""$time"\" , \"os\":\""$os"\",\"os_arch\":\""$os_arch"\",\"cpu_model\":\""$cpu_model"\",\"cpu_core\":\""$cpu_cores"\",\"cpu_load_1\":\""$cpu_load_1"\",\"cpu_load_2\":\""$cpu_load_2"\",\"cpu_load_3\":\""$cpu_load_3"\",\"ram_total\":\""$ram_total"\",\"ram_usage\":\""$ram_usage"\",\"ram_free\":\""$ram_free"\",\"ram_caches\":\""$ram_caches"\",\"ram_buffer\":\""$ram_buffers"\",\"swap_total\":\""$swap_total"\",\"swap_usage\":\""$swap_usage"\",\"swap_free\":\""$swap_free"\",\"file_descriptors_1\":\""$file_descriptors_1"\",\"file_descriptors_2\":\""$file_descriptors_2"\",\"file_descriptors_3\":\""$file_descriptors_3"\",\"ssh_sessions\":\""$ssh_sessions"\",\"uptime\":\""$uptime"\",\"default_interface\":\""$default_interface"\",\"active_connections\":\""$active_connections"\",\"ping_latency\":\""$ping_latency"\",\"all_interfaces\":\""$all_interfaces"\",\"all_interfaces_current\":\""$all_interfaces_current"\",\"ipv4_addresses\":\""$ipv4_addresses"\",\"ipv6_addresses\":\""$ipv6_addresses"\",\"disks\":\""$disks"\",\"disks_inodes\":\""$disks_inodes"\",\"cpu_info\":\""$cpu_info"\",\"cpu_info_current\":\""$cpu_info_current"\"}"
exit