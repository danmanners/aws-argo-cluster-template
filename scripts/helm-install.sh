#!/bin/bash
# Load all of the core functions from the same directory of the environment-setup script
source $(dirname ${0})/functions.sh

# Check if the first argument is a valid directory path
sourceEnvFile ${1}

# Check if dry-run flag is set
DRY_RUN="$(checkKubectlDryRun ${2})"
# Deploy Helm chart
deployHelmChart \
    ${1} \
    ${HELM_REPO_SOURCE} \
    ${HELM_REPO_NAME} \
    ${HELM_APP_NAME} \
    ${HELM_APP_VERSION} \
    ${HELM_APP_NAMESPACE} \
    ${DRY_RUN}
