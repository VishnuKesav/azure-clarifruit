set -euo pipefail

./download-newrelic.sh
./extract-xavier.sh
cp ../src/main/resources/log4j.properties .

docker build -t "xavier:latest" .

./container-test.sh
