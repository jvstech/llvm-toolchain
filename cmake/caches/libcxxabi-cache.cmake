include(${CMAKE_CURRENT_LIST_DIR}/common-project-cache.cmake)

enable_cache_variables(
  LIBCXXABI_USE_COMPILER_RT
  LIBCXXABI_USE_LLVM_UNWINDER
)

disable_cache_variables(
  LIBCXXABI_INCLUDE_TESTS
)

# Since we're using libunwind, we need to specify its location.
set_cache(CMAKE_SHARED_LINKER_FLAGS "-Wl,-L${INSTALL_DIR}/lib")
