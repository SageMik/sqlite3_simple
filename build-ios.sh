#!/bin/sh

simulator=false
if [ "$1" = "-simulator" ]; then
  simulator=true
fi

current_dir=$(pwd)/$(dirname "$0")
if [ "$simulator" = false ]; then
    build_dir="${current_dir}/ios-build"
    lib_prefix="${current_dir}/ios-output"
    platform=OS64
else
    build_dir="${current_dir}/ios-simulator-build"
    lib_prefix="${current_dir}/ios-simulator-output"
    platform=SIMULATOR64COMBINED
fi

cmake "$current_dir" -G Xcode -DCMAKE_TOOLCHAIN_FILE=ios.toolchain.cmake \
    -DPLATFORM=$platform -DENABLE_BITCODE=1 \
    -DCMAKE_INSTALL_PREFIX="" -B "$build_dir" \
    -DDEPLOYMENT_TARGET=12.0

cd "$build_dir" || exit

cmake --build "$build_dir" --config Release
cmake --install "$build_dir" --config Release --prefix "${lib_prefix}"