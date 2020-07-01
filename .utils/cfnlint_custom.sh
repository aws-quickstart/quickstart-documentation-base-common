#!/bin/bash
echo "Entered the script"
set -ex
if [[ -d "${GITHUB_WORKSPACE}/team_custom_rules" ]]; then
  CFNLINT_ARGS="-a team_custom_rules"
fi

cfn-lint --ignore-checks W ${CFNLINT_ARGS} --templates templates/*
set +x
