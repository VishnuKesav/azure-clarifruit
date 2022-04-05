: "${VERSION:?You must set the environment variable VERSION to the version of the xavier build e.g. 1.0.123 .}"

GIT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
GIT_MESSAGE=$(git log -1 HEAD --pretty=format:%s)
GIT_MESSAGE_TRUNCATED=$(git log -1 HEAD --pretty=format:%s | cut -c 1-255)
GIT_COMMITTER_EMAIL=$(git log -1 --pretty=format:"%ce")

if [[ $GIT_BRANCH = "master" ]]
then
  NEW_RELIC_APP_KEY=$NEW_RELIC_APP
elif [[ $GIT_BRANCH = "develop" ]]
then
  NEW_RELIC_APP_KEY=$DEV_NEW_RELIC_APP
else
  NEW_RELIC_APP_KEY="unknown_branch"
fi


curl -X POST "https://api.eu.newrelic.com/v2/applications/${NEW_RELIC_APP_KEY}/deployments.json" \
     -H "X-Api-Key:${NEW_RELIC_BUILD_SERVER_KEY}" -i \
     -H "Content-Type: application/json" \
     -d \
"{
  \"deployment\": {
    \"revision\": \"${VERSION}\",
    \"changelog\": \"git commit message: ${GIT_MESSAGE}\ngit commit id: ${BITBUCKET_COMMIT}\ngit branch: ${GIT_BRANCH}\nbuild number: ${BITBUCKET_BUILD_NUMBER}\",
    \"description\": \"${GIT_BRANCH}: ${GIT_MESSAGE_TRUNCATED}. (build: ${BITBUCKET_BUILD_NUMBER}, git: ${BITBUCKET_COMMIT})\",
    \"user\": \"${GIT_COMMITTER_EMAIL}\"
  }
}"
