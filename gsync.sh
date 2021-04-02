#!/bin/bash

# gsync: git sync
# aim: bidirectional sync between local and remote git repo

# usage: 
# 1. sync current branch: bash gsync.sh 
# 2. sync specific branch: bash gsync.sh {branch name}
# e.g. bash gsync.sh dev

# note: this script will peform auto merge when local & remote branch are diverged
# rebase is not supported yet, maybe I'll add itlater

if ! branch=$(git branch --show-current); then
	# one of the reason you may come to this is:
	# current folder is not even monitored by git
	exit 1
fi

# if parameter is provided 
if [[ -n "$1" ]]; then
	if [[ ! $(git branch --list) =~ $1 ]]; then
		echo "branch $1 doesn't exist"
		exit 2
	fi
	if [[ "$branch" != "$1" ]]; then
		branch="$1"
		git switch "$1"
	fi
fi

if ! git fetch; then
	exit 3
fi

status=$(git status)

if [[ "$status" =~ ahead ]]; then
	echo "** Pushing local changes to origin/main **"
	if ! git push; then
		exit 4
	fi
elif [[ "$status" =~ behind ]]; then
	echo "** Pulling remote changes from origin/main **"
	if ! git merge origin/"$branch" --ff-only; then
		exit 5
	fi
elif [[ "$status" =~ diverged ]]; then
	# try to perform auto merge
	if git merge origin/"$branch" --no-edit; then
		echo "** Pushing changes to origin/main after successful merge **"
		if ! git push; then
			exit 4
		fi
	else
		echo "There seems to be merge conflicts, please resolve them mannually"
		exit 6
	fi
elif [[ "$status" =~ 'up to date' ]]; then
	echo "You branch is already up to date with origin/$branch"
else
	echo "An unknown error occured, check the script you are running"
	exit 7
fi
