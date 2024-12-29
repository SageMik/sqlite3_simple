# The Flutter tooling requires that developers have CMake 3.10 or later
# installed. You should not increase this version, as doing so will cause
# the plugin to fail to compile for some customers of the plugin.
cmake_minimum_required(VERSION 3.10)

# Project-level configuration.
set(PROJECT_NAME "sqlite3_simple")
project(${PROJECT_NAME} LANGUAGES CXX)

# This value is used when generating builds using this plugin, so it must
# not be changed.
set(PLUGIN_NAME "sqlite3_simple_plugin")

include(FetchContent)

FetchContent_Declare(simple_native
    GIT_REPOSITORY https://github.com/SageMik/sqlite3_simple
    GIT_TAG Nv1.0.3
)
FetchContent_MakeAvailable(simple_native)

#install(TARGETS simple DESTINATION lib)
