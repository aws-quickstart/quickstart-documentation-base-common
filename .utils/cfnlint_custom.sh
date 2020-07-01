#!/bin/bash
set -e
if [[ -d "${GITHUB_WORKSPACE}/team_custom_rules" ]]; then
  # Install requirements for custom rules, plus the rules themselves.
  cd ${GITHUB_WORKSPACE}/team_custom_rules
  pip install -r requirements.txt
  python setup.py install
  cd ${GITHUB_WORKSPACE}
  # back to normal
  CFNLINT_ARGS="-a ${GITHUB_WORKSPACE}/team_custom_rules/qs_cfn_lint_rules"
  echo "Using custom ruleset"
else
  echo "NOT using custom ruleset"

fi

cfn-lint ${CFNLINT_ARGS} -i W --templates templates/* --format json > /cfnlint_output.json
python docs/boilerplate/.utils/pretty_cfnlint_output.py /cfnlint_output.json
