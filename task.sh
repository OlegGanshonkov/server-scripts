#!/bin/bash

# task deploy dev{ID}
# task deploy dev{ID} [TASK-ID = current branch]
# *dev{ID} - dev server instance (required)
# *[TASK-ID] - branch name (optional)
deploy() {
  local branch
  branch=$([ "$3" ] && echo "$3" || getCurrentBranch)
  if [[ -z "$2" ]]; then
    echo "Enter dev server: dev*"
    exit 1
  fi
  branchExist "$branch"
  git checkout master
  git pull origin master
  git checkout "$2"
  git reset --hard origin/master
  git checkout "$branch"
  rebaseCurrentBranch "$2"
  git checkout "$2"
  git merge "$branch"
  git push --force origin "$2"
  git checkout "$branch"
}

# task release
# task release [TASK-ID = current branch]
# *[TASK-ID] - branch name (optional)
release() {
  local branch
  branch=$([ "$2" ] && echo "$2" || getCurrentBranch)
  branchExist "$branch"
  git checkout master
  git pull origin master
  git checkout "$branch"
  rebaseCurrentBranch master
  git checkout master
  git merge "$branch"
  git push origin master
  git checkout abtest
  git merge -X theirs master -m "merge abtest"
  git push origin abtest
  git checkout master
}

# $1 - branch name
branchExist() {
  local branchExist
  branchExist=$(git show-ref --verify refs/heads/"$1")
  if [[ -z "$branchExist" ]]; then
    echo "Branch $branch not found"
    exit 1
  fi
}

# $1 - rebased branch name
rebaseCurrentBranch() {
  if git rebase "$1"; then
    echo "$1 rebased"
  else
    echo "$1 rebase conflict"
    exit 1
  fi
}

# Return current branch
getCurrentBranch() {
  git rev-parse --abbrev-ref HEAD;
  return $?
}

$1 $*
