#!/bin/bash
set -e
# Load all of the core functions from the same directory of the environment-setup script
source $(dirname ${0})/functions.sh

# List of required tools
tools=(
  "age"
  "aws,awscli" # awscli is the name for the brew package, whereas aws is the name of the command line tool
  "gh"
  "git"
  "helm"
  "jq"
  "kubectl"
  "node"
  "openssl"
  "talhelper"
  "talosctl,talosctl,siderolabs/talos" # talosctl is the name of the tool and what needs to be installed,
  # siderolabs/talos is the git repo that needs to be tapped prior to attempting to install the tool
  "yarn"
)

# List of required environment variables
required_env_vars=(
  "GitHub_Username"
  "AWS_Account_ID"
  "Cloud_Domain_Name"
)

# Check if the required tools are installed
echo "🔧 Checking if the required tools are installed..."
for tool in "${tools[@]}"; do
  checkToolInstalled $tool
done

# Ensure that the github cli is logged in
echo "🔧 Setting up the GitHub CLI..."
setGitHubCLIValues

# Have the user input all of their required environment variables
echo "🔧 Setting up the required values..."
# Check if the user is already authenticated with GitHub and has a username set
if [[ $(gh api user | jq -r .login) != "null" ]]; then
  GitHub_Username=$(gh api user | jq -r .login)
fi
# Get the current AWS Account ID
if aws sts get-caller-identity >/dev/null 2>&1; then
  AWS_Account_ID=$(aws sts get-caller-identity | jq -r .Account)
fi
# Check all required environment variables and ask the user to input them if not already set
for user_input in "${required_env_vars[@]}"; do
  # Check if the user input is already set
  if [[ -z "${!user_input}" ]]; then
    parseUserInput $user_input
  fi
done

# Check that everything looks good to the user; get confirmation
echo "🔍 Please review the following required values:"
checkUserInput "${required_env_vars[@]}"

# Lookup the Route53 Hosted Zone ID
printf "🔍 Looking up the Route53 Hosted Zone IDs...\n"

# Get the Route53 Hosted Zone ID for the parent domain of Cloud_Domain_Name
numCheck=$(echo ${Cloud_Domain_Name} | awk -F'.' '{print NF}')
# If the $numCheck has 3 or more parts, we want to trim off the subdomain and look up the hosted zone ID for the domain
if [[ $numCheck -gt 2 ]]; then
  Cloud_Parent_Domain=$(echo "${Cloud_Domain_Name}" | cut -d'.' -f2-) # Get the domain name without the subdomain
  r53_hosted_zone_id=$(getRoute53HostedZoneIDLookup ${Cloud_Parent_Domain})
  if [[ -z "${r53_hosted_zone_id}" ]]; then
    route53Error ${cdn}
    exit 1
  else
    echo -e "\t🎉 Found the Route53 Hosted Zone ID for ${Cloud_Parent_Domain}: ${r53_hosted_zone_id}"
  fi
fi

# Attempt to get the Route53 Hosted Zone ID for the Cloud_Domain_Name
domain_hosted_zone_id=$(getRoute53HostedZoneIDLookup ${Cloud_Domain_Name})
if [[ -z ${domain_hosted_zone_id} ]]; then
  route53Error ${Cloud_Domain_Name}
  printf "\t❓ Do you want to create the Route53 Hosted Zone for ${Cloud_Domain_Name}? (y/n) "
  read -r create_hosted_zone
  if [[ $create_hosted_zone == "y" ]]; then
    createRoute53HostedZone ${Cloud_Domain_Name}
  else
    echo -e "\t😕 Please create the Route53 Hosted Zone for ${Cloud_Domain_Name} and try again."
    exit 1
  fi
else
  echo -e "\t🎉 Found the Route53 Hosted Zone ID for ${Cloud_Domain_Name}: ${r53_hosted_zone_id}"
fi

# Check if the users Sealed Secrets Keypair exists
echo "🔐 Checking if the Sealed Secrets Keypair exists..."
createSealedSecretsKeypair

# Check if the users age Keypair exists
echo "🔐 Checking if the age Keypair exists..."
createAgeKeypair

# Check if the user has their .sops.yaml file configured
echo "🔐 Checking if the .sops.yaml file exists..."
createSopsConfig

# Encrypting our Sealed Secrets Key
echo "🔐 Encrypting the Sealed Secrets Key..."
encryptSealedSecretsKey

# Get the current list of repository secrets
echo "🔏 Writing all repository secrets..."
createGitHubRepoSecrets $GitHub_Username

# Create the ECR Repository
echo "📦 Creating the ECR Repository..."
createECRRegistry

# Upload the AGE Key to AWS Secrets Manager
echo "🔑 Checking on the AGE Key in AWS Secrets Manager..."
uploadAWSSecretsManagerSecret

# Replace the placeholder values in the Pulumi values.ts file
echo "🔧 Replacing the placeholder values in the Pulumi values.ts file..."
replacePulumiValues \
  ${Cloud_Domain_Name} \
  ${GitHub_Username} \
  ${domain_hosted_zone_id} \
  ${AWS_Account_ID}
if [[ $? -ne 0 ]]; then
  echo -e "\t❌ Failed to replace the placeholder values in the Pulumi values.ts file."
  exit 1
else
  echo -e "\t🎉 Replaced the placeholder values in the Pulumi values.ts file."
fi
