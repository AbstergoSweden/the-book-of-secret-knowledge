#!/usr/bin/env bash

# File operation shell functions
# A collection of useful file manipulation and search functions

#######################################
# Find duplicate files by content (MD5)
# Arguments:
#   Directory path (default: current directory)
# Returns:
#   List of duplicate files
#######################################
function FindDuplicates() {
  local _dir="${1:-.}"

  if [[ ! -d "$_dir" ]]; then
    echo "Error: Directory '$_dir' not found"
    return 1
  fi

  echo "Searching for duplicate files in $_dir..."
  find "$_dir" -type f -exec md5sum {} + 2>/dev/null | sort | uniq -w32 -D
}

#######################################
# Find files modified in the last N days
# Arguments:
#   $1 - Number of days
#   $2 - Directory path (default: current directory)
# Returns:
#   List of modified files
#######################################
function FindModified() {
  local _days="$1"
  local _dir="${2:-.}"

  if [[ -z "$_days" ]]; then
    echo "Usage: FindModified <days> [directory]"
    return 1
  fi

  echo "Files modified in the last $_days days in $_dir:"
  find "$_dir" -type f -mtime -"$_days" -ls 2>/dev/null
}

#######################################
# Find files larger than specified size
# Arguments:
#   $1 - Size (e.g., 100M, 1G)
#   $2 - Directory path (default: current directory)
# Returns:
#   List of large files
#######################################
function FindLarge() {
  local _size="$1"
  local _dir="${2:-.}"

  if [[ -z "$_size" ]]; then
    echo "Usage: FindLarge <size> [directory]"
    echo "Example: FindLarge 100M /var"
    return 1
  fi

  echo "Files larger than $_size in $_dir:"
  find "$_dir" -type f -size +"$_size" -exec ls -lh {} \; 2>/dev/null | awk '{print $9 " (" $5 ")"}'
}

#######################################
# Bulk rename files with pattern replacement
# Arguments:
#   $1 - Search pattern
#   $2 - Replace pattern
#   $3 - Directory (default: current directory)
# Returns:
#   List of renamed files
#######################################
function BulkRename() {
  local _search="$1"
  local _replace="$2"
  local _dir="${3:-.}"
  local _search_escaped
  local _replace_escaped

  if [[ -z "$_search" ]] || [[ -z "$_replace" ]]; then
    echo "Usage: BulkRename <search-pattern> <replace-pattern> [directory]"
    return 1
  fi

  # Escape characters in the search pattern that are special in sed regex and as delimiters
  _search_escaped=$(printf '%s\n' "$_search" | sed 's/[.\\[\*^$&/]/\\&/g')
  # Escape characters in the replacement pattern that are special in sed replacements and as delimiters
  _replace_escaped=$(printf '%s\n' "$_replace" | sed 's/[&/\\]/\\&/g')

  echo "Renaming files in $_dir (replacing '$_search' with '$_replace'):"
  
  find "$_dir" -maxdepth 1 -type f -name "*${_search}*" | while read -r file; do
    local newname
    newname=$(echo "$file" | sed "s/${_search_escaped}/${_replace_escaped}/")
    if [[ "$file" != "$newname" ]]; then
      echo "$file -> $newname"
      mv "$file" "$newname"
    fi
  done
}

#######################################
# Archive directory with timestamp
# Arguments:
#   Directory to archive
# Returns:
#   Archive file path
#######################################
function ArchiveDir() {
  local _dir="$1"

  if [[ -z "$_dir" ]]; then
    echo "Usage: ArchiveDir <directory>"
    return 1
  fi

  if [[ ! -d "$_dir" ]]; then
    echo "Error: Directory '$_dir' not found"
    return 1
  fi

  local _timestamp=$(date +%Y%m%d_%H%M%S)
  local _dirname=$(basename "$_dir")
  local _archive="${_dirname}_${_timestamp}.tar.gz"
  
  tar -czf "$_archive" "$_dir" 2>/dev/null
  
  if [[ $? -eq 0 ]]; then
    echo "Archive created: $_archive ($(du -h "$_archive" | cut -f1))"
  else
    echo "Error: Failed to create archive"
    return 1
  fi
}

#######################################
# Extract various archive formats
# Arguments:
#   Archive file path
# Returns:
#   Extraction status
#######################################
function Extract() {
  local _file="$1"

  if [[ -z "$_file" ]]; then
    echo "Usage: Extract <archive-file>"
    return 1
  fi

  if [[ ! -f "$_file" ]]; then
    echo "Error: File '$_file' not found"
    return 1
  fi

  case "$_file" in
    *.tar.bz2)   tar xjf "$_file"     ;;
    *.tar.gz)    tar xzf "$_file"     ;;
    *.bz2)       bunzip2 "$_file"     ;;
    *.rar)       unrar x "$_file"     ;;
    *.gz)        gunzip "$_file"      ;;
    *.tar)       tar xf "$_file"      ;;
    *.tbz2)      tar xjf "$_file"     ;;
    *.tgz)       tar xzf "$_file"     ;;
    *.zip)       unzip "$_file"       ;;
    *.Z)         uncompress "$_file"  ;;
    *.7z)        7z x "$_file"        ;;
    *)           echo "Error: Unknown archive format '$_file'" ; return 1 ;;
  esac

  if [[ $? -eq 0 ]]; then
    echo "Successfully extracted: $_file"
  else
    echo "Error: Failed to extract $_file"
    return 1
  fi
}

#######################################
# Find empty directories
# Arguments:
#   Directory path (default: current directory)
# Returns:
#   List of empty directories
#######################################
function FindEmptyDirs() {
  local _dir="${1:-.}"

  echo "Empty directories in $_dir:"
  find "$_dir" -type d -empty 2>/dev/null
}

#######################################
# Find broken symbolic links
# Arguments:
#   Directory path (default: current directory)
# Returns:
#   List of broken symlinks
#######################################
function FindBrokenLinks() {
  local _dir="${1:-.}"

  echo "Broken symbolic links in $_dir:"
  find "$_dir" -type l ! -exec test -e {} \; -print 2>/dev/null
}

#######################################
# Count files by extension
# Arguments:
#   Directory path (default: current directory)
# Returns:
#   File count by extension
#######################################
function CountByExtension() {
  local _dir="${1:-.}"

  echo "File count by extension in $_dir:"
  find "$_dir" -type f | awk -F/ '{ fn = $NF; if (fn ~ /\./) { sub(/.*\./, "", fn); print fn } }' | sort | uniq -c | sort -rn
}

#######################################
# Create directory and change into it
# Arguments:
#   Directory name
# Returns:
#   Changes to new directory
#######################################
function MkdirCD() {
  local _dir="$1"

  if [[ -z "$_dir" ]]; then
    echo "Usage: MkdirCD <directory>"
    return 1
  fi

  mkdir -p "$_dir" && cd "$_dir"
  echo "Created and changed to: $(pwd)"
}

#######################################
# Calculate directory size
# Arguments:
#   Directory path (default: current directory)
# Returns:
#   Total size of directory
#######################################
function DirSize() {
  local _dir="${1:-.}"

  if [[ ! -d "$_dir" ]]; then
    echo "Error: Directory '$_dir' not found"
    return 1
  fi

  du -sh "$_dir" 2>/dev/null
}

#######################################
# Find files containing text pattern
# Arguments:
#   $1 - Search pattern
#   $2 - Directory (default: current directory)
# Returns:
#   Files containing pattern
#######################################
function GrepFiles() {
  local _pattern="$1"
  local _dir="${2:-.}"

  if [[ -z "$_pattern" ]]; then
    echo "Usage: GrepFiles <pattern> [directory]"
    return 1
  fi

  echo "Searching for '$_pattern' in $_dir:"
  grep -r -n -H "$_pattern" "$_dir" 2>/dev/null
}

#######################################
# Compare two directories
# Arguments:
#   $1 - First directory
#   $2 - Second directory
# Returns:
#   Differences between directories
#######################################
function CompareDirs() {
  local _dir1="$1"
  local _dir2="$2"

  if [[ -z "$_dir1" ]] || [[ -z "$_dir2" ]]; then
    echo "Usage: CompareDirs <dir1> <dir2>"
    return 1
  fi

  if [[ ! -d "$_dir1" ]] || [[ ! -d "$_dir2" ]]; then
    echo "Error: One or both directories not found"
    return 1
  fi

  diff -rq "$_dir1" "$_dir2"
}

#######################################
# Safe file deletion (move to trash)
# Arguments:
#   File or directory path
# Returns:
#   Move confirmation
#######################################
function SafeDelete() {
  local _target="$1"
  local _trash="$HOME/.trash"

  if [[ -z "$_target" ]]; then
    echo "Usage: SafeDelete <file-or-directory>"
    return 1
  fi

  if [[ ! -e "$_target" ]]; then
    echo "Error: '$_target' not found"
    return 1
  fi

  mkdir -p "$_trash"
  local _timestamp=$(date +%Y%m%d_%H%M%S)
  local _basename=$(basename "$_target")
  
  mv "$_target" "${_trash}/${_basename}_${_timestamp}"
  echo "Moved to trash: ${_trash}/${_basename}_${_timestamp}"
}
