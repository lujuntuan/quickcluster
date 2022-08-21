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

find_path(3RDPARTY_DIR
    NAMES
    lib
    PATHS
    ${CMAKE_SOURCE_DIR}
    ${CMAKE_SOURCE_DIR}/../
    PATH_SUFFIXES
    3rd
    3RD
    3rdparty
    3RDPARTY
    dependence
    DEPENDENCE
    NO_CMAKE_FIND_ROOT_PATH
    NO_DEFAULT_PATH
    )

if(3RDPARTY_DIR)
    set(3RDPARTY_DIR_ENABLE ON)
    message(STATUS "3rdparty_dir found")
    message(STATUS "3RDPARTY_DIR=${3RDPARTY_DIR}")
else()
    set(3RDPARTY_DIR_ENABLE OFF)
    message(STATUS "3rdparty_dir not found")
endif()
macro(search_3rdparty_begin arg)
    set(3RD_INC_SEARCH_PATH
        ${CMAKE_INSTALL_PREFIX}}/include
        ${CMAKE_INSTALL_PREFIX}/${arg}/include
        )
    set(3RD_LIB_SEARCH_PATH
        ${CMAKE_INSTALL_PREFIX}}/lib
        ${CMAKE_INSTALL_PREFIX}/${arg}/lib
        ${CMAKE_INSTALL_PREFIX}}/lib/${CMAKE_BUILD_TYPE}
        ${CMAKE_INSTALL_PREFIX}/${arg}/lib/${CMAKE_BUILD_TYPE}
        )
    set(3RD_EXE_SEARCH_PATH
        ${CMAKE_INSTALL_PREFIX}}/bin
        ${CMAKE_INSTALL_PREFIX}/${arg}/bin
        ${CMAKE_INSTALL_PREFIX}}/bin/${CMAKE_BUILD_TYPE}
        ${CMAKE_INSTALL_PREFIX}/${arg}/bin/${CMAKE_BUILD_TYPE}
        )
    if(WIN32)
        list(APPEND
            3RD_INC_SEARCH_PATH
            $ENV{programfiles}/${arg}/include
            $ENV{programfiles\(x86\)}/${arg}/include
            )
        list(APPEND
            3RD_LIB_SEARCH_PATH
            $ENV{programfiles}/${arg}/lib
            $ENV{programfiles\(x86\)}/${arg}/lib
            $ENV{programfiles}/${arg}/lib/${CMAKE_BUILD_TYPE}
            $ENV{programfiles\(x86\)}/${arg}/lib/${CMAKE_BUILD_TYPE}
            )
        list(APPEND
            3RD_EXE_SEARCH_PATH
            $ENV{programfiles}/${arg}/bin
            $ENV{programfiles\(x86\)}/${arg}/bin
            $ENV{programfiles}/${arg}/bin/${CMAKE_BUILD_TYPE}
            $ENV{programfiles\(x86\)}/${arg}/bin/${CMAKE_BUILD_TYPE}
            )
    endif()
    if(3RDPARTY_DIR_ENABLE)
        list(APPEND
            3RD_INC_SEARCH_PATH
            ${3RDPARTY_DIR}/include
            ${3RDPARTY_DIR}/${arg}/include
            )
        list(APPEND
            3RD_LIB_SEARCH_PATH
            ${3RDPARTY_DIR}/lib
            ${3RDPARTY_DIR}/${arg}/lib
            ${3RDPARTY_DIR}/lib/${CMAKE_BUILD_TYPE}
            ${3RDPARTY_DIR}/${arg}/lib/${CMAKE_BUILD_TYPE}
            )
        list(APPEND
            3RD_EXE_SEARCH_PATH
            ${3RDPARTY_DIR}/bin
            ${3RDPARTY_DIR}/${arg}/bin
            ${3RDPARTY_DIR}/bin/${CMAKE_BUILD_TYPE}
            ${3RDPARTY_DIR}/${arg}/bin/${CMAKE_BUILD_TYPE}
            )
    else()
    endif()
endmacro(search_3rdparty_begin arg)
macro(search_3rdparty_end)
    unset(3RD_INC_SEARCH_PATH)
    unset(3RD_LIB_SEARCH_PATH)
    unset(3RD_EXE_SEARCH_PATH)
endmacro(search_3rdparty_end)
