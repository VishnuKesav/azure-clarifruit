# e.g. DATA_TAG="clarifruit-mongo-data-$(date +%Y-%d-%m)"
: "${DATA_TAG:?You must set the environment variable DATA_TAG to the tag of the data build to publish e.g. clarifruit-mongo-data-2021-08-15-4321.}"
: "${ECR_REPOSITORY:?You must set the environment variable ECR_REPOSITORY to the URI of the ECR repository for Xavier data e.g. 305761728900.dkr.ecr.eu-central-1.amazonaws.com.}"
: "${ECR_REPOSITORY_NAME:?You must set the environment variable ECR_REPOSITORY_NAME to the name of the ECR repository for Xavier data e.g. xavier-data.}"

set -e

aws ecr get-login-password --region eu-central-1 | docker login --username AWS --password-stdin "${ECR_REPOSITORY}"

REPOSITORY_TAG="${ECR_REPOSITORY}/${ECR_REPOSITORY_NAME}:${DATA_TAG}"
REPOSITORY_TAG_LATEST="${ECR_REPOSITORY}/${ECR_REPOSITORY_NAME}:latest"
echo "$(date): Building and pushing ${REPOSITORY_TAG}..."
docker buildx build --push -t "${REPOSITORY_TAG}" -t "${REPOSITORY_TAG_LATEST}" --platform linux/amd64,linux/arm64 .
