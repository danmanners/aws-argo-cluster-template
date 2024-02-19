# Description: Common functions used in the scripts

# Function to get the git root path
function getGitRootPath() {
  git rev-parse --show-toplevel
}

# Function to parse through all of the user defined input
function parseUserInput() {
  user_input=${1}
  if [[ -z "${!user_input}" ]]; then
    printf "\t> Please enter your $(echo ${user_input} | sed "s|_|\ |g"): "
    read -r $user_input
  fi
}

# Function to check all user defined input
function checkUserInput() {
  user_inputs=("$@")
  for user_input in "${user_inputs[@]}"; do
    echo -e "\t- $(echo ${user_input} | sed "s|_|\ |g"): ${!user_input}"
  done
  printf "🔍 Do these look correct? (y/n) "
  read -r confirm
  # Ask the user to confirm the input
  if [[ $confirm != "y" ]]; then
    echo "😕 Please re-run the script with the correct environment variables."
    exit 1
  fi
}

# Function to set github cli values and log the user in
function setGitHubCLIValues() {
  # Check if GitHub CLI is already authenticated
  if ! gh auth status >/dev/null 2>&1; then
    # Set GitHub CLI to non-interactive mode
    gh config set prompt disabled
    # Set the github.com protocol to SSH
    gh config set -h github.com git_protocol ssh
    # Open the browser to authenticate with GitHub
    open https://github.com/login/device
    # Perform the github auth
    gh auth login -w
    # Re-enable the prompt
    gh config set prompt enabled
  else
    echo -e "\t🎉 GitHub CLI is already authenticated."
    return
  fi
}

# Function to check if a tool is installed
function checkToolInstalled() {
  tool=$1
  check_tool=$(echo $tool | awk -F, '{print $1}')
  if ! command -v $check_tool &>/dev/null; then
    echo -e "\t❌ $check_tool is not installed."
    if ! command -v brew &>/dev/null; then
      echo -e "\t❌ Homebrew is not installed. Please install Homebrew and try again."
      open https://brew.sh
      exit 1
    else
      # Check if the user wants to install the tool
      printf "\t> $check_tool is not installed. Do you want to install it? (y/n) "
      read -r install
      if [[ $install != "y" ]]; then
        echo -e "\t😕 Skipping $check_tool installation."
        exit 1
      fi
      # Install the tool
      echo -e "\t✅ Installing $check_tool..."
      # Check the third argument of the tool, if it exists, make sure we run brew tap before installing the tool
      if [[ $(echo $tool | awk -F, '{print $3}') != "" ]]; then
        brew tap $(echo $tool | awk -F, '{print $3}')
      fi
      # Install the tool
      if [[ $(echo $tool | awk -F, '{print $2}') != "" ]]; then
        brew install $(echo $tool | awk -F, '{print $2}')
      else
        brew install $check_tool
      fi
    fi
  # Check if the tool was installed successfully
  else
    echo -e "\t✅ $check_tool is installed."
  fi
}

# Create the users Sealed Secrets Keypair
function createSealedSecretsKeypair() {
  # Set the keys directory
  keys_directory="$(getGitRootPath)/keys"
  private_key_path="${keys_directory}/sealed-secret.key"
  public_key_path="${keys_directory}/sealed-secret.crt"

  # Check if the keys already exist
  if [[ ! -f "${private_key_path}" ]]; then
    echo -e "\t🔑 Creating the Sealed Secrets Keypair..."
    # Generate the keypair that will be used to encrypt the secrets
    openssl req -x509 \
      -days 3650 -nodes \
      -newkey rsa:4096 \
      -keyout "$private_key_path" \
      -out "$public_key_path" \
      -subj "/CN=sealed-secret/O=sealed-secret" >/dev/null 2>&1

    echo -e "\t🎉 Sealed Secrets Keypair created."
  else
    echo -e "\t🎉 Sealed Secrets Keypair already exists."
  fi
}

# Function to create our age encryption keypair
function createAgeKeypair() {
  # Set the keys directory
  keys_directory="$(getGitRootPath)/keys"
  private_key_path="${keys_directory}/age.key"
  public_key_path="${keys_directory}/age.pub"

  # Check if the keys already exist
  if [[ ! -f "${private_key_path}" ]]; then
    echo -e "\t🔑 Creating the Age Keypair..."
    # Generate the keypair
    age-keygen -o $private_key_path >/dev/null 2>&1
    age-keygen -y $private_key_path >${public_key_path}
    echo -e "\t🎉 Age Keypair created."
  else
    echo -e "\t🎉 Age Keypair already exists."
  fi
}

# Function to create our sops file and encrypt our sealed secrets keypair
function createSopsConfig() {
  # Set the keys directory
  keys_directory="$(getGitRootPath)/keys"
  sops_template_file="${keys_directory}/sops_template.yaml"
  sops_file_path="$(getGitRootPath)/.sops.yaml"

  # Check if the sops file already exists
  if [[ ! -f "${sops_file_path}" ]]; then
    echo -e "\t🔑 Creating the Sops File..."
    sed "s|REPLACE_THIS|$(cat ${keys_directory}/age.pub)|g" $sops_template_file >$sops_file_path
    echo -e "\t🎉 Sops File created."
  else
    echo -e "\t🎉 Sops File already exists."
  fi
}

# Function to encrypt our Sealed Secrets Key
function encryptSealedSecretsKey() {
  # Set the keys directory
  keys_directory="$(getGitRootPath)/keys"
  private_key_path="${keys_directory}/sealed-secret.key"
  encrypted_key_path="${keys_directory}/sealed-secret.key.enc"

  # Check if the encrypted key already exists
  if [[ ! -f "${encrypted_key_path}" ]]; then
    echo -e "\t🔐 Encrypting the Sealed Secrets Key..."
    # Encrypt the key
    sops -e --output ${encrypted_key_path} ${private_key_path}
    echo -e "\t🎉 Sealed Secrets Key encrypted."
  else
    echo -e "\t🎉 Sealed Secrets Key already encrypted."
  fi
}

# Function to list all of the repository secrets
function listGitHubRepoSecrets() {
  github_username=${1}
  # Get the repository name
  remote_repo="${github_username}/$(basename -s .git $(git config --get remote.origin.url))"
  # List the secrets in the repository
  for item in $(gh secret list -R $remote_repo --json name | jq -rc '.[].name'); do
    echo -e "\t- $item"
  done
}

# Function to define and create our repository secrets using the GitHub CLI
function createGitHubRepoSecrets() {
  # Get the repository name
  remote_repo="${1}/$(basename -s .git $(git config --get remote.origin.url))"
  # Provide the list of secrets that we want to create in the repository
  secrets=(
    "AWS_Account_ID"
    "aws_access_key_id"
    "aws_secret_access_key"
    "region"
  )
  # Loop through the secrets and create them in the repository
  for secret in "${secrets[@]}"; do
    # Check if the secret already exists
    upperSecret=$(echo ${secret} | tr '[:lower:]' '[:upper:]')
    printf "\t✨ Creating the ${upperSecret} secret..."
    if [[ "${!secret}" ]]; then
      gh secret set ${upperSecret} -R $remote_repo -b "${!secret}" >/dev/null 2>&1
    else
      gh secret set ${upperSecret} -R $remote_repo -b "$(aws configure get default.${secret})" >/dev/null 2>&1
    fi
    # Check if the secret was created successfully
    if [[ $? -eq 0 ]]; then
      echo -e "🎉 secret created."
    else
      echo -e "❌ secret failed to create."
    fi
  done
}

# Function to create the appropriate ECR registry
function createECRRegistry() {
  # Reusable function inside of this function
  function chk() {
    # If the repository exists, return 0, else return 1
    if [[ $(aws ecr describe-repositories | jq -r '.repositories[].repositoryName' | xargs) =~ "${1}" ]]; then
      # if "${1}" in $(aws ecr describe-repositories | jq -r '.repositories[].repositoryName' | xargs); then
      return 0
    else
      return 1
    fi
  }
  # Get the repository name
  repository_name=$(basename -s .git $(git config --get remote.origin.url))
  # Check if the ECR registry already exists
  if chk "${repository_name}"; then
    echo -e "\t🎉 ECR Registry already exists."
  else
    echo -e "\t🔧 Creating the ECR Registry..."
    aws ecr create-repository --region=$(aws configure get default.region) --repository-name=${repository_name} >/dev/null 2>&1
    echo -e "\t🎉 ECR Registry created."
  fi
}

# Function to do the Route53 HostedZone ID Lookup
function getRoute53HostedZoneIDLookup() {
  # Get the domain name
  domain_name=${1}
  # Get the hosted zone id
  hosted_zone_id=$(aws route53 list-hosted-zones | jq -rc '.HostedZones[]|select(.Name == "'${domain_name}.'")')
  if [[ ! $hosted_zone_id ]]; then
    # If the hosted zone id is not found, return empty
    return
  else
    # Return the hosted zone id
    echo $hosted_zone_id | jq -r .Id | awk -F/ '{print $3}'
  fi
}

# Function to create the appropriate Route53 HostedZone and NS records in the parent domain
function createRoute53HostedZone() {
  # Get the domain name
  domain_name="${1}"
  parent_domain="$(echo ${domain_name} | cut -d'.' -f2-)" # Get the domain name without the subdomain
  parent_hosted_zone_id=$(getRoute53HostedZoneIDLookup ${parent_domain})

  # Create the Route53 Hosted Zone
  hz_create=$(aws route53 create-hosted-zone --name ${domain_name} --caller-reference $(date +%s))
  ns_records=$(echo "${hz_create}" | jq -rc '.DelegationSet.NameServers[] | {Value: .}' | jq -sc)
  # Create the data blob for the NS records
  post_data=$(
    jq -nc '{
      Changes: [
        { Action: "CREATE",
          ResourceRecordSet: {
            Name: "'${domain_name}'.",
            Type: "NS",
            TTL: 300,
            ResourceRecords: '${ns_records}'
          }
        }
      ]
    }'
  )

  # Create the NS records in the parent domain
  aws route53 change-resource-record-sets \
    --hosted-zone-id ${parent_hosted_zone_id} \
    --change-batch ${post_data} >/dev/null 2>&1

  # Check if the hosted zone was created successfully
  if [[ $? -eq 0 ]]; then
    echo -e "\t🎉 Route53 Hosted Zone created."
  else
    echo -e "\t❌ Route53 Hosted Zone failed to create."
  fi
}

# Function to return errors for the Route53 HostedZone ID Lookup
function route53Error() {
  echo -e "\t❌ The Route53 Hosted Zone ID for \"${1}\" cannot be found."
}

# Function to check if a secret is already in AWS Secrets Manager
function checkAWSSecretsManagerSecret() {
  # Check if the secret exists
  if [[ $(aws secretsmanager list-secrets | jq -r '.SecretList[].Name' | xargs) =~ "${1}" ]]; then
    echo -e "\t🎉 AGE key is already in AWS Secrets Store."
  else
    echo -e "\t🔑 Secret not found, creating."
    return 0
  fi
}

# Function to create the appropriate AWS Secrets Manager secret
function createAWSSecretsManagerSecret() {
  # Set the Description Field
  description="Cloud AGE Key for Talos to decrypt SealedSecrets Key"

  # Create the secret in AWS Secrets Manager
  secret=$(aws secretsmanager create-secret --name ${1} \
    --secret-string "$(cat $(getGitRootPath)/keys/age.key | grep AGE-SECRET-KEY)" \
    --description "${description}" \
    --tags Key=Repo,Value="${2}" |
    jq -r '.ARN')

  # Check if the secret was created successfully
  if [[ "${secret}" != "null" ]]; then
    echo -e "🎉 AGE key created in AWS Secrets Store."
  else
    echo -e "❌ AGE key failed to create in AWS Secrets Store."
  fi
}

# Function to update the appropriate AWS Secrets Manager secret
function updateAWSSecretsManagerSecret() {
  # Update the secret in AWS Secrets Manager
  secret=$(aws secretsmanager update-secret --secret-id ${1} \
    --secret-string "$(cat $(getGitRootPath)/keys/age.key | grep AGE-SECRET-KEY)" |
    jq -r '.ARN')

  # Check if the secret was updated successfully
  if [[ "${secret}" != "null" ]]; then
    echo "🎉 AGE key updated in AWS Secrets Store."
  else
    echo "❌ AGE key failed to update in AWS Secrets Store."
  fi
}

# Function to evaluate and upload the appropriate AWS Secrets Manager secret
function uploadAWSSecretsManagerSecret() {
  # Define the name of the secret
  secret_name="cloud-age-key"
  # Check if the secret already exists
  checkSecret=$(checkAWSSecretsManagerSecret ${secret_name})
  if [[ $checkSecret == "" ]]; then
    printf "\t🔑 Secret not found; creating..."
    # Get the repository name
    remote_repo="${1}/$(basename -s .git $(git config --get remote.origin.url))"
    createAWSSecretsManagerSecret "${secret_name}" "https://github.com/${remote_repo}"
  else
    printf "\t❓ Secret exists. Updating for integrity..."
    # Update the secret
    updateAWSSecretsManagerSecret "${secret_name}"
  fi
}

# Function to replace the placeholder values in the pulumi values file
function replacePulumiValues() {
  # Set all of the variables to be used in the pulumi values file
  domain="${1}"
  github_username="${2}"
  public_hosted_zone_id="${3}"
  aws_account_id="${4}"
  repository_name="$(basename -s .git $(git config --get remote.origin.url))"

  # Get the pulumi values file
  pulumi_values_file="$(getGitRootPath)/infrastructure/pulumi/env/values.ts"
  # Replace the placeholder values in the pulumi values file
  sed -i '' -e "s|your_domain_here|${domain}|" ${pulumi_values_file}
  sed -i '' -e "s|your_github_username|${github_username}|" ${pulumi_values_file}
  sed -i '' -e "s|your_github_repo_name|${repository_name}|" ${pulumi_values_file}
  sed -i '' -e "s|your_hosted_zone_id|${public_hosted_zone_id}|" ${pulumi_values_file}
  sed -i '' -e "s|your_aws_account_id|${aws_account_id}|" ${pulumi_values_file}
}

# Function to deploy a helm chart
function deployHelmChart() {
  # Set the variables
  APP_DIRECTORY=${1}
  HELM_REPO_SOURCE=${2}
  HELM_REPO_NAME=${3}
  HELM_APP_NAME=${4}
  HELM_APP_VERSION=${5}
  HELM_APP_NAMESPACE=${6}
  DRY_RUN=${7:-"none"}

  # Add the Helm repository
  helm repo add ${HELM_REPO_NAME} ${HELM_REPO_SOURCE}

  # Update your local Helm chart repository cache
  helm repo update

  # Template out and install the Helm chart via pipe to `kubectl apply`
  echo "helm template ${HELM_APP_NAME} ${HELM_REPO_NAME}/${HELM_APP_NAME} --version ${HELM_APP_VERSION} --values ${APP_DIRECTORY}/values.yaml -n ${HELM_APP_NAMESPACE} | kubectl apply -f - --dry-run=${DRY_RUN}"
  helm template ${HELM_APP_NAME} ${HELM_REPO_NAME}/${HELM_APP_NAME} \
    --version ${HELM_APP_VERSION} \
    --values ${APP_DIRECTORY}/values.yaml \
    -n ${HELM_APP_NAMESPACE} |
    kubectl apply -f - --dry-run=${DRY_RUN}
}

# Function to check and set for a default value with Kubectl dry-runs
function checkKubectlDryRun() {
  # Check if dry-run flag is set
  if [ "$1" == "--dry-run" ]; then
    echo "client"
  else
    echo "none"
  fi
}

# Function to evaluate if a directory path exists, then source the env.sh file if it does
function sourceEnvFile() {
  # Check if the first argument is a valid directory path
  if [ -d "${1}" ]; then
    export $(cat ${1}/env.sh | grep -v '#' | xargs)
    return 0
  else
    echo "Invalid directory path"
    exit 1
  fi
}
