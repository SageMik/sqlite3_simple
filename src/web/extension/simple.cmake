get_filename_component(_repo_root ${CMAKE_CURRENT_LIST_DIR}/../../.. ABSOLUTE)
set(simple_root ${_repo_root}/simple)

file(INSTALL FILES ${_repo_root}/zdic.txt DESTINATION ${CMAKE_BINARY_DIR}/contrib RENAME pinyin.txt) # 替换拼音文件
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

function(simple_wasm_add_pinyin_objects name common_compile_flags out_var)
  set(objects)
  foreach(source IN LISTS PINYIN_CMRC_SOURCES)
    get_filename_component(source_name "${source}" NAME)
    string(REPLACE "." "_" source_token "${source_name}")
    set(object "${CMAKE_CURRENT_BINARY_DIR}/${name}_${source_token}.o")
    add_custom_command(
      OUTPUT ${object}
      COMMAND ${clangxx}
        ${common_compile_flags}
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
  set(${out_var} ${objects} PARENT_SCOPE)
endfunction()
