include(ExternalProject)
include(VariableUtils)
include(Validate)

validate(
  HAS_VALUE
    BOOTSTRAP_BIN_DIR
  EXISTS
    CACHE_DIR
    ROOT_DIR
    INSTALL_DIR
    LLVM_SOURCE_DIR)

get_filename_component(srcDir "${LLVM_SOURCE_DIR}/../libcxx" ABSOLUTE)
if (NOT IS_DIRECTORY "${srcDir}")
  message(FATAL_ERROR "libc++ source directory not found: ${srcDir}")
endif()

ExternalProject_Add(libcxx
  SOURCE_DIR ${srcDir}
  CMAKE_GENERATOR Ninja
  CMAKE_ARGS
    -DROOT_DIR=${ROOT_DIR}
    -DINSTALL_DIR=${INSTALL_DIR}
    -DBOOTSTRAP_BIN_DIR=${BOOTSTRAP_BIN_DIR}
    -C${CACHE_DIR}/libcxx-cache.cmake
  DOWNLOAD_COMMAND ""
  TEST_COMMAND ""
  DEPENDS libcxxabi)
  