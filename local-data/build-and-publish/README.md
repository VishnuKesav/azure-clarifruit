# Local MongoDB Data Publishing Process

### Overview
This is a solution to allow developers and other Clarifruit staff to locally test against a copy of recent production MongoDB data in a safe way without the risk of damaging any shared environments.  
It can also be used as part of a CI/CD process as a way to safely test deleterious APIs against a dataset which will not cause any harm. 

### Jenkins (or other runner) Script
This process runs on a Jenkins slave, with the script:
```bash
cd local-data/build-and-publish

# Create and publish a new image using docker-in-docker
export INSPECTION_WEEKS=1 
export MONGODB_USERNAME=importer 
./1-dump-mongo-data.sh

# Build and publish monog image with the dumped data
export DATA_TAG="data-$(date +%Y-%d-%m-%H-%M-%S)"
export ECR_REPOSITORY="305761728900.dkr.ecr.eu-central-1.amazonaws.com"
export ECR_REPOSITORY_NAME="xavier-data"
./2-publish-aws.sh
```

It relies on an AWS user with permissions to publish to the Elastic Container Repository (ECR) credentials being accessible to the AWS SDK in context.

It also relies on a MONGODB_PASSWORD value for the importer user being set. 

##### Changes on Jenkins Master
To support the script the following tools were installed on the runner:

- MongoDB client tools 5.0
- docker arm64 support:
```
docker run --rm --privileged tonistiigi/binfmt:latest --install arm64
```
* docker buildx container (as Jenkins user):
```
docker buildx create --use --name build --node build --driver-opt network=host
```