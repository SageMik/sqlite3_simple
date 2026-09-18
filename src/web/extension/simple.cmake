get_filename_component(_repo_root ${CMAKE_CURRENT_LIST_DIR}/../../.. ABSOLUTE)
set(simple_root ${_repo_root}/simple)

file(INSTALL FILES ${_repo_root}/zdic.txt DESTINATION ${CMAKE_BINARY_DIR}/contrib RENAME pinyin.txt) # 替换拼音文件
set(SIMPLE_PINYIN_TEXT ${CMAKE_BINARY_DIR}/contrib/pinyin.txt) # 拼音数据源，供链接命令做文件级依赖
include(${simple_root}/contrib/CMakeRC.cmake)
cmrc_add_resource_library(PINYIN_TEXT TYPE OBJECT NAMESPACE pinyin_text WHENCE ${CMAKE_BINARY_DIR} ${CMAKE_BINARY_DIR}/contrib/pinyin.txt)
get_target_property(PINYIN_CMRC_SOURCES PINYIN_TEXT SOURCES)

set(SIMPLE_WASM_SOURCES
    ${simple_root}/src/entry.cc
    ${simple_root}/src/simple_highlight.cc
    ${simple_root}/src/simple_tokenizer.cc
    ${simple_root}/src/pinyin.cc
)

set(SIMPLE_WASM_CPP_ARGS
    -I ${CMAKE_CURRENT_BINARY_DIR}
    -I ${simple_root}/src
    -I ${CMRC_INCLUDE_DIR}
)

OPTION(SIMPLE_WITH_JIEBA "Option to build with cppjieba" ON)
if(SIMPLE_WITH_JIEBA)
  include(FetchContent)
  FetchContent_Declare(
    cppjieba
    GIT_REPOSITORY https://github.com/yanyiwu/cppjieba.git
    GIT_TAG 194c144d8b5ed1baf3190d07c5226e804454ab47
  )
  FetchContent_GetProperties(cppjieba)
  if(NOT cppjieba_POPULATED)
    FetchContent_Populate(cppjieba)
  endif()
  list(APPEND SIMPLE_WASM_CPP_ARGS
    -DUSE_JIEBA=1
    -I ${cppjieba_SOURCE_DIR}/include
    -I ${cppjieba_SOURCE_DIR}/deps
  )
  message(STATUS "cppjieba source dir: ${cppjieba_SOURCE_DIR}")
endif()

# 拼音数据由 CMRC 展开为巨型 C++ 数组（纯数据，无跨模块优化收益）。
# 三个变体共享同一份目标文件：因此只编译一次，且不带 -g/-flto，避免编译期内存溢出。
function(simple_wasm_add_pinyin base_flags)
  set(objects)
  foreach(source IN LISTS PINYIN_CMRC_SOURCES)
    get_filename_component(source_name "${source}" NAME)
    string(REPLACE "." "_" source_token "${source_name}")
    set(object "${CMAKE_CURRENT_BINARY_DIR}/simple_${source_token}.o")
    add_custom_command(
      OUTPUT ${object}
      COMMAND ${clangxx}
        ${base_flags}
        -O0 -g0
        -fno-rtti
        -x c++ -std=c++14 -c
        -I ${CMRC_INCLUDE_DIR}
        -o ${object}
        ${source}
      DEPENDS ${source} PINYIN_TEXT
      VERBATIM
    )
    list(APPEND objects ${object})
  endforeach()
  add_custom_target(simple_pinyin DEPENDS ${objects})
  set(SIMPLE_PINYIN_OBJECTS ${objects} PARENT_SCOPE)
endfunction()
