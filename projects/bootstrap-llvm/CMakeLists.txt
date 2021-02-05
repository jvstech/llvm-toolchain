include(ExternalProject)
include(VariableUtils)
include(Validate)

validate(
  EXISTS
    CACHE_DIR
    ROOT_DIR
    TOOLS_DIR
    LLVM_SOURCE_DIR)

# Build a bootstrapped compiler from the existing source for building the 
# runtimes and the final Clang/LLVM.
ExternalProject_Add(llvm-bootstrap
  SOURCE_DIR ${LLVM_SOURCE_DIR}
  CMAKE_GENERATOR Ninja
  CMAKE_ARGS
    -DROOT_DIR=${ROOT_DIR}
    -DTOOLS_DIR=${TOOLS_DIR}
    -C${CACHE_DIR}/bootstrap-llvm-cache.cmake
  DOWNLOAD_COMMAND ""
  TEST_COMMAND ""
  ${NINJA_DEPENDS_FLAG})

ExternalProject_Get_Property(llvm-bootstrap BINARY_DIR)

set_cache(BOOTSTRAP_BUILD_DIR ${BINARY_DIR} PATH)
set_cache(BOOTSTRAP_INSTALL_DIR ${BOOTSTRAP_BUILD_DIR}/bootstrap-llvm PATH)
set_cache(BOOTSTRAP_BIN_DIR ${BOOTSTRAP_INSTALL_DIR}/bin PATH)
