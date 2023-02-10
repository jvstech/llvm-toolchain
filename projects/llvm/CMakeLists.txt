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

if (NOT "${CMAKE_SYSTEM_NAME}" STREQUAL "Windows") 
  # Reconfigure and rebuild the bootstrapped version of Clang to use Compiler-RT,
  # libunwind, and libc++ by default.
  set(configArgs
    -DBOOTSTRAP_RECONFIGURING=TRUE)
  add_custom_target(clang-stage2 ALL
    ${CMAKE_COMMAND} ${configArgs} ${LLVM_SOURCE_DIR}
    COMMAND ${CMAKE_COMMAND} --build .
    COMMAND ${CMAKE_COMMAND} --build . --target install
    WORKING_DIRECTORY ${BOOTSTRAP_BUILD_DIR}
    DEPENDS runtimes
    COMMENT "Reconfiguring and rebuilding bootstrapped Clang to use just-built libraries by default")
  set(llvmDependsArg DEPENDS clang-stage2)
  set(crossBuildArgs -DBOOTSTRAP_BIN_DIR=${BOOTSTRAP_BIN_DIR})
else()
  validate(
    HAS_VALUE
      HOST_ARCH
    EXISTS
      LLVM_WINSYSROOT)
  set(crossBuildArgs 
    -DCMAKE_SYSTEM_NAME=Windows 
    -DCMAKE_TOOLCHAIN_FILE=${LLVM_SOURCE_DIR}/cmake/platforms/WinMsvc.cmake 
    -DLLVM_NATIVE_TOOLCHAIN=${BOOTSTRAP_INSTALL_DIR} 
    -DLLVM_WINSYSROOT=${LLVM_WINSYSROOT} 
    -DHOST_ARCH=${HOST_ARCH})
  if (MSVC_VER)
    set(crossBuildArgs ${crossBuildArgs} 
      -DMSVC_VER=${MSVC_VER})
  endif()
  if (WINSDK_VER)
    set(crossBuildArgs ${crossBuildArgs} 
      -DWINSDK_VER=${WINSDK_VER})
  endif()
endif()

# Now configure and build the final version of Clang/LLVM.
ExternalProject_Add(llvm
  SOURCE_DIR ${LLVM_SOURCE_DIR}
  CMAKE_GENERATOR Ninja
  CMAKE_ARGS
    -DROOT_DIR=${ROOT_DIR}
    -DINSTALL_DIR=${INSTALL_DIR}
    -DBOOTSTRAP_BUILD_DIR=${BOOTSTRAP_BUILD_DIR}
    ${crossBuildArgs}
    -C${CACHE_DIR}/llvm-cache.cmake
  DOWNLOAD_COMMAND ""
  TEST_COMMAND ""
  ${llvmDependsArg})
  