# Ref: https://docs.newrelic.com/docs/agents/java-agent/additional-installation/install-new-relic-java-agent-docker/
NEWRELIC_AGENT_VERSION=7.4.1

set -euo pipefail

mkdir -p newrelic
cp newrelic.yml ./newrelic/newrelic.yml
if [ -f "./newrelic/newrelic.jar" ]; then
  echo "Already downloaded newrelic, skipping."
else
  curl -o ./newrelic/newrelic.jar "https://download.newrelic.com/newrelic/java-agent/newrelic-agent/${NEWRELIC_AGENT_VERSION}/newrelic-agent-${NEWRELIC_AGENT_VERSION}.jar"
fi