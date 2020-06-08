#!/usr/bin/env bash -e
git remote update
git fetch
set +e 
git rev-parse --verify gh-pages
CHECK_BRANCH=$?
set -e
if [[  $CHECK_BRANCH -ne 0 ]];then
  git checkout -b gh-pages
else
    git checkout --track origin/gh-pages
fi
git rm -rf .
touch .gitmodules
git restore -s master docs
git rm -r docs/boilerplate -r
rm -rf docs/boilerplate
git restore -s master templates
git submodule add https://github.com/aws-quickstart/quickstart-documentation-base-common.git docs/boilerplate
rm configure_git_env.sh
mv docs/images images
