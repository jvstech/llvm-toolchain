include(ExternalProject)
include(VariableUtils)
include(Validate)

validate(
  EXISTS
    CACHE_DIR
    ROOT_DIR
    INSTALL_DIR
    LLVM_SOURCE_DIR
    BOOTSTRAP_BIN_DIR)

ExternalProject_Add(compiler-rt
  SOURCE_DIR ${LLVM_SOURCE_DIR}/../compiler-rt
  CMAKE_GENERATOR Ninja
  CMAKE_ARGS
    -DROOT_DIR=${ROOT_DIR}
    -DINSTALL_DIR=${INSTALL_DIR}
    -DLLVM_SOURCE_DIR=${LLVM_SOURCE_DIR}
    -DBOOTSTRAP_BIN_DIR=${BOOTSTRAP_BIN_DIR}
    -C${CACHE_DIR}/compiler-rt-cache.cmake
  DOWNLOAD_COMMAND ""
  TEST_COMMAND ""
  DEPENDS llvm-bootstrap)
