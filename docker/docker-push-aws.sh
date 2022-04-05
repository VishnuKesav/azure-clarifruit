# e.g. XAVIER_TAG="local-$(date +%Y-%d-%m)-0"
: "${XAVIER_TAG:?You must set the environment variable XAVIER_TAG to the branch, date of the build and build number e.g. develop-2021-08-15-4321.}"
: "${ECR_REPOSITORY:?You must set the environment variable ECR_REPOSITORY to the URI of the ECR repository for Xavier e.g. 305761728900.dkr.ecr.eu-central-1.amazonaws.com.}"
: "${ECR_REPOSITORY_NAME:?You must set the environment variable ECR_REPOSITORY_NAME to the name of the ECR repository for Xavier e.g. xavier.}"

set -euo pipefail

aws ecr get-login-password | docker login --username AWS --password-stdin "${ECR_REPOSITORY}"
REPOSITORY_TAG="${ECR_REPOSITORY}/${ECR_REPOSITORY_NAME}:${XAVIER_TAG}"

echo "Pushing to ${REPOSITORY_TAG}..."
docker tag "xavier:latest" "${REPOSITORY_TAG}"
echo "Tagged!"
docker push "${REPOSITORY_TAG}"
echo "Pushed!"