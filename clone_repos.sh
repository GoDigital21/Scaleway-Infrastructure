#!/bin/bash

GITHUB_USERNAME=$1
GITHUB_TOKEN=$2
REPOS_FILE="/maintenance/repos.txt"
BASE_PATH="data/containers"

while read -r repo; do
  REPO_NAME=$repo
  TARGET_PATH="$BASE_PATH/$REPO_NAME"

  if [ ! -d "$TARGET_PATH" ]; then
    echo "Cloning repository: $repo"
    git clone "https://$GITHUB_USERNAME:$GITHUB_TOKEN@github.com/$line.git" "$TARGET_PATH"
  fi
done < "$REPOS_FILE"