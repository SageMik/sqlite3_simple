cmake_minimum_required(VERSION 3.19)

set(BUILD_TEST_EXAMPLE OFF)

# 需要在最外层的 CMakeLists.txt 的 project() 前调用，否则无法生效
# https://cmake.org/cmake/help/latest/variable/CMAKE_OSX_ARCHITECTURES.html#variable:CMAKE_OSX_ARCHITECTURES
if (APPLE)
   set(CMAKE_OSX_ARCHITECTURES "x86_64;arm64" CACHE STRING "")
   set(CMAKE_OSX_DEPLOYMENT_TARGET "10.11" CACHE STRING "Minimum OS X deployment version")
   set(BUILD_SQLITE3 ON) # MacOS 下，开启 SQLite 编译体积更小
else()
   set(BUILD_SQLITE3 OFF)
endif()

project(simple-native)

include(FetchContent)

FetchContent_Declare(simple
    GIT_REPOSITORY https://github.com/wangfenjin/simple.git
    GIT_TAG 632fd7ba710ff54b8c6de1220bb47253132b94e5
)
FetchContent_MakeAvailable(simple)
