#PULL_REQUEST_NAME="deploy-prs"
#PR_DEPLOY_ENVIRONMENT="dev"

: "${PR_DEPLOY_ENVIRONMENT:?You must set the environment variable PR_DEPLOY_ENVIRONMENT to the either dev or prod.}"
: "${PULL_REQUEST_NAME:?You must set the environment variable PULL_REQUEST_NAME to the name of the pull request branch (only lower-case letters, numbers and dash allowed) e.g. java-17.}"

set -euo pipefail

if [ "${PR_DEPLOY_ENVIRONMENT}" = "dev" ]; then
  PR_REGION="eu-central-1"
elif [ "${PR_DEPLOY_ENVIRONMENT}" = "prod" ]; then
  PR_REGION="eu-west-1"
else
  echo "Bad environment '${PR_DEPLOY_ENVIRONMENT}'."
  exit -1
fi

PULL_REQUEST_NAME=$(./sanitize-pr-name.py ${PULL_REQUEST_NAME})

echo "Destroying pull request ${PR_DEPLOY_ENVIRONMENT} environment \'${PULL_REQUEST_NAME}\'..."

STACK_NAME="xavier-${PR_DEPLOY_ENVIRONMENT}-pr-service-${PULL_REQUEST_NAME}"

aws cloudformation delete-stack --region "${PR_REGION}" --stack-name "${STACK_NAME}"
aws cloudformation wait stack-delete-complete --region "${PR_REGION}" --stack-name "${STACK_NAME}"

echo "Done."