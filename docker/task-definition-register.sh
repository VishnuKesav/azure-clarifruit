# This registers a task definition for Xavier, based on the task-definition-template.json file (replacing the REPLACE_ME_IMAGE string with the given $XAVIER_TASK_IMAGE input environment variable).
# I used a technique described here to create this JSON: Ref: https://github.com/aws/aws-cli/issues/3064
#    TASK_DEFINITION=$(aws ecs describe-task-definition --task-definition "xavier" --region "eu-central-1")
#    NEW_TASK_DEFINTIION=$(echo $TASK_DEFINITION | jq --arg IMAGE "123" '.taskDefinition | .containerDefinitions[0].image = $IMAGE | del(.taskDefinitionArn) | del(.revision) | del(.status) | del(.requiresAttributes) | del(.compatibilities)')
#    echo $NEW_TASK_DEFINITION > task-definition-template.json
# Output is the ARN of the new task definition in a text file 'task-definition-result-arn.txt'
# Requires the jq command line utility and AWS CLI v2.
: "${PAPERTRAIL_DESTINATION:?You must set the environment variable PAPERTRAIL_DESTINATION to the appropraite environment destination. e.g logs111.papertrailapp.com:12345}" && \
: "${XAVIER_ENVIRONMENT:?You must set the environment variable XAVIER_ENVIRONMENT to the environment being deployed. e.g production-ecs}" && \
: "${TASK_FAMILY:?You must set the environment variable TASK_FAMILY to the appropraite task family name. e.g xavier}" && \
: "${LOGS_GROUP:?You must set the environment variable LOGS_GROUP to the appropraite environment log group. e.g xavier}" && \
: "${AWS_DEFAULT_REGION:?You must set the environment variable AWS_DEFAULT_REGION to the appropraite environment region. e.g eu-central-1}" && \
: "${XAVIER_TAG:?You must set the environment variable XAVIER_TAG to the branch, date of the build and build number e.g. develop-2021-08-15-4321.}"
: "${ECR_REPOSITORY:?You must set the environment variable ECR_REPOSITORY to the URI of the ECR repository for Xavier e.g. 305761728900.dkr.ecr.eu-central-1.amazonaws.com.}"
: "${ECR_REPOSITORY_NAME:?You must set the environment variable ECR_REPOSITORY_NAME to the name of the ECR repository for Xavier e.g. xavier.}"
: "${VERSION:?You must set the environment variable VERSION to the version of the xavier build e.g. 1.0.123 .}"

set -euo pipefail

XAVIER_TASK_IMAGE="${ECR_REPOSITORY}/${ECR_REPOSITORY_NAME}:${XAVIER_TAG}"

ESCAPED_XAVIER_TASK_IMAGE=$(printf '%s\n' "$XAVIER_TASK_IMAGE" | sed -e 's/[\/&]/\\&/g')
cat task-definition-template.json | sed "s/REPLACE_ME_IMAGE/$ESCAPED_XAVIER_TASK_IMAGE/g"  | sed "s/REPLACE_ME_XAVIER_ENVIRONMENT/$XAVIER_ENVIRONMENT/g" | sed "s/REPLACE_ME_PAPERTRAIL_DESTINATION/$PAPERTRAIL_DESTINATION/g" | sed "s/REPLACE_ME_TASK_FAMILY/$TASK_FAMILY/g" | sed "s/REPLACE_ME_LOGS_GROUP/$LOGS_GROUP/g" | sed "s/REPLACE_ME_AWS_REGION/$AWS_DEFAULT_REGION/g" > task-definition.json

echo "sed output:\n$(cat task-definition.json)"

echo "Registering task definition for xavier image..."
aws ecs register-task-definition --cli-input-json file://task-definition.json > task-definition-result.json
echo "Register-task-definition output:\n$(cat task-definition-result.json)"

TASK_DEFINITION_RESULT=$(cat task-definition-result.json)
echo $TASK_DEFINITION_RESULT | jq -r '.taskDefinition.taskDefinitionArn' > task-definition-result-arn.txt
echo "Registered (arn: $(cat task-definition-result-arn.txt))."

echo "Tagging task definition"
aws ecs tag-resource --resource-arn $(cat task-definition-result-arn.txt) --tags key=xavier-version,value=$VERSION

