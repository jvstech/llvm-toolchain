function(validate)
  cmake_parse_arguments(ARG
    ""
    ""
    "HAS_VALUE;EXISTS"
    ${ARGN})
  foreach (varName ${ARG_HAS_VALUE})
    if (NOT DEFINED ${varName} OR "" STREQUAL "${${varName}}")
      message(FATAL_ERROR "${varName} must be defined.")
    endif()
  endforeach()

  foreach (varName ${ARG_EXISTS})
    if (NOT DEFINED ${varName} OR "" STREQUAL "${${varName}}")
      message(FATAL_ERROR "${varName} must be defined.")
    endif()
    if (NOT EXISTS "${${varName}}")
      message(FATAL_ERROR "Not found (${varName}): ${${varName}}")
    endif()
  endforeach()
endfunction()
