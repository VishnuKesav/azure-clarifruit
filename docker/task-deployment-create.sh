# This deploys a new version of xavier to the current environment.
: "${CODE_DEPLOY_APP_NAME:?You must set the environment variable CODE_DEPLOY_APP_NAME to your fully qualified task definition ARN. e.g. xavier-dev-codedeploy}" && \
: "${CODE_DEPLOY_GROUP_NAME:?You must set the environment variable CODE_DEPLOY_GROUP_NAME to your fully qualified task definition ARN. e.g. xavier-dev-codedeploy}" && \
: "${WAIT_FOR_DEPLOYMENT_TO_FINISH:?You must set the environment variable WAIT_FOR_DEPLOYMENT_TO_FINISH to specify if we should wait for deployment to finish}" && \

set -euo pipefail

XAVIER_TASK_DEFINITION="$(cat task-definition-result-arn.txt)"

ESCAPED_XAVIER_TASK_DEFINITION=$(printf '%s\n' "$XAVIER_TASK_DEFINITION" | sed -e 's/[\/]/\\\\\\\//g')
cat task-deployment-template.json | sed "s/REPLACE_ME_DEFINITION/$ESCAPED_XAVIER_TASK_DEFINITION/g" | sed "s/REPLACE_ME_CODE_DEPLOY_APP_NAME/$CODE_DEPLOY_APP_NAME/g" | sed "s/REPLACE_ME_CODE_DEPLOY_GROUP_NAME/$CODE_DEPLOY_GROUP_NAME/g" > task-deployment.json

echo "sed output:\n$(cat task-deployment.json)"

echo "Deploying xavier..."
aws deploy create-deployment --cli-input-json file://task-deployment.json > task-deployment-id.json
cat task-deployment-id.json

TASK_DEPLOYMENT_ID_JSON=$(cat task-deployment-id.json)
echo $TASK_DEPLOYMENT_ID_JSON | jq -r '.deploymentId' > task-deployment-id.txt
TASK_DEPLOYMENT_ID="$(cat task-deployment-id.txt)"

echo "Deployed with ID: ${TASK_DEPLOYMENT_ID}."

if [ "$WAIT_FOR_DEPLOYMENT_TO_FINISH" = true ] ; then
  echo "Waiting for successful completion of the deployment..."
  aws deploy wait deployment-successful --deployment-id "${TASK_DEPLOYMENT_ID}"
else
  echo "Not waiting for completion of the deployment."
fi

