# e.g. inputs:
#BITBUCKET_BRANCH=docker-papertrail
#BITBUCKET_BUILD_NUMBER=1
#XAVIER_PUBLISH_DATE=`date +%Y-%d-%m`

: "${XAVIER_PUBLISH_DATE:?You must set the environment variable XAVIER_PUBLISH_DATE to the date of the build e.g. 2021-08-15.}" && \
: "${XAVIER_AZURE_PASSWORD:?You must set the environment variable XAVIER_AZURE_PASSWORD in order to push to Azure}" && \

docker build --platform linux/amd64 -t "xavier:latest-x86_64" .
docker build --platform linux/arm64 -t "xavier:latest-arm64" .

REPOSITORY="xavier.azurecr.io"
docker login --username xavier --password ${XAVIER_AZURE_PASSWORD} "${REPOSITORY}"
DATED_TAG="xavier:${BITBUCKET_BRANCH:-default}-${XAVIER_PUBLISH_DATE}-${BITBUCKET_BUILD_NUMBER:-0}"
REPOSITORY_TAG="${REPOSITORY}/$DATED_TAG"

echo "Pushing to ${REPOSITORY_TAG}-x86_64..."
docker tag "xavier:latest-x86_64" "${REPOSITORY_TAG}-x86_64"
docker push "${REPOSITORY_TAG}-x86_64"

echo "Pushing to ${REPOSITORY_TAG}-arm64..."
docker tag "xavier:latest-arm64" "${REPOSITORY_TAG}-arm64"
docker push "${REPOSITORY_TAG}-arm64"

## Publish multi-platform manifest
docker manifest create ${REPOSITORY_TAG} ${REPOSITORY_TAG}-x86_64 ${REPOSITORY_TAG}-arm64
docker manifest push --purge ${REPOSITORY_TAG}

echo "Completed AWS Publish of Xavier docker images to the repository:\n${REPOSITORY_TAG}"
