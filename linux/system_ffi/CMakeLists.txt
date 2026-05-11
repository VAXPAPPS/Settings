cmake_minimum_required(VERSION 3.13)
project(system_ffi LANGUAGES C CXX)

add_library(system_ffi SHARED
  system_ffi_bridge.c
)

target_compile_options(system_ffi PRIVATE -Wall -Wextra -Wno-unused-parameter)

set_target_properties(system_ffi PROPERTIES
  C_STANDARD 11
  POSITION_INDEPENDENT_CODE ON
  OUTPUT_NAME "system_ffi"
)

target_link_libraries(system_ffi PRIVATE)
