#!/usr/bin/env bash

# System utility shell functions
# A collection of useful system administration and monitoring functions

#######################################
# Check if a service is running
# Dependencies: systemctl or service
# Arguments:
#   Service name
# Returns:
#   Service status
#######################################
function CheckService() {
  local _service="$1"

  if [[ -z "$_service" ]]; then
    echo "Usage: CheckService <service-name>"
    return 1
  fi

  if command -v systemctl &> /dev/null; then
    if systemctl is-active --quiet "$_service"; then
      echo "Service '$_service' is RUNNING"
      systemctl status "$_service" --no-pager -l
    else
      echo "Service '$_service' is NOT running"
      return 1
    fi
  elif command -v service &> /dev/null; then
    service "$_service" status
  else
    echo "Neither 'systemctl' nor 'service' command found"
    return 1
  fi
}

#######################################
# Find processes by name
# Arguments:
#   Process name pattern
# Returns:
#   List of matching processes
#######################################
function FindProcess() {
  local _pattern="$1"

  if [[ -z "$_pattern" ]]; then
    echo "Usage: FindProcess <pattern>"
    return 1
  fi

  echo "Processes matching '$_pattern':"
  ps aux | grep -i "$_pattern" | grep -v grep
}

#######################################
# Get memory usage of a process
# Arguments:
#   Process name or PID
# Returns:
#   Memory usage information
#######################################
function ProcessMemory() {
  local _process="$1"

  if [[ -z "$_process" ]]; then
    echo "Usage: ProcessMemory <process-name-or-pid>"
    return 1
  fi

  if [[ "$_process" =~ ^[0-9]+$ ]]; then
    # It's a PID
    ps -p "$_process" -o pid,vsz,rss,comm | awk 'NR==1 {print $0} NR>1 {printf "%s\t%sMB\t%sMB\t%s\n", $1, $2/1024, $3/1024, $4}'
  else
    # It's a process name
    ps aux | grep -i "$_process" | grep -v grep | awk '{printf "PID: %s\tVSZ: %sMB\tRSS: %sMB\tCMD: %s\n", $2, $5/1024, $6/1024, $11}'
  fi
}

#######################################
# Show top 10 memory consuming processes
# Returns:
#   Top 10 processes by memory usage
#######################################
function TopMemory() {
  echo "Top 10 processes by memory usage:"
  ps aux --sort=-%mem | head -11 | awk 'NR==1 {print $0} NR>1 {printf "%s\t%s%%\t%s%%\t%sMB\t%s\n", $2, $3, $4, $6/1024, $11}'
}

#######################################
# Show top 10 CPU consuming processes
# Returns:
#   Top 10 processes by CPU usage
#######################################
function TopCPU() {
  echo "Top 10 processes by CPU usage:"
  ps aux --sort=-%cpu | head -11 | awk 'NR==1 {print $0} NR>1 {printf "%s\t%s%%\t%s%%\t%sMB\t%s\n", $2, $3, $4, $6/1024, $11}'
}

#######################################
# Show disk usage summary
# Returns:
#   Disk usage by filesystem
#######################################
function DiskUsage() {
  echo "Disk Usage Summary:"
  df -h | grep -v tmpfs | grep -v devtmpfs
}

#######################################
# Find largest directories
# Arguments:
#   $1 - Path to search (default: current directory)
#   $2 - Number of results (default: 10)
# Returns:
#   Largest directories
#######################################
function LargestDirs() {
  local _path="${1:-.}"
  local _count="${2:-10}"

  echo "Top $_count largest directories in $_path:"
  du -h "$_path" 2>/dev/null | sort -rh | head -n "$_count"
}

#######################################
# Find largest files
# Arguments:
#   $1 - Path to search (default: current directory)
#   $2 - Number of results (default: 10)
# Returns:
#   Largest files
#######################################
function LargestFiles() {
  local _path="${1:-.}"
  local _count="${2:-10}"

  echo "Top $_count largest files in $_path:"
  find "$_path" -type f -exec du -h {} + 2>/dev/null | sort -rh | head -n "$_count"
}

#######################################
# System information summary
# Returns:
#   System information
#######################################
function SysInfo() {
  echo "=== System Information ==="
  echo "Hostname: $(hostname)"
  echo "Kernel: $(uname -r)"
  echo "OS: $(cat /etc/os-release 2>/dev/null | grep PRETTY_NAME | cut -d'"' -f2)"
  echo "Uptime: $(uptime -p 2>/dev/null || uptime)"
  echo "CPU: $(grep "model name" /proc/cpuinfo 2>/dev/null | head -1 | cut -d':' -f2 | xargs)"
  echo "CPU Cores: $(nproc 2>/dev/null || grep -c processor /proc/cpuinfo)"
  echo "Total RAM: $(free -h 2>/dev/null | awk '/^Mem:/ {print $2}')"
  echo "Used RAM: $(free -h 2>/dev/null | awk '/^Mem:/ {print $3}')"
  echo "Load Average: $(cat /proc/loadavg 2>/dev/null | cut -d' ' -f1-3)"
}

#######################################
# Check system load and alert if high
# Arguments:
#   Threshold (default: 80% CPU)
# Returns:
#   System load status
#######################################
function CheckLoad() {
  local _threshold="${1:-80}"
  local _cpus=$(nproc)
  local _load=$(cat /proc/loadavg | cut -d' ' -f1)
  local _load_pct=$(echo "scale=2; $_load / $_cpus * 100" | bc)

  echo "Current load: $_load (${_load_pct}% on $_cpus cores)"
  
  if (( $(echo "$_load_pct > $_threshold" | bc -l) )); then
    echo "⚠ WARNING: High system load!"
    return 1
  else
    echo "✓ System load is normal"
    return 0
  fi
}

#######################################
# Monitor a log file in real-time with filtering
# Arguments:
#   $1 - Log file path
#   $2 - Filter pattern (optional)
# Returns:
#   Filtered log output
#######################################
function MonitorLog() {
  local _logfile="$1"
  local _pattern="$2"

  if [[ -z "$_logfile" ]]; then
    echo "Usage: MonitorLog <logfile> [pattern]"
    return 1
  fi

  if [[ ! -f "$_logfile" ]]; then
    echo "Error: Log file '$_logfile' not found"
    return 1
  fi

  if [[ -n "$_pattern" ]]; then
    echo "Monitoring $_logfile for pattern: $_pattern (Ctrl+C to stop)"
    tail -f "$_logfile" | grep --line-buffered "$_pattern"
  else
    echo "Monitoring $_logfile (Ctrl+C to stop)"
    tail -f "$_logfile"
  fi
}

#######################################
# Quick backup of a file with timestamp
# Arguments:
#   File path
# Returns:
#   Backup file path
#######################################
function QuickBackup() {
  local _file="$1"

  if [[ -z "$_file" ]]; then
    echo "Usage: QuickBackup <file>"
    return 1
  fi

  if [[ ! -f "$_file" ]]; then
    echo "Error: File '$_file' not found"
    return 1
  fi

  local _timestamp=$(date +%Y%m%d_%H%M%S)
  local _backup="${_file}.backup_${_timestamp}"
  
  cp "$_file" "$_backup"
  echo "Backup created: $_backup"
}

#######################################
# Check for zombie processes
# Returns:
#   List of zombie processes
#######################################
function CheckZombies() {
  local _zombies=$(ps aux | awk '$8=="Z" {print $0}')
  
  if [[ -z "$_zombies" ]]; then
    echo "No zombie processes found"
  else
    echo "Zombie processes found:"
    echo "$_zombies"
  fi
}

#######################################
# Show logged in users
# Returns:
#   List of logged in users
#######################################
function ShowUsers() {
  echo "Currently logged in users:"
  w
}

#######################################
# Check available disk inodes
# Returns:
#   Inode usage by filesystem
#######################################
function CheckInodes() {
  echo "Inode usage:"
  df -i | grep -v tmpfs | grep -v devtmpfs
}
