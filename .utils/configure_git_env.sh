#!/bin/bash -e
set -x
git remote update
git fetch
set +e 
git rev-parse --verify origin/gh-pages
CHECK_BRANCH=$?
set -e
if [[  $CHECK_BRANCH -ne 0 ]];then
  git checkout -b gh-pages
  git push origin gh-pages
else
  git checkout gh-pages
#    git checkout --track origin/gh-pages
fi
git rm -rf .
touch .gitmodules
git restore -s origin/master docs
set +e
git rm -r docs/boilerplate -r
rm -rf docs/boilerplate
set -e
git restore -s origin/master templates
git submodule add https://github.com/aws-quickstart/quickstart-documentation-base-common.git docs/boilerplate
rm configure_git_env.sh
mv docs/images images
