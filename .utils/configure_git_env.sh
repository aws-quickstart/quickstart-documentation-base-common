git remote update
git fetch
git checkout --track origin/gh-pages
rm -rf docs/*
git restore -s master docs
git rm -r docs/common -r
git restore -s master templates
git submodule add https://github.com/aws-quickstart/quickstart-documentation-base-common.git docs/common
rm configure_git_env.sh
mv docs/images images
