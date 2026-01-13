#!/usr/bin/env bash

# Docker helper shell functions
# A collection of useful Docker shortcuts and utilities

#######################################
# Stop all running containers
# Returns:
#   Stopped container IDs
#######################################
function DockerStopAll() {
  local _containers=$(docker ps -q)
  
  if [[ -z "$_containers" ]]; then
    echo "No running containers"
    return 0
  fi

  docker stop $_containers
  echo "All containers stopped"
}

#######################################
# Remove all stopped containers
# Returns:
#   Removed container count
#######################################
function DockerClean() {
  echo "Removing stopped containers..."
  docker container prune -f
  echo "Removing unused images..."
  docker image prune -f
  echo "Removing unused volumes..."
  docker volume prune -f
  echo "Cleanup complete"
}

#######################################
# Show container resource usage
# Returns:
#   Container stats
#######################################
function DockerStats() {
  docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}"
}

#######################################
# Get shell access to container
# Arguments:
#   Container name or ID
# Returns:
#   Shell session in container
#######################################
function DockerShell() {
  local _container="$1"

  if [[ -z "$_container" ]]; then
    echo "Usage: DockerShell <container-name-or-id>"
    return 1
  fi

  if docker exec -it "$_container" bash 2>/dev/null; then
    return 0
  elif docker exec -it "$_container" sh 2>/dev/null; then
    return 0
  else
    echo "Failed to access shell in container '$_container'"
    return 1
  fi
}

#######################################
# Show container logs with tail
# Arguments:
#   $1 - Container name or ID
#   $2 - Number of lines (default: 50)
# Returns:
#   Container logs
#######################################
function DockerLogs() {
  local _container="$1"
  local _lines="${2:-50}"

  if [[ -z "$_container" ]]; then
    echo "Usage: DockerLogs <container-name-or-id> [lines]"
    return 1
  fi

  docker logs --tail "$_lines" -f "$_container"
}

#######################################
# List images sorted by size
# Returns:
#   Sorted image list
#######################################
function DockerImages() {
  docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}" | sort -k3 -h
}

#######################################
# Remove dangling images
# Returns:
#   Removal status
#######################################
function DockerCleanDangling() {
  local _dangling_images
  _dangling_images=$(docker images -f "dangling=true" -q)

  if [[ -z "$_dangling_images" ]]; then
    echo "No dangling images found"
    return 0
  fi

  echo "Removing dangling images..."
  if docker rmi $_dangling_images 2>/dev/null; then
    echo "Dangling images removed"
  else
    echo "Failed to remove some dangling images"
    return 1
  fi
}

#######################################
# Show Docker disk usage
# Returns:
#   Docker disk usage summary
#######################################
function DockerDiskUsage() {
  docker system df -v
}

#######################################
# Backup container data volume
# Arguments:
#   $1 - Container name
#   $2 - Volume path
#   $3 - Backup destination (default: current directory)
# Returns:
#   Backup status
#######################################
function DockerBackup() {
  local _container="$1"
  local _volume="$2"
  local _dest="${3:-.}"

  if [[ -z "$_container" ]] || [[ -z "$_volume" ]]; then
    echo "Usage: DockerBackup <container> <volume-path> [destination]"
    return 1
  fi

  local _timestamp=$(date +%Y%m%d_%H%M%S)
  local _backup="${_dest}/backup_${_container}_${_timestamp}.tar.gz"

  docker run --rm --volumes-from "$_container" -v "${_dest}":/backup ubuntu tar czf "/backup/$(basename "$_backup")" "$_volume"
  
  if [[ $? -eq 0 ]]; then
    echo "Backup created: $_backup"
  else
    echo "Backup failed"
    return 1
  fi
}

#######################################
# Monitor Docker events
# Returns:
#   Live Docker events
#######################################
function DockerWatch() {
  docker events --format '{{.Time}} {{.Type}} {{.Action}} {{.Actor.Attributes.name}}'
}

#######################################
# List all container IPs
# Returns:
#   Container names and IP addresses
#######################################
function DockerIPs() {
  docker ps -q | xargs -n 1 docker inspect --format '{{.Name}} - {{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' | sed 's/^\///'
}

#######################################
# Compare two images
# Arguments:
#   $1 - First image
#   $2 - Second image
# Returns:
#   Image differences
#######################################
function DockerDiff() {
  local _image1="$1"
  local _image2="$2"

  if [[ -z "$_image1" ]] || [[ -z "$_image2" ]]; then
    echo "Usage: DockerDiff <image1> <image2>"
    return 1
  fi

  echo "=== Comparing $_image1 and $_image2 ==="
  
  local _tmp1
  local _tmp2

  _tmp1=$(mktemp) || { echo "Error: failed to create temporary file for $_image1" >&2; return 1; }
  _tmp2=$(mktemp) || { echo "Error: failed to create temporary file for $_image2" >&2; rm -f "$_tmp1"; return 1; }

  docker history "$_image1" > "$_tmp1"
  docker history "$_image2" > "$_tmp2"
  diff "$_tmp1" "$_tmp2"
  rm -f "$_tmp1" "$_tmp2"
}

#######################################
# Get container inspect information
# Arguments:
#   Container name or ID
# Returns:
#   Formatted container info
#######################################
function DockerInfo() {
  local _container="$1"

  if [[ -z "$_container" ]]; then
    echo "Usage: DockerInfo <container-name-or-id>"
    return 1
  fi

  if command -v jq &> /dev/null; then
    docker inspect "$_container" | jq '.[0] | {
      Name: .Name,
      State: .State.Status,
      Image: .Config.Image,
      IPAddress: .NetworkSettings.IPAddress,
      Ports: .NetworkSettings.Ports,
      Mounts: .Mounts
    }'
  else
    echo "Container information for: $_container"
    docker inspect "$_container"
  fi
}

#######################################
# Export container to image
# Arguments:
#   $1 - Container name
#   $2 - Image name
# Returns:
#   Export status
#######################################
function DockerExport() {
  local _container="$1"
  local _image="$2"

  if [[ -z "$_container" ]] || [[ -z "$_image" ]]; then
    echo "Usage: DockerExport <container> <image-name>"
    return 1
  fi

  docker commit "$_container" "$_image"
  echo "Container exported to image: $_image"
}
