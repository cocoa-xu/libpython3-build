#!/bin/sh

set -xe

PYTHON3_VERSION=$1
HOST_TRIPLET=$2

export DEBIAN_FRONTEND=noninteractive
case "${HOST_TRIPLET}" in
  riscv64-linux-*)
    apt-get update
    apt-get install -y --no-install-recommends curl gcc g++ git build-essential ca-certificates gettext xz-utils zlib1g-dev libssl-dev libffi-dev liblzma-dev libreadline-dev libbz2-dev libncurses-dev
    ;;
  *)
    yum install -y curl gcc gcc-c++ git make gettext xz zlib-devel openssl-devel libffi-devel lzma-devel readline-devel bzip2 bzip2-devel ncurses-devel xz-devel
    ;;
esac

rm -rf /work/build
mkdir -p /work/build
chmod a+rw /work/build

export ROOTDIR="/work"
export CURRENT_DIR=$(pwd)
curl -fSL "https://www.python.org/ftp/python/${PYTHON3_VERSION}/Python-${PYTHON3_VERSION}.tgz" -o "Python-${PYTHON3_VERSION}.tgz"
XZ_OPT="-k"
tar -xzf "Python-${PYTHON3_VERSION}.tgz"

export DESTDIR="${ROOTDIR}/build/python3"
export XZ_OPT="-e -T0 -9"
rm -rf "${DESTDIR}"
mkdir -p "${DESTDIR}"

cd "${CURRENT_DIR}"
cd "Python-${PYTHON3_VERSION}"
./configure --prefix=/ --enable-optimizations --with-lto=full --enable-shared=yes --with-static-libpython=no
make -j$(nproc)
make DESTDIR="${DESTDIR}" install

cd "${DESTDIR}"
tar -czf "${ROOTDIR}/build/libpython3-${HOST_TRIPLET}.tar.gz" .
cd "${ROOTDIR}/build"
sha256sum libpython3-${HOST_TRIPLET}.tar.gz | tee libpython3-${HOST_TRIPLET}.tar.gz.sha256

cd "${CURRENT_DIR}"
rm -rf "Python-${PYTHON3_VERSION}"
