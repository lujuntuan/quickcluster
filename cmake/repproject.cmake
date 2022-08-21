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

macro(start_rep_project)
    if(${ARGC} LESS 2)
        message(FATAL_ERROR "Args error!")
    endif()
    if("${ARGV0}" STREQUAL "replica" OR "${ARGV0}" STREQUAL "REPLICA")
        set(SUB_PROJECT_TYPE "REPLICA")
    else()
        set(SUB_PROJECT_TYPE "SOURCE")
    endif()
    string(REGEX REPLACE ".*/(.*)" "\\1" CURRENT_DIR_NAME ${CMAKE_CURRENT_LIST_DIR})
    set(REP_PROJECT_NAME ${CURRENT_DIR_NAME})
    unset(CURRENT_DIR_NAME)
    project(${REP_PROJECT_NAME} VERSION ${CMAKE_PROJECT_VERSION} LANGUAGES C CXX)
    set(REP_SOURCES ${ARGV})
    set(PROJECT_REP_SOURCES "")
    list(REMOVE_AT REP_SOURCES 0)
endmacro(start_rep_project)

macro(end_rep_project)
    foreach(rep ${REP_SOURCES})
        if(Qt5_FOUND)
            qt5_generate_repc(
                PROJECT_REP_SOURCES
                ${CMAKE_SOURCE_DIR}/idl/${CLUSTER_SERVERS_PROJECT}/${rep}.rep
                ${SUB_PROJECT_TYPE}
                )
        else()
            if("${SUB_PROJECT_TYPE}" STREQUAL REPLICA)
                qt6_add_repc_replicas(
                    ${PROJECT_NAME}
                    ${CMAKE_SOURCE_DIR}/idl/${CLUSTER_SERVERS_PROJECT}/${rep}.rep
                    )
            else()
                qt6_add_repc_sources(
                    ${PROJECT_NAME}
                    ${CMAKE_SOURCE_DIR}/idl/${CLUSTER_SERVERS_PROJECT}/${rep}.rep
                    )
            endif()
        endif()
    endforeach()
    if(PROJECT_REP_SOURCES)
        target_sources(
            ${PROJECT_NAME}
            PRIVATE
            ${PROJECT_REP_SOURCES}
            )
    endif()
    target_link_libraries(
        ${PROJECT_NAME}
        PRIVATE
        cluster
        )
    target_include_directories(
        ${PROJECT_NAME}
        PRIVATE
        ${PROJECT_BINARY_DIR}
        ${CMAKE_SOURCE_DIR}/idl/${CLUSTER_SERVERS_PROJECT}
        )
    target_compile_definitions(
        ${PROJECT_NAME}
        PRIVATE
        "-DCLUSTER_TARGET_NAME=\"${PROJECT_NAME}\""
        )
    if(UNIX)
        set_target_properties(
            ${PROJECT_NAME}
            PROPERTIES
            LINK_FLAGS
            "-Wl,-rpath-link,${CMAKE_LIBRARY_OUTPUT_DIRECTORY}"
            )
    endif()
    install(
        TARGETS
        ${PROJECT_NAME}
        RUNTIME
        DESTINATION
        ${CMAKE_INSTALL_BINDIR}
        )
    unset(REP_SOURCES)
    unset(SUB_PROJECT_TYPE)
    unset(PROJECT_REP_SOURCES)
endmacro(end_rep_project)
