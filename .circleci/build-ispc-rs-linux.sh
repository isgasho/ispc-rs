#!/bin/bash

set -x

echo "Setting up Rust"
curl https://sh.rustup.rs -sSf | sh -s -- -y
source $HOME/.cargo/env
rustc --version
cargo --version

export LLVM_VERSION=5.0.2
echo "Setting up LLVM ${LLVM_VERSION}"
export LLVM=clang+llvm-${LLVM_VERSION}-x86_64-linux-gnu-ubuntu-16.04
wget http://llvm.org/releases/${LLVM_VERSION}/${LLVM}.tar.xz
mkdir llvm
tar -xf ${LLVM}.tar.xz -C llvm --strip-components=1
export LIBCLANG_PATH=`pwd`/llvm/lib/

echo "Setting up ISPC"
wget -O ispc.tar.gz https://downloads.sourceforge.net/project/ispcmirror/v1.10.0/ispc-v1.10.0-linux.tar.gz
tar -xvf ispc.tar.gz
export PATH=$PATH:`pwd`/ispc-1.10.0-Linux/bin/:`pwd`/ispc-1.10.0-Darwin/bin/
ispc --version

cargo build
cargo test
cargo doc

echo "Building examples"

for d in `ls examples/`; do
		cd examples/${d}/
		pwd
		if [[ "$d" == "simple" ]]; then
				cargo build --features ispc
		fi
		cargo build
		if [[ "$?" != "0" ]]; then
				exit 1
		fi
		cd ../../
done


