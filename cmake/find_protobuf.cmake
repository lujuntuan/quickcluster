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

option(PROTOBUF_USE_C "" OFF)

search_3rdparty_begin(protobuf)
find_program(PROTOBUF_GENERATOR_EXE
    NAMES
    protoc
    PATHS
    ${3RD_EXE_SEARCH_PATH}
    ENV PATH
    NO_CMAKE_PATH
    )
find_path(PROTOBUF_INCLUDE_DIR
    NAMES
    google/protobuf/message.h
    PATHS
    ${3RD_INC_SEARCH_PATH}
    )
find_library(PROTOBUF_LIBRARY
    NAMES
    protobuf
    libprotobuf
    PATHS
    ${3RD_LIB_SEARCH_PATH}
    )
mark_as_advanced(PROTOBUF_GENERATOR_EXE PROTOBUF_INCLUDE_DIR PROTOBUF_LIBRARY)
search_3rdparty_end()

if(PROTOBUF_GENERATOR_EXE AND PROTOBUF_INCLUDE_DIR AND PROTOBUF_LIBRARY)
    set(PROTOBUF_ENABLE ON)
    message(STATUS "protobuf found")
    message(STATUS "PROTOBUF_GENERATOR_EXE=${PROTOBUF_GENERATOR_EXE}")
    message(STATUS "PROTOBUF_INCLUDE_DIR=${PROTOBUF_INCLUDE_DIR}")
    message(STATUS "PROTOBUF_LIBRARY=${PROTOBUF_LIBRARY}")
else()
    set(PROTOBUF_ENABLE OFF)
    message(STATUS "protobuf not found")
endif()

if(PROTOBUF_USE_C)
    search_3rdparty_begin(protobuf-c)
    find_program(PROTOBUF_C_GENERATOR_EXE
        NAMES
        protoc-c
        PATHS
        ${3RD_EXE_SEARCH_PATH}
        ENV PATH
        NO_CMAKE_PATH
        )
    find_path(PROTOBUF_C_INCLUDE_DIR
        NAMES
        protobuf-c/protobuf-c.h
        PATHS
        ${3RD_INC_SEARCH_PATH}
        )
    find_library(PROTOBUF_C_LIBRARY
        NAMES
        protobuf-c
        libprotobuf-c
        PATHS
        ${3RD_LIB_SEARCH_PATH}
        )
    search_3rdparty_end()
    mark_as_advanced(PROTOBUF_C_GENERATOR_EXE PROTOBUF_C_INCLUDE_DIR PROTOBUF_C_LIBRARY)
    if(PROTOBUF_C_GENERATOR_EXE AND PROTOBUF_C_INCLUDE_DIR AND PROTOBUF_C_LIBRARY)
        set(PROTOBUF_C_ENABLE ON)
        message(STATUS "protobuf-c found")
        message(STATUS "PROTOBUF_C_GENERATOR_EXE=${PROTOBUF_C_GENERATOR_EXE}")
        message(STATUS "PROTOBUF_C_INCLUDE_DIR=${PROTOBUF_C_INCLUDE_DIR}")
        message(STATUS "PROTOBUF_C_LIBRARY=${PROTOBUF_C_LIBRARY}")
    else()
        set(PROTOBUF_C_ENABLE OFF)
        message(STATUS "protobuf-c not found")
    endif()
endif()

function(proto_generate_src _gen_dir _out_var)
    if(${ARGC} LESS 3)
        message(FATAL_ERROR "Args error")
    endif()
    set(_source ${ARGV})
    set(_file_sources)
    list(REMOVE_AT _source 0 1)
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
    if(NOT _file_sources)
        message(FATAL_ERROR "Can not find any sources")
    endif()
    foreach(it ${_file_sources})
        get_filename_component(filedir ${it} DIRECTORY)
        get_filename_component(infile ${it} ABSOLUTE)
        get_filename_component(outfilename ${it} NAME_WE)
        list(APPEND outfile ${_gen_dir}/${outfilename}.pb.h ${_gen_dir}/${outfilename}.pb.cc)
        if(PROTOBUF_GENERATOR_EXE)
            add_custom_command(
                OUTPUT ${outfile}
                COMMAND ${CMAKE_COMMAND} -E make_directory ${_gen_dir}
                COMMAND ${PROTOBUF_GENERATOR_EXE} -I${filedir} --cpp_out=${_gen_dir} ${it}
                DEPENDS ${infile}
                VERBATIM
                )
        endif()
        if(PROTOBUF_C_GENERATOR_EXE AND PROTOBUF_USE_C)
            add_custom_command(
                OUTPUT ${outfile}
                COMMAND ${CMAKE_COMMAND} -E make_directory ${_gen_dir}
                COMMAND ${PROTOBUF_C_GENERATOR_EXE} -I${filedir} --c_out=${_gen_dir} ${it}
                DEPENDS ${infile}
                VERBATIM
                )
        endif()
        list(APPEND outfiles ${outfile})
    endforeach()
    set_source_files_properties(${outfiles} PROPERTIES GENERATED TRUE)
    set(${_out_var} ${outfiles} PARENT_SCOPE)
    add_custom_target(
        ${PROJECT_NAME}_proto
        SOURCES
        ${_file_sources}
    )
endfunction(proto_generate_src)
