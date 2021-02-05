cmake_minimum_required(VERSION 3.16)

project(LLVM-Standalone-Toolchain LANGUAGES NONE)

if (NOT DEFINED ROOT_DIR)
  get_filename_component(ROOT_DIR "${CMAKE_SOURCE_DIR}/.." ABSOLUTE)
endif()

set(CMAKE_MODULE_PATH "${CMAKE_MODULE_PATH};${ROOT_DIR}/cmake/modules")
set(CACHE_DIR "${ROOT_DIR}/cmake/caches")

# Find ninja. If it can't be found, build it from source and use it.
find_program(NINJA_EXECUTABLE ninja PATHS ${TOOLS_DIR}/ninja/bin)
if (NINJA_EXECUTABLE-NOTFOUND OR NINJA_FORCE_BUILD)
  message(STATUS "Adding Ninja as a build target.")
  add_subdirectory(ninja)
endif()

add_subdirectory(bootstrap-llvm)
add_subdirectory(compiler-rt)
