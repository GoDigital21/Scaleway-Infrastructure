#!/bin/bash

GITHUB_USERNAME=$1
GITHUB_TOKEN=$2
REPOS_FILE="/maintenance/repos.txt"
BASE_PATH="/data/containers"

while read -r repo; do
  REPO=$repo
  if [ "$REPO" = "." ] || [ "$REPO" = "" ]; then
    continue
  fi
  REPO_NAME=$(echo $REPO | awk -F'/' '{print $NF}')

  TARGET_PATH="$BASE_PATH/$REPO_NAME"

  if [ ! -d "$TARGET_PATH" ]; then
    mkdir -p "$TARGET_PATH"
    echo "Cloning repository: $REPO_NAME into $TARGET_PATH"
    git clone "https://$GITHUB_USERNAME:$GITHUB_TOKEN@github.com/$REPO.git" "$TARGET_PATH"
  fi
done < "$REPOS_FILE"