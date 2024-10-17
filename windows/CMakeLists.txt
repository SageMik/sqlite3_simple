cmake_minimum_required(VERSION 3.14)

set(PROJECT_NAME "sqlite3_simple")
project(${PROJECT_NAME} LANGUAGES CXX)

cmake_policy(VERSION 3.14...3.25)

file(GLOB simple "${CMAKE_CURRENT_SOURCE_DIR}/simple.dll")

set(sqlite3_simple_bundled_libraries
  "${simple}"
  PARENT_SCOPE
)