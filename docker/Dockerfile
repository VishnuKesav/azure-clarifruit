FROM alpine

RUN apk upgrade --no-cache && \
    apk add --no-cache openjdk17-jre-headless

WORKDIR /opt/xavier

# Add layers of files to the docker image. Order is significant, from least changing to most changing.
ADD newrelic/ newrelic/
ADD lib/ lib/
ADD log4j.properties .
ADD docker.conf .
ADD xavier.jar .

# Hint to docker hosts about ports being used
EXPOSE 8080/tcp

# Java run statement
CMD java -XX:+UseContainerSupport \
         -XX:InitialRAMPercentage=40.0 \
         -XX:MinRAMPercentage=20.0 \
         -XX:MaxRAMPercentage=90.0 \
         -javaagent:/opt/xavier/newrelic/newrelic.jar \
         -Dlog4j.configuration=file:/opt/xavier/log4j.properties \
         -Dnewrelic.config.agent_enabled=${NEW_RELIC_ENABLED} \
         -Dnewrelic.config.app_name="${NEW_RELIC_APP_NAME}" \
         -Dnewrelic.config.license_key=${NEW_RELIC_LICENSE_KEY} \
         -cp /opt/xavier:/opt/xavier/*:/opt/xavier/lib/* \
         com.aclartech.Main \
         uri=http://0.0.0.0:8080,config=docker
