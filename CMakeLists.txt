#*********************************************************************************
#  *Copyright(C): Juntuan.Lu, 2020-2030, All rights reserved.
#  *Author:  Juntuan.Lu
#  *Version: 1.0
#  *Date:  2021/07/22
#  *Email: 931852884@qq.com
#  *Description:
#  *Others:
#  *Function List:
#  *History:
#**********************************************************************************

###############
###Project
###############
cmake_minimum_required(VERSION 3.10 FATAL_ERROR)

set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
#set(CMAKE_BUILD_TYPE "Release" CACHE STRING "Build to Release and Debug")
#set(CMAKE_INSTALL_PREFIX "/usr/local" CACHE PATH "Where install")

###############
###Common
###############
include(cmake/common.cmake)
message("** Build Type=${CMAKE_BUILD_TYPE}")
message("** Install Dir=${CMAKE_INSTALL_PREFIX}")
set(CLUSTER_VERSION "unknown")
set(CLUSTER_COMMITID "unknown")
file(STRINGS ${CMAKE_SOURCE_DIR}/version.txt CLUSTER_VERSION)
cluster_get_git_commit(CLUSTER_COMMITID)
message("** CLUSTER_VERSION: ${CLUSTER_VERSION}")
message("** CLUSTER_COMMITID: ${CLUSTER_COMMITID}")

project(cluster VERSION ${CLUSTER_VERSION} LANGUAGES C CXX)

###############
###Platform
###############
include(cmake/platform.cmake)

###############
###Condition
###############
option(BUILD_SHARED_LIBS "Build shared libraries" ON)
include(cmake/find_3rdparty.cmake)

###############
###Type
###############
set(CLUSTER_HMI_PROJECT "ejanus" CACHE STRING "Cluster HMI project suffix name")
set(CLUSTER_SERVERS_PROJECT "common" CACHE STRING "Cluster Servers project suffix name")

###############
###Subproject
###############
include(GNUInstallDirs)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/output/bin)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/output/lib)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/output/lib)
set(COMMON_PKG_OUTPUT_PATH ${CMAKE_BINARY_DIR}/output/pkgconfig)
set(COMMON_ETC_OUTPUT_PATH ${CMAKE_BINARY_DIR}/output/etc)
set(COMMON_SHARE_OUTPUT_PATH ${CMAKE_BINARY_DIR}/output/share)
set(COMMON_CMAKE_OUTPUT_PATH ${CMAKE_BINARY_DIR}/output/cmake)
set(COMMON_INCLUDE_OUTPUT_PATH ${CMAKE_BINARY_DIR}/output/include)
option(CLUSTER_USE_QT6 "Use Qt6 library" OFF)
if(CLUSTER_USE_QT6)
    find_package(QT NAMES Qt6 REQUIRED)
else()
    find_package(QT NAMES Qt5 REQUIRED)
endif()
find_package(Qt${QT_VERSION_MAJOR} REQUIRED COMPONENTS
    Core Gui Quick RemoteObjects
)
message("** QT_VERSION=${QT_VERSION}")
if(EXISTS "${CMAKE_SOURCE_DIR}/external/bootmanager/CMakeLists.txt")
    message("** Add bootmanager package by external")
    add_subdirectory(external/bootmanager)
else()
    find_package(bootmanager QUIET)
endif()
if(EXISTS "${CMAKE_SOURCE_DIR}/external/cluster/CMakeLists.txt")
    message("** Add cluster package by external")
    add_subdirectory(external/cluster)
else()
    find_package(cluster REQUIRED)
endif()
add_subdirectory(servers)
add_subdirectory(hmi)

###############
###IDL
###############
file(GLOB
    IDL_SOURCES
    ${CMAKE_SOURCE_DIR}/idl/${CLUSTER_SERVERS_PROJECT}/*.*
)
add_custom_target(idl SOURCES ${IDL_SOURCES})
unset(IDL_SOURCES)
