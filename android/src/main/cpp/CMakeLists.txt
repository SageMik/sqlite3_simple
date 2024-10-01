cmake_minimum_required(VERSION 3.19)

project(simple_without_sqlite3)

include(FetchContent)

# 切换为原项目指定commit，该commit改进了不编译SQLite时的表现
FetchContent_Declare(simple
    GIT_REPOSITORY https://github.com/wangfenjin/simple.git
    GIT_TAG 473fc89
)
set(BUILD_SQLITE3 OFF)
set(BUILD_TEST_EXAMPLE OFF)
FetchContent_MakeAvailable(simple)
