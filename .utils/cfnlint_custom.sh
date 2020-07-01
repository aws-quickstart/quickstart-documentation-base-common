#!/bin/bash
set -e
if [[ -d "${GITHUB_WORKSPACE}/team_custom_rules" ]]; then
  CFNLINT_ARGS="-a team_custom_rules"
  echo "Using custom ruleset"
else
  echo "NOT using custom ruleset"

fi

cfn-lint --ignore-checks W ${CFNLINT_ARGS} --templates templates/*
