# e.g. inputs:
#BITBUCKET_BRANCH=docker-papertrail
#BITBUCKET_BUILD_NUMBER=1
#XAVIER_PUBLISH_DATE=`date +%Y-%d-%m`

: "${XAVIER_PUBLISH_DATE:?You must set the environment variable XAVIER_PUBLISH_DATE to the date of the build e.g. 2021-08-15.}" && \

docker build --platform linux/amd64 -t "xavier:latest-x86_64" .
docker build --platform linux/arm64 -t "xavier:latest-arm64" .

aws ecr get-login-password | docker login --username AWS --password-stdin "305761728900.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com"
DATED_TAG="xavier:${BITBUCKET_BRANCH:-default}-${XAVIER_PUBLISH_DATE}-${BITBUCKET_BUILD_NUMBER:-0}"
REPOSITORY_TAG="305761728900.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/$DATED_TAG"

echo "Pushing to ${REPOSITORY_TAG}-x86_64..."
docker tag "xavier:latest-x86_64" "${REPOSITORY_TAG}-x86_64"
docker push "${REPOSITORY_TAG}-x86_64"

echo "Pushing to ${REPOSITORY_TAG}-arm64..."
docker tag "xavier:latest-arm64" "${REPOSITORY_TAG}-arm64"
docker push "${REPOSITORY_TAG}-arm64"

## BitBucket Pipelines doesn't support docker manifest:
## docker manifest create is only supported on a Docker cli with experimental cli features enabled
## https://community.atlassian.com/t5/Bitbucket-questions/How-do-you-enable-experimental-features-for-Docker-on-Bitbucket/qaq-p/952325
## Hence we will publish the x86_64 build only (using docker-push-aws.sh) as the default until we have a platform that can support it.
echo "Pushing to ${REPOSITORY_TAG}..."
docker manifest create ${REPOSITORY_TAG} ${REPOSITORY_TAG}-x86_64 ${REPOSITORY_TAG}-arm64
docker manifest push --purge ${REPOSITORY_TAG}

echo "Completed AWS Publish of Xavier docker images to the repository:\n${REPOSITORY_TAG}"
