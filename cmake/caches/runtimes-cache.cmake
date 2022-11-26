include(${CMAKE_CURRENT_LIST_DIR}/common-project-cache.cmake)

set_cache(LLVM_ENABLE_RUNTIMES "libcxx;libcxxabi;libunwind")

### libc++

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

### libc++abi

enable_cache_variables(
  LIBCXXABI_USE_COMPILER_RT
  LIBCXXABI_USE_LLVM_UNWINDER
)

disable_cache_variables(
  LIBCXXABI_INCLUDE_TESTS
)

### libunwind

enable_cache_variables(
  LIBUNWIND_USE_COMPILER_RT
)
