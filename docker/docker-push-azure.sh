# e.g. XAVIER_TAG="local-$(date +%Y-%d-%m)-0"
: "${XAVIER_TAG:?You must set the environment variable XAVIER_TAG to the branch, date of the build and build number e.g. develop-2021-08-15-4321.}"
: "${XAVIER_AZURE_PASSWORD:?You must set the environment variable XAVIER_AZURE_PASSWORD in order to push to Azure}"
: "${XAVIERCONTAINER_AZURE_PASSWORD:?You must set the environment variable XAVIERCONTAINER_AZURE_PASSWORD in order to push to Azure}"

set -euo pipefail

#TODO: Remove the xavier.azurecr.io publish
REPOSITORY="xavier.azurecr.io"
docker login --username xavier --password ${XAVIER_AZURE_PASSWORD} "${REPOSITORY}"
REPOSITORY_TAG="${REPOSITORY}/xavier:$XAVIER_TAG"

echo "Pushing to ${REPOSITORY_TAG}..."
docker tag "xavier:latest" "${REPOSITORY_TAG}"
docker push "${REPOSITORY_TAG}"

REPOSITORY_TAG_FOR_LATEST="${REPOSITORY}/xavier:latest"
echo "Pushing to ${REPOSITORY_TAG_FOR_LATEST}..."
docker tag "xavier:latest" "${REPOSITORY_TAG_FOR_LATEST}"
docker push "${REPOSITORY_TAG_FOR_LATEST}"


#New repository (created by Terraform) to replace the above
REPOSITORY="xaviercontainer.azurecr.io"
docker login --username xaviercontainer --password ${XAVIERCONTAINER_AZURE_PASSWORD} "${REPOSITORY}"
REPOSITORY_TAG="${REPOSITORY}/xavier:$XAVIER_TAG"

echo "Pushing to ${REPOSITORY_TAG}..."
docker tag "xavier:latest" "${REPOSITORY_TAG}"
docker push "${REPOSITORY_TAG}"

REPOSITORY_TAG_FOR_LATEST="${REPOSITORY}/xavier:latest"
echo "Pushing to ${REPOSITORY_TAG_FOR_LATEST}..."
docker tag "xavier:latest" "${REPOSITORY_TAG_FOR_LATEST}"
docker push "${REPOSITORY_TAG_FOR_LATEST}"
