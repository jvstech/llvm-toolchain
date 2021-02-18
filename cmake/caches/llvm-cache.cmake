include(${CMAKE_CURRENT_LIST_DIR}/common-project-cache.cmake)

enable_cache_variables(
  LLVM_ENABLE_ASSERTIONS
  LLVM_ENABLE_MODULES
  LLVM_INSTALL_UTILS
)

disable_cache_variables(
  CLANG_ENABLE_ARCMT

  LLVM_ENABLE_LIBPFM
  LLVM_ENABLE_LIBEDIT
  LLVM_ENABLE_TERMINFO
)

set_cache(CLANG_TABLEGEN "${BOOTSTRAP_BUILD_DIR}/bin/clang-tblgen" FILEPATH)
set_cache(LLVM_TABLEGEN "${BOOTSTRAP_BUILD_DIR}/bin/llvm-tblgen" FILEPATH)

set_cache(LLVM_ENABLE_PROJECTS "clang;clang-tools-extra;lld")
set_cache(LLVM_TARGETS_TO_BUILD "all")

if (NOT "${CMAKE_SYSTEM_NAME}" STREQUAL "Windows")
  enable_cache_variables(
    LLVM_ENABLE_LLD
    LLVM_ENABLE_LIBCXX)
    
  set_cache_variables(STRING 
    VARIABLES
      LLVM_ENABLE_LIBXML2
      LLVM_ENABLE_ZLIB
    VALUE OFF)

  set_cache(CMAKE_CXX_FLAGS "-I${INSTALL_DIR}/include/c++/v1" PATH)

  set_cache_variables(STRING
    VARIABLES
      CMAKE_EXE_LINKER_FLAGS
      CMAKE_MODULE_LINKER_FLAGS
      CMAKE_SHARED_LINKER_FLAGS
    VALUE "-Wl,-L${INSTALL_DIR}/lib")
  
  set_cache(CLANG_DEFAULT_CXX_STDLIB "libc++")
  set_cache(CLANG_DEFAULT_LINKER "lld")
  set_cache(CLANG_DEFAULT_RTLIB "compiler-rt")
  set_cache(CLANG_DEFAULT_UNWINDLIB "libunwind")
else()
  set_cache(CMAKE_AR "${BOOTSTRAP_BUILD_DIR}/bin/llvm-lib" FILEPATH)
endif()

