include(VariableUtils)
include(Validate)

validate(
  EXISTS
    ROOT_DIR
    INSTALL_DIR
    TOOLS_DIR)

set(TOOLCHAIN_CMAKE_DIR "${INSTALL_DIR}/share/toolchain")
set(postInstallOutput
  ${TOOLCHAIN_CMAKE_DIR}/linux-default-cache.sh 
  ${TOOLCHAIN_CMAKE_DIR}/linux-default-configure.sh 
  ${TOOLCHAIN_CMAKE_DIR}/linux-default-toolchain.sh)
add_custom_command(
  OUTPUT ${postInstallOutput}
  COMMAND ${CMAKE_COMMAND}
  ARGS
    -DROOT_DIR=${ROOT_DIR} 
    -DTOOLCHAIN_CMAKE_DIR=${TOOLCHAIN_CMAKE_DIR} 
    -DINSTALL_DIR=${INSTALL_DIR}
    -DTOOLS_DIR=${TOOLS_DIR}
    -P ${CMAKE_CURRENT_LIST_DIR}/post-install.cmake
  COMMENT "Generating default CMake scripts for the toolchain...")
add_custom_target(post-install-cmake
  ALL
  DEPENDS
    llvm
    ${postInstallOutput})
