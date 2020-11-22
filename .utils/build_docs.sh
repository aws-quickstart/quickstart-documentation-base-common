#!/bin/bash
set -e
ASCIIDOC_ATTRIBUTES=""
GITHUB_REPO_OWNER=$(echo ${GITHUB_REPOSITORY} | cut -d '/' -f 1)
if [ -d docs/images ]; then
  mv docs/images images
fi
if [ "${GITHUB_REPO_OWNER}" == "aws-quickstart" ]; then
  cp docs/boilerplate/.css/AWS-Logo.svg images/
  if [ "${GITHUB_REF}" == "refs/heads/master" ] || [ "${GITHUB_REF}" == "refs/heads/main" ]; then
    ASCIIDOC_ATTRIBUTES="-a production_build"
  fi
fi
asciidoctor --base-dir docs/ --backend=html5 -o ../index.html -w --failure-level ERROR --doctype=book -a toc2 ${ASCIIDOC_ATTRIBUTES} docs/boilerplate/index.adoc


if [ -d docs/languages ]; then
  for dir in docs/languages/*/
  do
    dir=${dir%*/}
    lang=$(echo ${dir%*/} | awk -F'[-]' '{print $2}')
    asciidoctor --base-dir docs/languages/docs-${lang}/ --backend=html5 -o ../../../index-${lang}.html -w --failure-level ERROR --doctype=book -a toc2 ${ASCIIDOC_ATTRIBUTES} docs/languages/docs-${lang}/index.adoc
  done
fi
