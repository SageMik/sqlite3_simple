#!/bin/sh

current_dir="$(cd "$(dirname "$0")" && pwd)"

if [ "${IOS_SIMULATOR:-false}" = "true" ]; then
    build_dir="${current_dir}/ios-simulator-build"
    lib_prefix="${current_dir}/out-simulator"
    platform=SIMULATOR64COMBINED
else
    build_dir="${current_dir}/ios-build"
    lib_prefix="${current_dir}/out"
    platform=OS64
fi

cmake "$current_dir" -G Xcode -DCMAKE_TOOLCHAIN_FILE=ios.toolchain.cmake \
    -DPLATFORM=$platform -DENABLE_BITCODE=1 \
    -DCMAKE_INSTALL_PREFIX="" -B "$build_dir" \
    -DDEPLOYMENT_TARGET=12.0

cd "$build_dir" || exit

cmake --build "$build_dir" --config Release
cmake --install "$build_dir" --config Release --prefix "${lib_prefix}"