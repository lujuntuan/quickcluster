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

find_package(CommonAPI-SomeIP QUIET)

search_3rdparty_begin(CommonAPI-SomeIP)
if(CMAKE_HOST_WIN32)
    find_program(COMMONAPI_SOMEIP_GENERATOR_EXE
        NAMES
        capicxx-someip-gen
        commonapi-someip-generator-windwos-x86
        commonapi-someip-generator-windwos-x86_64
        PATHS
        ${3RD_EXE_SEARCH_PATH}
        ENV PATH
        NO_CMAKE_PATH
        )
elseif(CMAKE_HOST_UNIX)
    find_program(COMMONAPI_SOMEIP_GENERATOR_EXE
        NAMES
        capicxx-someip-gen
        commonapi-someip-generator-linux-x86
        commonapi-someip-generator-linux-x86_64
        PATHS
        ${3RD_EXE_SEARCH_PATH}
        ENV PATH
        NO_CMAKE_PATH
        )
endif()
find_path(COMMONAPI_SOMEIP_INCLUDE_DIR
    NAMES
    CommonAPI/SomeIP/ProxyBase.h
    CommonAPI/SomeIP/ProxyBase.hpp
    PATHS
    ${3RD_INC_SEARCH_PATH}
    PATH_SUFFIXES
    ""
    CommonAPI-3.2
    )
find_library(COMMONAPI_SOMEIP_LIBRARY
    NAMES
    CommonAPI-SomeIP
    libCommonAPI-SomeIP
    PATHS
    ${3RD_LIB_SEARCH_PATH}
    )
mark_as_advanced(COMMONAPI_SOMEIP_GENERATOR_EXE COMMONAPI_SOMEIP_INCLUDE_DIR COMMONAPI_SOMEIP_LIBRARY)
search_3rdparty_end()

if(CommonAPI-SomeIP_FOUND OR (COMMONAPI_SOMEIP_INCLUDE_DIR AND COMMONAPI_SOMEIP_LIBRARY))
    set(COMMONAPI_SOMEIP_ENABLE ON)
    message(STATUS "CommonAPI-SomeIP found")
    if(COMMONAPI_SOMEIP_GENERATOR_EXE)
        message(STATUS "COMMONAPI_SOMEIP_GENERATOR_EXE=${COMMONAPI_SOMEIP_GENERATOR_EXE}")
    endif()
    if(COMMONAPI_SOMEIP_INCLUDE_DIR AND COMMONAPI_SOMEIP_LIBRARY)
        set_target_properties(
            CommonAPI-SomeIP
            PROPERTIES
            INTERFACE_INCLUDE_DIRECTORIES
            ${COMMONAPI_SOMEIP_INCLUDE_DIR}
        )
        message(STATUS "COMMONAPI_SOMEIP_INCLUDE_DIR=${COMMONAPI_SOMEIP_INCLUDE_DIR}")
        message(STATUS "COMMONAPI_SOMEIP_LIBRARY=${COMMONAPI_SOMEIP_LIBRARY}")
    else()
        message(STATUS "")
    endif()
else()
    set(COMMONAPI_SOMEIP_ENABLE OFF)
    message(STATUS "CommonAPI-SomeIP not found")
endif()

function(commonapi_someip_generate_src _gen_dir _opt_value _out_var)
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
            ${_gen_dir}/${_opt_value}SomeIPProxy.hpp
            ${_gen_dir}/${_opt_value}SomeIPProxy.cpp
            ${_gen_dir}/${_opt_value}SomeIPStubAdapter.hpp
            ${_gen_dir}/${_opt_value}SomeIPStubAdapter.cpp
            ${_gen_dir}/${_opt_value}SomeIPDeployment.hpp
            ${_gen_dir}/${_opt_value}SomeIPDeployment.cpp
            )
        add_custom_command(
            OUTPUT ${outfile}
            COMMAND ${CMAKE_COMMAND} -E make_directory ${_gen_dir}
            COMMAND ${COMMONAPI_SOMEIP_GENERATOR_EXE} ${it} --dest=${_gen_dir}
            COMMAND ${CMAKE_COMMAND} -E touch ${outfile}
            DEPENDS ${infile}
            VERBATIM
            )
        list(APPEND outfiles ${outfile})
    endforeach()
    set_source_files_properties(${outfiles} PROPERTIES GENERATED TRUE)
    set(${_out_var} ${outfiles} PARENT_SCOPE)
    add_custom_target(
        ${PROJECT_NAME}_fdepl
        SOURCES
        ${_file_sources}
    )
endfunction()
