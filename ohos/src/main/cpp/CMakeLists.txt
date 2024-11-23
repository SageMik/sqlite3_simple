cmake_minimum_required(VERSION 3.14)

project(simple_with_sqlite3)

add_library(simple SHARED IMPORTED)
set_target_properties(simple
    PROPERTIES
    IMPORTED_LOCATION ${CMAKE_CURRENT_SOURCE_DIR}/libs/${OHOS_ARCH}/libsimple.so)

add_library(sqlite3 SHARED IMPORTED)
set_target_properties(sqlite3
    PROPERTIES
    IMPORTED_LOCATION ${CMAKE_CURRENT_SOURCE_DIR}/libs/${OHOS_ARCH}/libsqlite3.so)

add_library(entry SHARED entry.cpp)

target_link_libraries(entry PUBLIC
        libace_napi.z.so
        sqlite3
        simple
)