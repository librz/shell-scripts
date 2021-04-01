#!/bin/bash

# gsync: git sync
# aim: bidirectional sync between local and remote git repo

if ! branch=$(git branch --show-current); then
	exit 1
fi

if [[ -n "$1" ]]; then
	if [[ ! $(git branch --list) =~ $1 ]]; then
		echo "branch $1 doesn't exit"
		exit 2
	fi
	branch="$1"
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
