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

include(${CMAKE_SOURCE_DIR}/cmake/defines.cmake)
find_package(Qt${QT_VERSION_MAJOR} REQUIRED COMPONENTS Core)
set(CMAKE_AUTOMOC ON)

##########

project(bootmanager VERSION ${CMAKE_PROJECT_VERSION} LANGUAGES C CXX)
include_directories(
    ${PROJECT_SOURCE_DIR}/src
    )
file(GLOB
    PROJECT_SOURCES
    ${PROJECT_SOURCE_DIR}/src/*.*
    )
file(GLOB
    BOOTCLI_SOURCES
    ${PROJECT_SOURCE_DIR}/src/extend/bootcli.cpp
    )
file(GLOB
    BOOTDAEMON_SOURCES
    ${PROJECT_SOURCE_DIR}/include/${PROJECT_NAME}/*
    ${PROJECT_SOURCE_DIR}/src/extend/bootdaemon.cpp
    )
file(GLOB
    COMMON_SOURCES
    ${PROJECT_SOURCE_DIR}/src/common/*.*
    )
add_executable(
    bootmanager
    ${PROJECT_SOURCES}
    ${COMMON_SOURCES}
    )
add_executable(
    bootcli
    ${BOOTCLI_SOURCES}
    ${COMMON_SOURCES}
    )
add_library(
    bootdaemon
    ${BOOTDAEMON_SOURCES}
    ${COMMON_SOURCES}
    )
    link_libraries(
    Qt${QT_VERSION_MAJOR}::Core
    )
target_link_libraries(
    bootmanager
    PRIVATE
    Qt${QT_VERSION_MAJOR}::Core
    )
target_link_libraries(
    bootcli
    PRIVATE
    Qt${QT_VERSION_MAJOR}::Core
    )
target_link_libraries(
    bootdaemon
    PUBLIC
    Qt${QT_VERSION_MAJOR}::Core
    )
target_include_directories(
    bootdaemon
    PUBLIC
    $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/include>
    $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
    )
target_compile_definitions(
    bootdaemon
    PRIVATE
    "-DBOOTDAEMON_LIBRARY"
    )
find_package(automotive-dlt QUIET)
if(automotive-dlt_FOUND)
    option(CLUSTER_DLT_LOG "Cluster use dlt log" OFF)
    if(CLUSTER_DLT_LOG)
        if(automotive-dlt_FOUND)
            target_link_libraries(
                bootmanager
                $<BUILD_INTERFACE:Genivi::dlt>
                )
        else()
            target_include_directories(
                bootmanager
                PRIVATE
                ${DLT_INCLUDE_DIR}
                )
            target_link_libraries(
                bootmanager
                $<BUILD_INTERFACE:${DLT_LIBRARY}>
                )
        endif()
        target_compile_definitions(
            bootmanager
            PRIVATE
            "-DCLUSTER_HAS_DLT"
            )
        message("** CLUSTER_HAS_DLT=true")
    endif()
endif()
install(
    TARGETS
    bootmanager
    bootcli
    bootdaemon
    EXPORT
    ${PROJECT_NAME}Config
    RUNTIME
    DESTINATION
    ${CMAKE_INSTALL_BINDIR}
    ARCHIVE
    DESTINATION
    ${CMAKE_INSTALL_LIBDIR}
    LIBRARY
    DESTINATION
    ${CMAKE_INSTALL_LIBDIR}
    INCLUDES
    DESTINATION
    ${CMAKE_INSTALL_INCLUDEDIR}
    )
install(
    EXPORT
    ${PROJECT_NAME}Config
    DESTINATION
    ${CMAKE_INSTALL_LIBDIR}/cmake/${PROJECT_NAME}
    )
install(
    DIRECTORY
    ${PROJECT_SOURCE_DIR}/include/bootmanager
    DESTINATION
    ${CMAKE_INSTALL_INCLUDEDIR}
    )
if(EXISTS ${PROJECT_SOURCE_DIR}/etc)
    cluster_install_etc(bootmanager)
endif()
