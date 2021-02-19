macro(validate_var varName)
  if ("" STREQUAL "${${varName}}")
    message(FATAL_ERROR "${varName} must be defined.")
  endif()
endmacro()

macro(validate_dir varName)
  validate_var(${varName})
  if (NOT IS_DIRECTORY "${${varName}}")
    message(FATAL_ERROR "${varName}: directory not found: '${${varName}}'")
  endif()
endmacro()

validate_dir(ROOT_DIR)
validate_dir(INSTALL_DIR)
validate_dir(TOOLS_DIR)
validate_var(TOOLCHAIN_CMAKE_DIR)

find_program(NINJA_BIN ninja
  PATHS ${TOOLS_DIR}/ninja/bin
  REQUIRED)

file(MAKE_DIRECTORY "${TOOLCHAIN_CMAKE_DIR}")

set(templatesDir "${ROOT_DIR}/cmake/templates")
file(GLOB fileTemplates LIST_DIRECTORIES FALSE "${templatesDir}/*.in")
foreach (fileTemplate ${fileTemplates})
  get_filename_component(outputName ${fileTemplate} NAME_WLE)
  message("${outputName}")
  configure_file("${fileTemplate}" 
    "${TOOLCHAIN_CMAKE_DIR}/${outputName}"
    @ONLY)
endforeach()
