set(CMAKE_MODULE_PATH "${CMAKE_MODULE_PATH};${ROOT_DIR}/cmake/modules")
include(VariableUtils)

find_program(ninjaExe ninja
  PATHS ${TOOLS_DIR}/ninja/bin
  REQUIRED)

set_cache(CMAKE_BUILD_TYPE Release)
set_cache(CMAKE_INSTALL_PREFIX "${INSTALL_DIR}" PATH)
set_cache(CMAKE_GENERATOR Ninja)
set_cache(CMAKE_MAKE_PROGRAM ${ninjaExe} FILEPATH)

set_cache(CMAKE_C_COMPILER "${BOOTSTRAP_BIN_DIR}/clang" FILEPATH)
set_cache(CMAKE_CXX_COMPILER "${BOOTSTRAP_BIN_DIR}/clang++" FILEPATH)
set_cache(CMAKE_ASM_COMPILER "${BOOTSTRAP_BIN_DIR}/clang")
set_cache(LLVM_CONFIG_PATH "${BOOTSTRAP_BIN_DIR}/llvm-config" FILEPATH)
