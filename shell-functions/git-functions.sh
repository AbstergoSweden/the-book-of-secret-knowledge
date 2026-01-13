#!/usr/bin/env bash

# Git helper shell functions
# A collection of useful Git shortcuts and utilities

#######################################
# Git status with short format
# Returns:
#   Concise git status
#######################################
function gs() {
  git status -sb
}

#######################################
# Git log with pretty format
# Arguments:
#   Number of commits (default: 10)
# Returns:
#   Formatted git log
#######################################
function glog() {
  local _count="${1:-10}"
  git log --oneline --graph --decorate --all -n "$_count"
}

#######################################
# Show changed files in last commit
# Returns:
#   List of changed files
#######################################
function GitLastChanged() {
  git diff --name-only HEAD~1
}

#######################################
# Create and checkout a new branch
# Arguments:
#   Branch name
# Returns:
#   New branch creation status
#######################################
function GitNewBranch() {
  local _branch="$1"

  if [[ -z "$_branch" ]]; then
    echo "Usage: GitNewBranch <branch-name>"
    return 1
  fi

  git checkout -b "$_branch"
}

#######################################
# Delete local and remote branch
# Arguments:
#   Branch name
# Returns:
#   Deletion status
#######################################
function GitDeleteBranch() {
  local _branch="$1"

  if [[ -z "$_branch" ]]; then
    echo "Usage: GitDeleteBranch <branch-name>"
    return 1
  fi

  read -p "Delete local and remote branch '$_branch'? (y/n) " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    git branch -d "$_branch"
    git push origin --delete "$_branch"
  fi
}

#######################################
# Undo last commit (keep changes)
# Returns:
#   Reset status
#######################################
function GitUndoCommit() {
  git reset --soft HEAD~1
  echo "Last commit undone (changes kept)"
}

#######################################
# Amend last commit with current changes
# Returns:
#   Amend status
#######################################
function GitAmend() {
  git commit --amend --no-edit
  echo "Last commit amended"
}

#######################################
# Show file history
# Arguments:
#   File path
# Returns:
#   File change history
#######################################
function GitFileHistory() {
  local _file="$1"

  if [[ -z "$_file" ]]; then
    echo "Usage: GitFileHistory <file>"
    return 1
  fi

  git log --follow -p -- "$_file"
}

#######################################
# Show branches sorted by last commit date
# Returns:
#   Sorted branch list
#######################################
function GitBranches() {
  git for-each-ref --sort=-committerdate refs/heads/ --format='%(committerdate:short) %(refname:short)'
}

#######################################
# Find commits by message
# Arguments:
#   Search pattern
# Returns:
#   Matching commits
#######################################
function GitFindCommit() {
  local _pattern="$1"

  if [[ -z "$_pattern" ]]; then
    echo "Usage: GitFindCommit <pattern>"
    return 1
  fi

  git log --all --grep="$_pattern"
}

#######################################
# Show repository statistics
# Returns:
#   Repository stats
#######################################
function GitStats() {
  echo "=== Repository Statistics ==="
  echo "Total commits: $(git rev-list --count HEAD)"
  echo "Total contributors: $(git shortlog -sn | wc -l)"
  echo "Total branches: $(git branch -a | wc -l)"
  echo "Total tags: $(git tag | wc -l)"
  echo ""
  echo "Top 5 contributors:"
  git shortlog -sn | head -5
}

#######################################
# Clean up merged branches
# Returns:
#   Cleanup status
#######################################
function GitCleanup() {
  echo "Merged branches that can be deleted:"
  git branch --merged | grep -v "\*" | grep -v "main" | grep -v "master"
  
  read -p "Delete these branches? (y/n) " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    git branch --merged | grep -v "\*" | grep -v "main" | grep -v "master" | xargs -n 1 git branch -d
  fi
}

#######################################
# Create a git alias
# Arguments:
#   $1 - Alias name
#   $2 - Git command
# Returns:
#   Alias creation status
#######################################
function GitAlias() {
  local _alias="$1"
  local _command="$2"

  if [[ -z "$_alias" ]] || [[ -z "$_command" ]]; then
    echo "Usage: GitAlias <alias-name> <git-command>"
    return 1
  fi

  git config --global alias."$_alias" "$_command"
  echo "Created alias: git $_alias = git $_command"
}

#######################################
# Show uncommitted changes size
# Returns:
#   Size of changes
#######################################
function GitChangesSize() {
  git diff --stat | tail -1
}
