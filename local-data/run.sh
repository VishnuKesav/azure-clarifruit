# Run a local MongoDB container with the most recent week of inspection data and all config data embedded in it.
# Note you will need to be have configured AWS CLI credentials before running, e.g.
# aws sso login
# Ref: https://clarifruit.atlassian.net/wiki/spaces/RD/pages/1861287937/AWS+CLI+with+Single+Sign-On+SSO

set -e

aws ecr get-login-password --region eu-central-1 | docker login --username AWS --password-stdin 305761728900.dkr.ecr.eu-central-1.amazonaws.com

docker kill local-clarifruit-mongo-data || echo "Mongo local data not running."

docker pull 305761728900.dkr.ecr.eu-central-1.amazonaws.com/xavier-data:latest
docker run -d --rm --name local-clarifruit-mongo-data -p 27017:27017 305761728900.dkr.ecr.eu-central-1.amazonaws.com/xavier-data:latest
