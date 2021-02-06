# set_cache - Sets a forced-by-default cache variable with a default type of 
# STRING.
function(set_cache varName value)
  cmake_parse_arguments(ARG
    "NO_FORCE;STRING;BOOL;FILEPATH;PATH"
    ""
    ""
    ${ARGN})
  
  _fill_cache_args()
  set(${varName} ${value} CACHE ${argType} "" ${forceFlag})
endfunction()

# set_default - Sets a variable to the given value if the variable is undefined.
function(set_default varName value)
  if (NOT DEFINED ${varName})
    set(${varName} ${value} PARENT_SCOPE)
  endif()
endfunction()

# set_cache_default - Sets a cache variable to the given value if the variable
# is undefined.
function(set_cache_default varName value)
  cmake_parse_arguments(ARG
    "NO_FORCE;STRING;BOOL;FILEPATH;PATH"
    ""
    ""
    ${ARGN})

  _fill_cache_args()
  set(${varName} ${value} CACHE ${argType} "" ${forceFlag})
endfunction()

# set_cache_variables - Sets multiple cache variables to the given value.
function(set_cache_variables)
  cmake_parse_arguments(ARG
    "STRING;BOOL;FILEPATH;PATH"
    "VALUE"
    "VARIABLES"
    ${ARGN})
  _get_cache_type(argType
    "${ARG_BOOL}" "${ARG_FILEPATH}" "${ARG_PATH}" "${ARG_STRING}")
  foreach (varName ${ARG_VARIABLES})
    set_cache(${varName} "${ARG_VALUE}" ${argType})
  endforeach()
endfunction()

# disable_cache_variables - Sets the value of multiple cache variables to FALSE.
function(disable_cache_variables)
  foreach(cacheVar ${ARGN})
    set_cache(${cacheVar} FALSE)
  endforeach()
endfunction()

# enable_cache_variables - Sets the value of multiple cache variables to TRUE.
function(enable_cache_variables)
  foreach (cacheVar ${ARGN})
    set_cache(${cacheVar} TRUE)
  endforeach()
endfunction()

function(_get_cache_type outVar isBool isFilePath isPath isString)
  set(argType STRING)
  if (isBool)
    set(argType BOOL)
  elseif (isFilePath)
    set(argType FILEPATH)
  elseif (isPath)
    set(argType PATH)
  endif()

  set(${outVar} ${argType} PARENT_SCOPE)
endfunction()

macro(_fill_cache_args)
  if (NOT ARG_STRING AND NOT ARG_BOOL AND NOT ARG_FILEPATH AND NOT ARG_PATH)
    # Check for true/false-like values.
    string(TOLOWER "${value}" lowerValue)
    if ("${lowerValue}" MATCHES "^yes|no|true|false|on|off$")
      set(argType BOOL)
    endif()
  endif()
  if (NOT argType)
    _get_cache_type(argType
      "${ARG_BOOL}" "${ARG_FILEPATH}" "${ARG_PATH}" "${ARG_STRING}")
  endif()

  set(forceFlag FORCE)
  if (ARG_NO_FORCE)
    set(forceFlag)
  endif()
endmacro()