#!/bin/bash
set -euo pipefail


# 1. Fetch and setup test framework.
# For more info and usage examples, see:
#   https://github.com/GoogleContainerTools/container-structure-test

# only linux and osx are supported
if [[ "${OSTYPE}" == "linux-gnu" ]]; then
  cst_ostype="linux"
elif [[ "${OSTYPE}" == "darwin"* ]]; then
  cst_ostype="darwin"
else
  echo "Unsupported operating system[${OSTYPE}]"
  exit 1
fi

CONTAINER_DIR="build/tool"
mkdir -p "${CONTAINER_DIR}"
CONTAINER_TOOL="${CONTAINER_DIR}/container-structure-test-${cst_ostype}-amd64"
if [ -f "$CONTAINER_TOOL" ]; then
    echo "$CONTAINER_TOOL exists. Skipping download."
else
    echo "$CONTAINER_TOOL does not exist. Downloading..."
    wget -N \
         -P "${CONTAINER_DIR}" \
          https://storage.googleapis.com/container-structure-test/latest/container-structure-test-${cst_ostype}-amd64
    chmod +x build/tool/container-structure-test-${cst_ostype}-amd64
fi


# 2. Test using container-structure-test.
$CONTAINER_TOOL test \
    --image xavier:latest \
    --config "container-test.yaml"
