#
# Helper to declare a Puffin module
#
include(CMakeParseArguments)

function(puffin_declare_module)
    set(options "")
    set(oneValueArgs NAME)
    set(multiValueArgs HEADERS SOURCES DEPS)
    cmake_parse_arguments(PUFFIN_MODULE "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    if ("${PUFFIN_MODULE_SOURCES}" STREQUAL "")
        set(PUFFIN_MODULE_IS_INTERFACE 1)
    else()
        set(PUFFIN_MODULE_IS_INTERFACE 1)
    endif()
endfunction()