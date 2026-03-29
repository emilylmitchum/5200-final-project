#!/bin/bash

printf "Would you like to sync with the GitHub server (y/n)? "
read answer

if [[ "$answer" =~ ^[Yy]$ ]]; then
    echo "Syncing with GitHub..."

    # Pull latest changes
    git pull

    # Increase buffer size for large pushes
    git config http.postBuffer 524288000

    # Commit message prompt
    printf "ENTER MESSAGE: "
    read message
    echo "commit message = $message"

    # Add changes
    git add .

    # Commit
    git commit -m "$message"

    # Push
    git push origin main

else
    echo "Not synced to GitHub!"
fi

#must be run in git bash terminal, type bash git.sh to run