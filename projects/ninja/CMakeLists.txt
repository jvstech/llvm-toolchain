include(FetchContent)
include(ExternalProject)
include(VariableUtils)
include(Validate)

validate(
  EXISTS
    CACHE_DIR
    ROOT_DIR
    TOOLS_DIR)

set_default(NINJA_REPO_URL "https://github.com/ninja-build/ninja")
set_default(NINJA_VERSION "1.11.1")

# Download the Ninja source code at configuration time.
FetchContent_Declare(ninjasrc
  GIT_REPOSITORY "${NINJA_REPO_URL}"
  GIT_TAG "v${NINJA_VERSION}")
FetchContent_GetProperties(ninjasrc)
if (NOT ninjasrc_POPULATED)
  FetchContent_Populate(ninjasrc)
endif()

# Configure and build Ninja at build time.
ExternalProject_Add(ninja-build
  SOURCE_DIR ${ninjasrc_SOURCE_DIR}
  CMAKE_ARGS
    -DROOT_DIR=${ROOT_DIR}
    -DTOOLS_DIR=${TOOLS_DIR}
    -C${CACHE_DIR}/ninja-cache.cmake
  DOWNLOAD_COMMAND ""
  TEST_COMMAND "")

ExternalProject_Get_Property(ninja-build BINARY_DIR)

set_cache(NINJA_DEPENDS_FLAG DEPENDS ninja-build)
