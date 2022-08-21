#*********************************************************************************
#  *Copyright(C): Juntuan.Lu, 2020-2030, All rights reserved.
#  *Author:  Juntuan.Lu
#  *Version: 1.0
#  *Date:  2021/04/22
#  *Email: 931852884@qq.com
#  *Description:
#  *Others:
#  *Function List:
#  *History:
#**********************************************************************************

find_package(CommonAPI QUIET)

search_3rdparty_begin(CommonAPI)
if(CMAKE_HOST_WIN32)
    find_program(COMMONAPI_CORE_GENERATOR_EXE
        NAMES
        capicxx-core-gen
        commonapi-core-generator-windwos-x86
        commonapi-core-generator-windwos-x86_64
        PATHS
        ${3RD_EXE_SEARCH_PATH}
        ENV PATH
        NO_CMAKE_PATH
        )
elseif(CMAKE_HOST_UNIX)
    find_program(COMMONAPI_CORE_GENERATOR_EXE
        NAMES
        capicxx-core-gen
        commonapi-core-generator-linux-x86
        commonapi-core-generator-linux-x86_64
        PATHS
        ${3RD_EXE_SEARCH_PATH}
        ENV PATH
        NO_CMAKE_PATH
        )
endif()
find_path(COMMONAPI_CORE_INCLUDE_DIR
    NAMES
    CommonAPI/CommonAPI.h
    CommonAPI/CommonAPI.hpp
    PATHS
    ${3RD_INC_SEARCH_PATH}
    PATH_SUFFIXES
    ""
    CommonAPI-3.2
    )
find_library(COMMONAPI_CORE_LIBRARY
    NAMES
    CommonAPI
    libCommonAPI
    PATHS
    ${3RD_LIB_SEARCH_PATH}
    )
mark_as_advanced(COMMONAPI_CORE_GENERATOR_EXE COMMONAPI_CORE_INCLUDE_DIR COMMONAPI_CORE_LIBRARY)
search_3rdparty_end()

if(CommonAPI_FOUND OR (COMMONAPI_CORE_INCLUDE_DIR AND COMMONAPI_CORE_LIBRARY))
    set(COMMONAPI_CORE_ENABLE ON)
    message(STATUS "CommonAPI found")
    if(COMMONAPI_CORE_GENERATOR_EXE)
        message(STATUS "COMMONAPI_CORE_GENERATOR_EXE=${COMMONAPI_CORE_GENERATOR_EXE}")
    endif()
    if(COMMONAPI_CORE_INCLUDE_DIR AND COMMONAPI_CORE_LIBRARY)
        set_target_properties(
            CommonAPI
            PROPERTIES
            INTERFACE_INCLUDE_DIRECTORIES
            ${COMMONAPI_CORE_INCLUDE_DIR}
        )
        message(STATUS "COMMONAPI_CORE_INCLUDE_DIR=${COMMONAPI_CORE_INCLUDE_DIR}")
        message(STATUS "COMMONAPI_CORE_LIBRARY=${COMMONAPI_CORE_LIBRARY}")
    else()
        message(STATUS "")
    endif()
else()
    set(COMMONAPI_CORE_ENABLE OFF)
    message(STATUS "CommonAPI not found")
endif()

function(commonapi_core_generate_src _gen_dir _opt_value _out_var)
    if(${ARGC} LESS 4)
        message(FATAL_ERROR "Args error")
    endif()
    set(_source ${ARGV})
    set(_file_sources)
    list(REMOVE_AT _source 0 1 2)
    foreach(it ${_source})
        file(GLOB_RECURSE
            _file
            ${it}
            )
        list(APPEND _file_sources ${_file})
    endforeach()
    if(NOT _gen_dir)
        message(FATAL_ERROR "Gen dir not set")
    endif()
    if(NOT _opt_value)
        message(FATAL_ERROR "Opt value not set")
    endif()
    if(NOT _file_sources)
        message(FATAL_ERROR "Can not find any sources")
    endif()
    foreach(it ${_file_sources})
        get_filename_component(filedir ${it} DIRECTORY)
        get_filename_component(infile ${it} ABSOLUTE)
        get_filename_component(outfilename ${it} NAME_WE)
        list(APPEND outfile
            ${_gen_dir}/${_opt_value}.hpp
            ${_gen_dir}/${_opt_value}Proxy.hpp
            ${_gen_dir}/${_opt_value}ProxyBase.hpp
            ${_gen_dir}/${_opt_value}Stub.hpp
            ${_gen_dir}/${_opt_value}StubDefault.hpp
            )
        add_custom_command(
            OUTPUT ${outfile}
            COMMAND ${CMAKE_COMMAND} -E make_directory ${_gen_dir}
            COMMAND ${COMMONAPI_CORE_GENERATOR_EXE} ${it} -sk --dest=${_gen_dir}
            COMMAND ${CMAKE_COMMAND} -E touch ${outfile}
            DEPENDS ${infile}
            VERBATIM
            )
        list(APPEND outfiles ${outfile})
    endforeach()
    set_source_files_properties(${outfiles} PROPERTIES GENERATED TRUE)
    set(${_out_var} ${outfiles} PARENT_SCOPE)
    add_custom_target(
        ${PROJECT_NAME}_fidl
        SOURCES
        ${_file_sources}
    )
endfunction()
