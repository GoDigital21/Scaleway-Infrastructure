#!/bin/bash

GITHUB_USERNAME=$1
GITHUB_TOKEN=$2
REPOS_FILE="/maintenance/repos.txt"
BASE_PATH="/data/containers"

# Debugging output to verify the input arguments
echo "GITHUB_USERNAME: $GITHUB_USERNAME"
echo "GITHUB_TOKEN: $GITHUB_TOKEN"
echo "REPOS_FILE: $REPOS_FILE"

# Check if repos.txt exists and is not empty
if [ ! -f "$REPOS_FILE" ]; then
    echo "Error: $REPOS_FILE not found."
    exit 1
fi

if [ ! -s "$REPOS_FILE" ]; then
    echo "Error: $REPOS_FILE is empty."
    exit 1
fi

while read -r repo; do
    REPO=$repo
    echo "Processing repository: $REPO"  # Debugging output

    if [ "$REPO" = "." ] || [ "$REPO" = "" ]; then
        echo "Skipping empty line or dot entry."  # Debugging output
        continue
    fi

    REPO_NAME=$(echo $REPO | awk -F'/' '{print $NF}')
    TARGET_PATH="$BASE_PATH/$REPO_NAME"

    echo "Repository Name: $REPO_NAME"
    echo "Target Path: $TARGET_PATH"

    if [ ! -d "$TARGET_PATH" ]; then
        echo "Creating directory: $TARGET_PATH"
        mkdir -p "$TARGET_PATH"
        echo "Cloning repository: $REPO_NAME into $TARGET_PATH"
        git clone "https://$GITHUB_USERNAME:$GITHUB_TOKEN@github.com/$REPO.git" "$TARGET_PATH"
    else
        echo "$REPO_NAME already exists in $TARGET_PATH, skipping."
    fi
done < "$REPOS_FILE"