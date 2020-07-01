#!/bin/bash
set -e
if [[ -d "${GITHUB_WORKSPACE}/team_custom_rules" ]]; then
  CFNLINT_ARGS="-a team_custom_rules"
fi

cfnlint ${CFNLINT_ARGS} checked_out_repo/templates/*
