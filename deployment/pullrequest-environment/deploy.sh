#PULL_REQUEST_NAME="deploy-prs"
#TASK_DEFINITION_ARN="arn:aws:ecs:eu-central-1:305761728900:task-definition/xavier:602"
#PR_DEPLOY_ENVIRONMENT="dev"

: "${PR_DEPLOY_ENVIRONMENT:?You must set the environment variable PR_DEPLOY_ENVIRONMENT to the either dev or prod.}"
: "${PULL_REQUEST_NAME:?You must set the environment variable PULL_REQUEST_NAME to the name of the pull request branch (only lower-case letters, numbers and dash allowed) e.g. java-17.}"
: "${TASK_DEFINITION_ARN:?You must set the environment variable TASK_DEFINITION_ARN to the ARN of a task definition to publish to the service.}"

set -euo pipefail

if [ "${PR_DEPLOY_ENVIRONMENT}" = "dev" ]; then
  PR_REGION="eu-central-1"
  VPC="vpc-069aba8a7a035f945"
  SUBNET1="subnet-0e09bf6f1b4eb76ae"
  SUBNET2="subnet-0beae6ccc622de1ae"
  CONTAINER_SECURITY_GROUP="sg-0308e60bfd2161b0c"

  CLUSTER_NAME="xavier-dev-cluster"
  ALB_LISTENER_ARN="arn:aws:elasticloadbalancing:eu-central-1:305761728900:listener/app/xavier-dev-pr/1682a3b9198798be/022c9ab899362c27"
  SUBDOMAIN_PREFIX="services-dev-pr"
  ALB_DNS_NAME="xavier-dev-pr-795212970.eu-central-1.elb.amazonaws.com"
  ALB_HOSTED_ZONE="Z215JYRZR1TBD5"
  SERVICE_NAME_PREFIX="xavier-dev-pullrequest"

elif [ "${PR_DEPLOY_ENVIRONMENT}" = "prod" ]; then
  PR_REGION="eu-west-1"
  VPC="vpc-06ec7d26e53d4df17"
  SUBNET1="subnet-0af6c3699bcc3d8b4"
  SUBNET2="subnet-0549da110d44c9131"
  CONTAINER_SECURITY_GROUP="sg-05eb25ea15fd56375"

  CLUSTER_NAME="xavier-prod-pr-ecs"
  ALB_LISTENER_ARN="arn:aws:elasticloadbalancing:eu-west-1:305761728900:listener/app/xavier-prod-pr/09f7ec6efdee7165/e1a4fca15fd05708"
  SUBDOMAIN_PREFIX="services-pr"
  ALB_DNS_NAME="xavier-prod-pr-357480423.eu-west-1.elb.amazonaws.com"
  ALB_HOSTED_ZONE="Z32O12XQLNTSW2"
  SERVICE_NAME_PREFIX="xavier-pullrequest"

else
  echo "Bad environment '${PR_DEPLOY_ENVIRONMENT}'."
  exit -1
fi

PULL_REQUEST_NAME=$(./sanitize-pr-name.py ${PULL_REQUEST_NAME})

HOSTNAME="${SUBDOMAIN_PREFIX}-${PULL_REQUEST_NAME}.clarifruit.com"
ALB_HOSTNAME_LISTENER_PRIORITY=$(./generate-aws-alb-priority.py ${HOSTNAME})

echo "Deploying new ${PR_DEPLOY_ENVIRONMENT} ECS service ${SERVICE_NAME_PREFIX}-${PULL_REQUEST_NAME} to ALB listener with priority ${ALB_HOSTNAME_LISTENER_PRIORITY}..."

STACK_NAME="xavier-${PR_DEPLOY_ENVIRONMENT}-pr-service-${PULL_REQUEST_NAME}"

aws cloudformation deploy \
    --region "${PR_REGION}" \
    --template-file deploy-pr-service.yml \
    --stack-name "${STACK_NAME}" \
    --parameter-overrides \
      PullRequestName="${PULL_REQUEST_NAME}" \
      VPC="${VPC}" \
      Subnet1="${SUBNET1}" \
      Subnet2="${SUBNET2}" \
      ContainerSecurityGroup="${CONTAINER_SECURITY_GROUP}" \
      AlbListenerARN="${ALB_LISTENER_ARN}" \
      AlbListenerPriority="${ALB_HOSTNAME_LISTENER_PRIORITY}" \
      TaskDefinition="${TASK_DEFINITION_ARN}" \
      ClusterName="${CLUSTER_NAME}" \
      SubdomainPrefix="${SUBDOMAIN_PREFIX}" \
      AlbDnsName="${ALB_DNS_NAME}" \
      AlbDnsHostedZoneName="${ALB_HOSTED_ZONE}" \
      ServiceNamePrefix="${SERVICE_NAME_PREFIX}"

aws cloudformation describe-stacks --region "${PR_REGION}" --stack-name "${STACK_NAME}" --query "Stacks[0].Outputs[]" --output "text"
