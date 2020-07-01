#!/bin/bash
set -e
if [[ -d "${GITHUB_WORKSPACE}/team_custom_rules" ]]; then
  pip install -r ${GITHUB_WORKSPACE}/team_custom_rules/requirements.txt
  python ${GITHUB_WORKSPACE}/team_custom_rules/setup.py install
  CFNLINT_ARGS="-a ${GITHUB_WORKSPACE}/team_custom_rules/qs_cfn_lint_rules"
  echo "Using custom ruleset"
else
  echo "NOT using custom ruleset"

fi

cfn-lint ${CFNLINT_ARGS} -i W --templates templates/*
