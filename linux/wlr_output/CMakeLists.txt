cmake_minimum_required(VERSION 3.13)
project(wlr_output LANGUAGES C CXX)

# ─── Dependencies ─────────────────────────────────────────────────────────────
find_package(PkgConfig REQUIRED)
pkg_check_modules(WAYLAND_CLIENT REQUIRED IMPORTED_TARGET wayland-client)

# ─── Protocol code (pre-generated from wlr-output-management-unstable-v1.xml)
# Files are generated at project root build time and copied here.
# They are committed to avoid requiring wayland-scanner at user build time.
set(WLR_PROTO_H   "${CMAKE_CURRENT_SOURCE_DIR}/wlr_output_management.h")
set(WLR_PROTO_C   "${CMAKE_CURRENT_SOURCE_DIR}/wlr_output_management.c")

# ─── Shared library ───────────────────────────────────────────────────────────
add_library(wlr_output SHARED
    "${WLR_PROTO_C}"
    wlr_output_manager.cpp
    wlr_ffi_bridge.cpp
)

set_target_properties(wlr_output PROPERTIES
    CXX_STANDARD 17
    C_STANDARD   11
    OUTPUT_NAME  "wlr_output"
    SOVERSION    1
    VERSION      1.0.0
    # Load from same dir as executable
    INSTALL_RPATH "$ORIGIN"
)

target_include_directories(wlr_output
    PUBLIC  "${CMAKE_CURRENT_SOURCE_DIR}"
    PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}"
)

target_link_libraries(wlr_output
    PRIVATE PkgConfig::WAYLAND_CLIENT
)

target_compile_options(wlr_output PRIVATE
    -Wall
    -Wno-unused-parameter
    $<$<CONFIG:Release>:-O3>
    $<$<CONFIG:Debug>:-g>
)

# Suppress "missing field initializer" warnings from wayland-scanner output
set_source_files_properties(wlr_output_manager.cpp PROPERTIES
    COMPILE_FLAGS "-Wno-missing-field-initializers"
)

