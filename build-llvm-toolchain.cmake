macro(set_default varName value)
  if (NOT DEFINED ${varName} OR "" STREQUAL "${${varName}}")
    set(${varName} ${value})
  endif()
endmacro()

set_default(LLVM_PROJECT_REPO_URL "https://github.com/llvm/llvm-project")
set_default(LLVM_VERSION "11.0.1")

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
  message(
    "The source directory either does not exist or does not appear to be a valid
LLVM source tree. The source will need to be acquired from 
${LLVM_PROJECT_REPO_URL}.")
  if ("" STREQUAL "${GIT_EXECUTABLE}" OR NOT EXISTS "${GIT_EXECUTABLE}")
    find_program(GIT_EXECUTABLE git REQUIRED)
  endif()

  message(STATUS "Found Git: ${GIT_EXECUTABLE}")
  message(STATUS "Cloning LLVM source ...")
  # Can't use FetchContent here as this script is meant to be run stand-alone
  # (`cmake -P build-llvm-toolchian.cmake`) where FetchContent is unsupported.
  execute_process(COMMAND 
    ${GIT_EXECUTABLE} clone --depth 1 
      --branch "llvmorg-${LLVM_VERSION}" "${LLVM_PROJECT_REPO_URL}.git" 
      "${SOURCE_DIR}"
    RESULT_VARIABLE gitResult)
  if (NOT "${gitResult}" STREQUAL "0")
    message(FATAL_ERROR "Error cloning LLVM source.")
  endif()
  # Update SOURCE_DIR to refer to the 'llvm' subdirectory.
  set(SOURCE_DIR "${SOURCE_DIR}/llvm")
endif()

# Adjust the directories and ensure they exist.
set(BUILD_DIR "${ROOT_DIR}/${BUILD_DIR_NAME}")
file(MAKE_DIRECTORY "${BUILD_DIR}")
set(TOOLS_DIR "${ROOT_DIR}/${TOOLS_DIR_NAME}")
file(MAKE_DIRECTORY "${TOOLS_DIR}")
get_filename_component(installDirPath "${INSTALL_DIR}" ABSOLUTE)
file(MAKE_DIRECTORY "${installDirPath}")

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
      ${ROOT_DIR}/projects
  WORKING_DIRECTORY ${BUILD_DIR})

# Start the build.
execute_process(
  COMMAND
    ${CMAKE_COMMAND} --build .
  WORKING_DIRECTORY ${BUILD_DIR})
