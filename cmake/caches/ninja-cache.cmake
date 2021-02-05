set(CMAKE_MODULE_PATH "${CMAKE_MODULE_PATH};${ROOT_DIR}/cmake/modules")
include(VariableUtils)

set_cache(CMAKE_BUILD_TYPE Release)
set_cache(CMAKE_INSTALL_PREFIX "${TOOLS_DIR}/ninja" PATH)

set_cache(BUILD_TESTING OFF)
