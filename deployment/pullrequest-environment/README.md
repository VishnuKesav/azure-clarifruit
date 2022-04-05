# Pull Request Deployments
These scripts deploy and destroy a temporary pull request environment when the label 'deploy' is applied to or removed 
from a GitHub pull request.

The scripts are invoked by the two GitHub workflows:
- pr-deploy-environment.yml
- pr-destroy-environment.yml

#### generate-aws-alb-priority.py
The python script generate-aws-alb-priority.py uses a neat trick to generate a unique Priority value for a listener 
rule on the xavier-dev-pr ALB HTTPS listener. It creates a simplistic hash of the hostname for the temporary environment
by adding the ascii values of the hostname characters (wrapped at 5000).

#### deploy.sh
This runs the AWS CLI to deploy the CloudFormation template deploy-pr-service.yml.
This template creates an ECS Service, Target Group, Listener Rule and DNS Alias.

#### destroy.sh
This deletes the CloudFormation stack created by deploy.sh.
