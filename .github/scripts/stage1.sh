#!/bin/sh

set -xe

PYTHON3_VERSION=$1
HOST_ARCH=$2
HOST_ABI=$3
DOCKER_IMAGE=$4

sudo docker run --privileged --network=host --rm --platform="linux/${HOST_ARCH}" -v $(pwd):/work "${DOCKER_IMAGE}" \
    sh -c "chmod a+x /work/stage2.sh && /work/stage2.sh ${PYTHON3_VERSION} ${HOST_ARCH}-linux-${HOST_ABI}"

if [ -d "$(pwd)/build" ]; then
  sudo chmod -R a+wr "$(pwd)/build" ;
fi
