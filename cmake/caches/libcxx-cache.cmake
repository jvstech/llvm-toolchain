include(${CMAKE_CURRENT_LIST_DIR}/common-project-cache.cmake)

enable_cache_variables(
  LIBCXX_USE_COMPILER_RT
  # Yes, it's actually LIBCXXABI_USE_LLVM_UNWINDER -- not 
  # LIBCXX_USE_LLVM_UNWINDER.
  LIBCXXABI_USE_LLVM_UNWINDER 
)

disable_cache_variables(
  LIBCXX_INCLUDE_DOCS 
  LIBCXX_INCLUDE_BENCHMARKS 
  LIBCXX_INCLUDE_TESTS
  # Prevent the use of libatomic -- __atomic_X functions are provided by
  # Compiler-RT builtins.
  LIBCXX_HAS_ATOMIC_LIB
)

set_cache(LIBCXX_CXX_ABI "libcxxabi")
# Since we're using libunwind, we need to specify its location.
set_cache(CMAKE_SHARED_LINKER_FLAGS "-Wl,-L${INSTALL_DIR}/lib")
