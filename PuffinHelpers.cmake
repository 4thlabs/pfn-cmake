include(FetchContent)

FetchContent_Declare(
    catch2
    GIT_REPOSITORY https://github.com/catchorg/Catch2.git
    GIT_TAG v2.7.2
    GIT_SHALLOW ON
)

#
# Helper to declare a Puffin module
#
function(puffin_declare_module)
    set(options "")
    set(oneValueArgs NAME)
    set(multiValueArgs HEADERS SOURCES FEATURES DEPS)

    cmake_parse_arguments(PUFFIN_MODULE "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
    
    set(TMP_NAME ${PUFFIN_MODULE_NAME})
    first_letter_upper(TMP_NAME)

    set(PUFFIN_MODULE_TARGETS_NAME "Puffin${TMP_NAME}Targets")

    if ("${PUFFIN_MODULE_SOURCES}" STREQUAL "")
        set(PUFFIN_MODULE_IS_INTERFACE 1)
    else()
        set(PUFFIN_MODULE_IS_INTERFACE 1)
    endif()

    if(PUFFIN_MODULE_IS_INTERFACE)
        add_library("${PUFFIN_MODULE_NAME}" INTERFACE)

        target_include_directories("${PUFFIN_MODULE_NAME}"
            INTERFACE $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
            INTERFACE $<INSTALL_INTERFACE:include>
        )

        target_link_libraries("${PUFFIN_MODULE_NAME}" 
            INTERFACE 
                ${PUFFIN_MODULE_DEPS}
        )

        target_compile_features("${PUFFIN_MODULE_NAME}" 
            INTERFACE
                ${PUFFIN_MODULE_FEATURES}
        )
    else()

    endif()

    install(DIRECTORY include/ DESTINATION include)

    install(TARGETS "${PUFFIN_MODULE_NAME}" EXPORT "${PUFFIN_MODULE_TARGETS_NAME}"
        RUNTIME DESTINATION bin
        ARCHIVE DESTINATION lib
        LIBRARY DESTINATION lib
        INCLUDES DESTINATION include
    )

    install(
        EXPORT 
            "${PUFFIN_MODULE_TARGETS_NAME}"
        FILE 
            "${PUFFIN_MODULE_TARGETS_NAME}.cmake"
        NAMESPACE
            Puffin::
        DESTINATION
            lib/cmake/puffin
    )

    export(TARGETS "${PUFFIN_MODULE_NAME}" FILE "${PUFFIN_MODULE_TARGETS_NAME}.cmake" NAMESPACE Puffin::)
    
    add_library("Puffin::${PUFFIN_MODULE_NAME}" ALIAS "${PUFFIN_MODULE_NAME}")
endfunction()

#
# Helper to declare a module sample
#
function(puffin_declare_samples)
    set(options "")
    set(oneValueArgs "NAME")
    set(multiValueArgs SOURCES DEPS)

    cmake_parse_arguments(PUFFIN_SAMPLE "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
    
    add_executable("${PUFFIN_SAMPLE_NAME}" "${PUFFIN_SAMPLE_SOURCES}")
    target_link_libraries("${PUFFIN_SAMPLE_NAME}" ${PUFFIN_SAMPLE_DEPS})
    set_target_properties("${PUFFIN_SAMPLE_NAME}"
        PROPERTIES
        RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/samples"
    )
endfunction()

function(puffin_declare_tests)
    set(options "")
    set(oneValueArgs "NAME")
    set(multiValueArgs SOURCES DEPS)

    cmake_parse_arguments(PUFFIN_TEST "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    FetchContent_GetProperties(catch2)
    if(NOT catch2_POPULATED)
        FetchContent_Populate(catch2)
        add_subdirectory(${catch2_SOURCE_DIR} ${catch2_BINARY_DIR})
    endif()
    add_executable("tests_${PUFFIN_TEST_NAME}" "${PUFFIN_TEST_SOURCES}")
    target_link_libraries("tests_${PUFFIN_TEST_NAME}" Catch2 ${PUFFIN_TEST_DEPS})
    
    set_target_properties("tests_${PUFFIN_TEST_NAME}"
        PROPERTIES
        RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/tests"
    )

    add_test(NAME Puffin COMMAND "${CMAKE_BINARY_DIR}/tests/tests_${PUFFIN_TEST_NAME}")
endfunction()

function(first_letter_upper args)
    string(SUBSTRING "${${args}}" 0 1 FIRST_LETTER)
    string(TOUPPER ${FIRST_LETTER} FIRST_LETTER)
    string(REGEX REPLACE "^.(.*)" "${FIRST_LETTER}\\1" RESULT "${${args}}")
    set(${args} ${RESULT} PARENT_SCOPE)
endfunction()