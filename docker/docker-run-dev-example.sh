docker run -p 8082:8080 -p 5005:5005 \
           -v "$(pwd)/../src/main/resources/local.conf:/opt/xavier/docker.conf"  \
           --rm \
           -it \
           xavier:latest \
           java \
           "-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=*:5005" \
           -XX:+UseContainerSupport \
           -XX:InitialRAMPercentage=40.0 \
           -XX:MinRAMPercentage=20.0 \
           -XX:MaxRAMPercentage=90.0 \
           -Dlog4j.configuration=file:/opt/xavier/log4j.properties \
           -cp "/opt/xavier:/opt/xavier/*:/opt/xavier/lib/*" \
           com.aclartech.Main \
           uri=http://0.0.0.0:8080,config=docker
