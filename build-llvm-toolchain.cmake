macro(set_default varName value)
  if (NOT DEFINED ${varName} OR "" STREQUAL "${${varName}}")
    set(${varName} ${value})
  endif()
endmacro()

set_default(LLVM_PROJECT_REPO_URL "https://github.com/llvm/llvm-project")
set_default(LLVM_VERSION "15.0.5")
option(USE_LLVM_MAIN_BRANCH "Use the main branch of the LLVM source repo")
option(UPDATE_SOURCE
  "Ensure the LLVM source is at the HEAD commit")
option(FORCE_UPDATE_SOURCE
  "Ensure the LLVM source is at the HEAD commit and discard local changes")

set(ROOT_DIR ${CMAKE_CURRENT_LIST_DIR})

set_default(SOURCE_DIR "source")
get_filename_component(SOURCE_DIR_NAME "${SOURCE_DIR}" NAME)

set_default(BUILD_DIR "build")
get_filename_component(BUILD_DIR_NAME "${BUILD_DIR}" NAME)

set_default(INSTALL_DIR "install")
get_filename_component(INSTALL_DIR_NAME "${INSTALL_DIR}" NAME)

set_default(TOOLS_DIR "tools")
get_filename_component(TOOLS_DIR_NAME "${TOOLS_DIR}" NAME)

set_default(CMAKE_BUILD_TYPE "Release")
set_default(BUILD_TYPE "${CMAKE_BUILD_TYPE}")
set_default(NINJA_FORCE_BUILD FALSE)

function(check_dir_contents outVar dir)
  if (NOT IS_DIRECTORY "${dir}")
    set(${outVar} FALSE PARENT_SCOPE)
    return()
  endif()

  foreach (fileName ${ARGN})
    if (NOT EXISTS "${dir}/${fileName}")
      set(${outVar} FALSE PARENT_SCOPE)
      return()
    endif()
  endforeach()

  set(${outVar} TRUE PARENT_SCOPE)
endfunction()

# This is a list of some common files expected to exist in the LLVM source 
# directory. It can (and perhaps should) have files added or changed as
# necessary to support specific tags or LLVM versions.
set(expectedLLVMSourceFiles
  cmake/config-ix.cmake
  cmake/modules/AddLLVM.cmake
  cmake/platforms/WinMsvc.cmake)

# Check to make sure the source directory exists and that some common, expected
# files exist in it.
check_dir_contents(sourceMatches ${SOURCE_DIR} ${expectedLLVMSourceFiles})
if (NOT sourceMatches)
  # Check to see if the "llvm" subdirectory exists and try again.
  if (IS_DIRECTORY "${SOURCE_DIR}/llvm")
    check_dir_contents(sourceMatches "${SOURCE_DIR}/llvm" ${expectedLLVMSourceFiles})
    if (sourceMatches)
      set(SOURCE_DIR "${SOURCE_DIR}/llvm")
    endif()
  endif()

  # If the "llvm" source directory couldn't be found, change the source 
  # directory to one under the root directory for download.
  if (NOT sourceMatches)
    set(SOURCE_DIR ${ROOT_DIR}/${SOURCE_DIR_NAME})
  endif()
endif()

if (NOT sourceMatches)
  set(downloadSource TRUE)
endif()

# Download the LLVM source code if required.
if (downloadSource)
  message(STATUS "Source directory: ${SOURCE_DIR}")
  message("The source directory either does not exist or does not appear to be"
    "a valid LLVM source tree. The source will need to be acquired from"
    "${LLVM_PROJECT_REPO_URL}.")
  if ("" STREQUAL "${GIT_EXECUTABLE}" OR NOT EXISTS "${GIT_EXECUTABLE}")
    find_program(GIT_EXECUTABLE git REQUIRED)
  endif()

  # Use the proper branch (either a tagged version, specific branch, or main).
  if (NOT LLVM_BRANCH)
    set(LLVM_BRANCH "llvmorg-${LLVM_VERSION}")
    if (USE_LLVM_MAIN_BRANCH)
      set(LLVM_BRANCH "main")
      message(STATUS "Using the main branch from the LLVM source repo")
    endif()
  else()
    message(STATUS "Using branch ${LLVM_BRANCH}")
  endif()

  message(STATUS "Found Git: ${GIT_EXECUTABLE}")
  message(STATUS "Cloning LLVM source ...")
  # Can't use FetchContent here as this script is meant to be run stand-alone
  # (`cmake -P build-llvm-toolchian.cmake`) where FetchContent is unsupported.
  execute_process(COMMAND 
    ${GIT_EXECUTABLE} clone --depth 1 
      --branch "${LLVM_BRANCH}" "${LLVM_PROJECT_REPO_URL}.git" 
      "${SOURCE_DIR}"
    RESULT_VARIABLE gitResult)  
  if (NOT "${gitResult}" STREQUAL "0")
    message(FATAL_ERROR "Error cloning LLVM source.")
  endif()
  # Update SOURCE_DIR to refer to the 'llvm' subdirectory.
  set(SOURCE_DIR "${SOURCE_DIR}/llvm")
endif()

# Make sure the source is up-to-date, if requested.
if ((UPDATE_SOURCE AND NOT USE_LLVM_MAIN_BRANCH) OR FORCE_UPDATE_SOURCE)
  if (FORCE_UPDATE_SOURCE)
    message(STATUS "Updating source and discarding any local changes ...")
    # Grab the upstream branch.
    execute_process(
      COMMAND
        ${GIT_EXECUTABLE} rev-parse --abbrev-ref --symbolic-full-name "@{u}"
      OUTPUT_VARIABLE upstreamBranch
      RESULT_VARIABLE gitResult
      WORKING_DIRECTORY "${SOURCE_DIR}")
    if (NOT "${gitResult}" STREQUAL "0")
      message(FATAL_ERROR
        "An error occurred while trying to determine the upstream branch.")
    endif()
    
    # Fetch the latest refs.
    execute_process(COMMAND
      ${GIT_EXECUTABLE} fetch --all
      RESULT_VARIABLE gitResult
      WORKING_DIRECTORY "${SOURCE_DIR}")
    if (NOT "${gitResult}" STREQUAL "0")
      message(FATAL_ERROR
        "An error occurred while trying to fetch latest refs.")
    endif()

    # Jump to the latest commit.
    execute_process(COMMAND
      ${GIT_EXECUTABLE} reset --hard "${upstreamBranch}"
      RESULT_VARIABLE gitResult
      WORKING_DIRECTORY "${SOURCE_DIR}")
    if (NOT "${gitResult}" STREQUAL "0")
      message(FATAL_ERROR
        "An error occurred while trying to update the source.")
    endif()
  else()
    # Perform a simple git pull, but don't die if it fails.
    execute_process(COMMAND
      ${GIT_EXECUTABLE} pull
      RESULT_VARIABLE gitResult
      WORKING_DIRECTORY "${SOURCE_DIR}")
    if (NOT "${gitResult}" STREQUAL "0")
      message(WARNING
        "There was a problem updating the source.")
    endif()
  endif()
endif()

# Adjust the directories and ensure they exist.
set(BUILD_DIR "${ROOT_DIR}/${BUILD_DIR_NAME}")
file(MAKE_DIRECTORY "${BUILD_DIR}")
set(TOOLS_DIR "${ROOT_DIR}/${TOOLS_DIR_NAME}")
file(MAKE_DIRECTORY "${TOOLS_DIR}")
get_filename_component(installDirPath "${INSTALL_DIR}" ABSOLUTE)
file(MAKE_DIRECTORY "${installDirPath}")

# Configure and validate Windows cross-compile options -- if specified.
if ("${CMAKE_SYSTEM_NAME}" STREQUAL "Windows")
  set_default(HOST_ARCH "x86_64")
  message(STATUS "Windows build specified. Target architecture: ${HOST_ARCH}")
  if (NOT DEFINED MSVC_BASE)
  message(FATAL_ERROR 
    "For Windows builds, MSVC_BASE must be defined and be an absolute path"
    "to a folder containing MSVC headers and system libraries.")
  endif()
  if (NOT DEFINED WINSDK_BASE)
    message(FATAL_ERROR 
      "For Windows builds, WINSDK_BASE must be defined and be an absolute path"
      "to a folder containing Windows SDK headers and system libraries.")
  endif()
  if (NOT DEFINED WINSDK_VER)
    message(FATAL_ERROR
      "For Windows builds, WINSDK_VER must be defined and set to the full"
      "version number of the Windows SDK to use.")
  endif()
  if (NOT IS_DIRECTORY "${MSVC_BASE}")
    message(FATAL_ERROR "MSVC_BASE directory not found: '${MSVC_BASE}'")
  endif()
  if (NOT IS_DIRECTORY "${WINSDK_BASE}")
    message(FATAL_ERROR "WINSDK_BASE directory not found: '${WINSDK_BASE}'")
  endif()
  if (NOT IS_DIRECTORY "${WINSDK_BASE}/Lib/${WINSDK_VER}" OR 
    NOT IS_DIRECTORY "${WINSDK_BASE}/Include/${WINSDK_VER}")
    message(FATAL_ERROR 
      "WINSDK_VER does not specify a valid Windows SDK version: ${WINSDK_VER}")
  endif()
  set(crossBuildArgs 
    -DCMAKE_SYSTEM_NAME=Windows 
    -DMSVC_BASE=${MSVC_BASE} 
    -DWINSDK_BASE=${WINSDK_BASE} 
    -DWINSDK_VER=${WINSDK_VER} 
    -DHOST_ARCH=${HOST_ARCH})
endif()

# Start the configuration process.
get_filename_component(sourceDirPath "${SOURCE_DIR}" ABSOLUTE)
execute_process(
  COMMAND 
    ${CMAKE_COMMAND}
      -DROOT_DIR=${ROOT_DIR}
      -DTOOLS_DIR=${TOOLS_DIR}
      -DLLVM_SOURCE_DIR=${sourceDirPath}
      -DNINJA_FORCE_BUILD=${NINJA_FORCE_BUILD}
      -DCMAKE_INSTALL_PREFIX=${installDirPath}
      -DINSTALL_DIR=${installDirPath}
      ${crossBuildArgs}
      ${ROOT_DIR}/projects
  WORKING_DIRECTORY ${BUILD_DIR})

# Start the build.
execute_process(
  COMMAND
    ${CMAKE_COMMAND} --build .
  WORKING_DIRECTORY ${BUILD_DIR})
