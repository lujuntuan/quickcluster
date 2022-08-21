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

function(cluster_get_git_commit _git_hash)
    set(${_git_hash} "unknown" PARENT_SCOPE)
    find_package(Git QUIET)
    if(GIT_FOUND)
        execute_process(
            COMMAND ${GIT_EXECUTABLE} log -1 --pretty=format:%H
            OUTPUT_VARIABLE ${_git_hash}
            OUTPUT_STRIP_TRAILING_WHITESPACE
            ERROR_QUIET
            WORKING_DIRECTORY
            ${CMAKE_SOURCE_DIR}
            )
    endif()
endfunction()

function(cluster_install_etc _target)
    if(NOT EXISTS ${PROJECT_SOURCE_DIR}/etc)
        return()
    endif()
    add_custom_command(
        TARGET
        ${_target}
        POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_directory ${PROJECT_SOURCE_DIR}/etc/ ${COMMON_ETC_OUTPUT_PATH}
        )
    get_filename_component(_PREFIX_RELATIVE_PATH ${CMAKE_INSTALL_PREFIX} REALPATH)
    if(${_PREFIX_RELATIVE_PATH} MATCHES "^/usr")
        #use root
        install(
            DIRECTORY
            ${PROJECT_SOURCE_DIR}/etc/
            DESTINATION
            /etc
            )
    else()
        install(
            DIRECTORY
            ${PROJECT_SOURCE_DIR}/etc/
            DESTINATION
            etc
            )
    endif()
    unset(_PREFIX_RELATIVE_PATH)
endfunction()

function(cluster_install_share _target)
    if(NOT EXISTS ${PROJECT_SOURCE_DIR}/share)
        return()
    endif()
    add_custom_command(
        TARGET
        ${_target}
        POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_directory ${PROJECT_SOURCE_DIR}/share/ ${COMMON_SHARE_OUTPUT_PATH}
        )
    install(
        DIRECTORY
        ${PROJECT_SOURCE_DIR}/share/
        DESTINATION
        share/${CMAKE_PROJECT_NAME}
        )
    unset(_PREFIX_RELATIVE_PATH)
endfunction()
