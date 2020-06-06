#!/bin/sh
ASCIIDOC_ATTRIBUTES=""
GITHUB_REPO_OWNER=$(echo ${GITHUB_REPOSITORY} | cut -d '/' -f 1)
if [ "${GITHUB_REPO_OWNER}" == "aws-quickstart" ]; then
  if [ "${GITHUB_REF}" == "refs/heads/master" ]; then
    ASCIIDOC_ATTRIBUTES="-a production_build"
  fi
fi
asciidoctor --base-dir docs/ --backend=html5 -o ../index.html -w --failure-level ERROR --doctype=book -a toc2 ${ASCIIDOC_ATTRIBUTES} docs/boilerplate/index.adoc
