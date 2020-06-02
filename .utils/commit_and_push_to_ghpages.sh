#!/usr/bin/env bash

set -eu

repo_uri="https://x-access-token:${GITHUB_TOKEN}@github.com/${GITHUB_REPOSITORY}.git"

remote_name="doc-upstream"
main_branch="master"
target_branch="gh-pages"

cd "$GITHUB_WORKSPACE"
git config --local user.email "action@github.com"
git config --local user.name "GitHub Action"
git add -A
git commit -a -m "Updating documentation"
if [ $? -ne 0 ]; then
    echo "nothing to commit"
    exit 0
fi
git remote set-url "${remote_name}" "${repo_uri}" # includes access token
git push "${remote_name}" "${target_branch}"
