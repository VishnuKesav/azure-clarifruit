## Xavier Docker

### Xavier in Docker
Xavier is a Java 8 application which implements the backend APIs for Clarifruit's web and mobile applications. 

#### Web Service
The process main() runs an embedded Grizzly web server:  
https://javaee.github.io/grizzly/httpserverframework.html

Integrated with Jersey JAX-RS REST implementation:  
https://eclipse-ee4j.github.io/jersey/

A command line argument 'uri' controls the IP address and port bound to by the Grizzly web server.  
e.g. uri=http://127.0.0.1:8082 will allow local connections on port 8082

Typical deployments used the loopback interface address 127.0.0.1. 
In Docker, this cannot work, because the loopback interface only allows connections from within the container. 
In Docker, we must use the 'all interfaces' address 0.0.0.0:  
```
uri=http://0.0.0.0:8080 
```

As a hint to external parties we use the Docker EXPOSE statement to indicate we are listening on this port:
```
EXPOSE 8080/tcp
```

#### Configuration
The configuration of Xavier is loaded based on a 'config' parameter passed as an argument, typical values of which are 'prod', 'dev' or 'local'. Based on the value of this argument, Xavier reads a properties file.   
e.g. prod.conf  
The configuration is loaded using a library Lightbend Config:  
https://github.com/lightbend/config  
This library is critical to the operation of Xavier inside Docker.  
In the past the Xavier ZIP bundle was separately built for different environments, including the environment specific configuration file {env}.conf .

In Docker, we use a feature of the Lightbend Config which can substitute Environment Variables for config values, so that a specific set of Environment Variables can be passed to the container and are then readable as usual by Xavier.

To use this Environment Variable capability, we use the HOCON (.conf) configuration file format for Lightbend Config .   
e.g. docker.conf
```
environment=${XAVIER_ENVIRONMENT}
db.url=${XAVIER_DB_URL}
db.username=${XAVIER_DB_USERNAME}
db.password=${XAVIER_DB_PASSWORD}
```

Will allow the properties listed on the left to be specified by the environment variable names on the right.

The following environment variables _must all_ be set (even if to an empty string) and passed to docker run in order to configure Xavier:
```
# Environment of Xavier. Either 'production' or 'development'. Controls whether Xavier connects to certain AWS resources or uses in-memory alternatives.
XAVIER_ENVIRONMENT=""

# JDBC URL to connect to the Xavier MySQL database. e.g. jdbc:mysql://clarifruit-dev-cluster.clarifruit.com/aclartech?useSSL=false
XAVIER_DB_URL=""
# Username for Xavier to authenticate to MySQL with.
XAVIER_DB_USERNAME=""
# Password for Xavier to authenticate to MySQL with.
XAVIER_DB_PASSWORD=""
# Number of connections to keep open by this instance of Xavier in the Hikari connection pool. e.g. 5 for a development instance
XAVIER_DB_MAXIMUM_POOL_SIZE=""

# The AWS Access Key that Xavier uses to access AWS services.
XAVIER_AWS_ACCESS_KEY=""
# The AWS Secret Key that Xavier uses to access AWS services.
XAVIER_AWS_ACCESS_SECRET=""
# The AWS App Access Key that Xavier uses to access AWS services.
XAVIER_AWS_APP_ACCESS_KEY=""
# The AWS App Secret Key that Xavier uses to access AWS services.
XAVIER_AWS_APP_ACCESS_SECRET=""
# The AWS region in which the services Xavier uses reside.
XAVIER_AWS_REGION=""
# The AWS region in which the simple email services (SES) Xavier uses reside.
XAVIER_AWS_SES_REGION=""

# The Auth0 client secret used for auth APIs (e.g. validating refresh tokens).
XAVIER_AUTH_CLIENT_SECRET=""
# The Auth0 client secret used for auth admin APIs (e.g. creating users).
XAVIER_AUTH_ADMIN_CLIENT_SECRET=""

# Enable the NewRelic Java agent (true/false)
NEW_RELIC_ENABLED=false
# The NewRelic APM application name (e.g. xavier-development, xavier-production, current "clarifruit-dev" or "clarifruit prod" )
NEW_RELIC_APP_NAME=""
# NewRelic license key (authenticates xavier to report APM data to NewRelic's API)
NEW_RELIC_LICENSE_KEY=""
```

### Build Process
The build process (docker/docker-build.sh):
1) Takes the existing built Xavier artefact ZIP file and extracts it
2) Moves the xavier jar out of /lib to the root
3) Extracts the version from the prod.conf file
4) Removes unneeded config files
5) Downloads New Relic and puts the JAR and config into /newrelic
6) Runs docker build 

### Deployment
The docker image will be deployed into 4 repositories:
* AWS Development Elastic Container Registry (ECR)
* AWS Production ECR
* Azure Development Azure Container Registry (ACR)
* Azure Production ACR

The reason to deploy into these separate repositories is to keep the artefacts close to the deployed container infrastructure so that it is fast to spin up instances of the container locally within the environment.

IMPORTANT: The same image must be deployed everywhere, hence the build will fail if any of the registries fail.


### AWS Permissions
Two roles have been created in AWS to support running Xavier as an ECS Fargate task:

#### Development Roles

##### ecsTaskExecutionRole
This is the role Amazon uses to fetch containers from ECR and run resources on your behalf when starting the container.

To allow AWS to read SSM parameters, add this managed policy to the ecsTaskExecutionRole:
arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess

Ref: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/specifying-sensitive-data-parameters.html#secrets-iam-parameters


##### xavier-dev-ecs-task-role
This is the role assumed by the task itself and allows the Java AWS SDK in Xavier to have permissions to call AWS services. 
This could eventually replace the current model we have in which we pass an AWS Secret Key / Access Key for Xavier to use (within AWS).

#### AWS Task Definitions
Task definition details are stored in /docker/task-definition-template.json.
Update these when needed, and they will take effect (memory, properties etc...).
The ECS cluster and service are created centrally by the clarifruit-aws-containers project.

#### AWS Code Deploy
The final part of the deployment of containerised Xavier into AWS uses a Code Deploy job separately configured in the 'clarifruit-aws-containers' repository.
The script task-deployment-create.sh runs a Code Deploy job which does a blue/green deployment to the existing service waiting for it.

