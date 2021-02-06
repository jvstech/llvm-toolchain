include(ExternalProject)
include(VariableUtils)
include(Validate)

validate(
  HAS_VALUE
    BOOTSTRAP_BIN_DIR
    BOOTSTRAP_BUILD_DIR
  EXISTS
    CACHE_DIR
    ROOT_DIR
    INSTALL_DIR
    LLVM_SOURCE_DIR)

# Reconfigure and rebuild the bootstrapped version of Clang to use Compiler-RT,
# libunwind, and libc++ by default.
set(configArgs
  -DCLANG_DEFAULT_CXX_STDLIB=libc++
  -DCLANG_DEFAULT_RTLIB=compiler-rt
  -DCLANG_DEFAULT_UNWINDLIB=libunwind)
add_custom_target(clang-stage2 ALL
  ${CMAKE_COMMAND} ${configArgs} ${LLVM_SOURCE_DIR}
  COMMAND ${CMAKE_COMMAND} --build .
  COMMAND ${CMAKE_COMMAND} --build . --target install
  WORKING_DIRECTORY ${BOOTSTRAP_BUILD_DIR}
  DEPENDS libcxx
  COMMENT "Reconfiguring and rebuilding bootstrapped Clang to use just-built libraries by default")

# Now configure and build the final version of Clang/LLVM.
ExternalProject_Add(llvm
  SOURCE_DIR ${LLVM_SOURCE_DIR}
  CMAKE_GENERATOR Ninja
  CMAKE_ARGS
    -DROOT_DIR=${ROOT_DIR}
    -DINSTALL_DIR=${INSTALL_DIR}
    -DBOOTSTRAP_BUILD_DIR=${BOOTSTRAP_BUILD_DIR}
    -DBOOTSTRAP_BIN_DIR=${BOOTSTRAP_BIN_DIR}
    -C${CACHE_DIR}/llvm-cache.cmake
  DOWNLOAD_COMMAND ""
  TEST_COMMAND ""
  DEPENDS clang-stage2)
  