# Extract the Xavier ZIP deployment package and prep for

set -euo pipefail

rm -rf ./lib
unzip -o ../target/xavier-package.zip
cp docker.conf.template docker.conf
echo "version=\"$VERSION\"" >> docker.conf

rm -rf ./deployment
mv lib/xavier-*.jar xavier.jar
