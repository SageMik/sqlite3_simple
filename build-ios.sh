#!/bin/sh

set -eu

script_dir="$(cd "$(dirname "$0")" && pwd)"

build_variant() {
    platform="$1"
    out_name="$2"
    build_dir="${script_dir}/ios-build-${platform}"
    install_dir="${script_dir}/ios-install-${platform}"

    cmake "${script_dir}" -G Xcode -DCMAKE_TOOLCHAIN_FILE=ios.toolchain.cmake \
        -DPLATFORM="${platform}" -DENABLE_BITCODE=1 \
        -DCMAKE_INSTALL_PREFIX="" -B "${build_dir}" \
        -DDEPLOYMENT_TARGET=12.0

    cmake --build "${build_dir}" --config Release
    cmake --install "${build_dir}" --config Release --prefix "${install_dir}"
    cp "${install_dir}/bin/libsimple.a" "${script_dir}/${out_name}"
}

build_variant OS64 libsimple-ios.a
build_variant SIMULATOR64COMBINED libsimple-ios-simulator.a
