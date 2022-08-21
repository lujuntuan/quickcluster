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
include(${CMAKE_SOURCE_DIR}/cmake/find_qtav.cmake)
find_package(Qt${QT_VERSION_MAJOR} REQUIRED COMPONENTS
    Core Gui Quick RemoteObjects
)
link_libraries(
    Qt${QT_VERSION_MAJOR}::Core
    Qt${QT_VERSION_MAJOR}::Gui
    Qt${QT_VERSION_MAJOR}::Quick
    Qt${QT_VERSION_MAJOR}::RemoteObjects
    )
set(CMAKE_AUTOMOC ON)

##########

set(CLUSTER_PLATFORM_DOC_PATH "" CACHE STRING "Cluster platform doc path")
if(NOT ${CLUSTER_PLATFORM_DOC_PATH} STREQUAL "")
    add_definitions(
        "-DCLUSTER_PLATFORM_DOC_PATH=\"${CLUSTER_PLATFORM_DOC_PATH}\""
        )
    message("** CLUSTER_PLATFORM_DOC_PATH=${CLUSTER_PLATFORM_DOC_PATH}")
endif()
project(cluster VERSION ${CMAKE_PROJECT_VERSION} LANGUAGES C CXX)
file(GLOB_RECURSE
    PROJECT_SOURCES
    ${PROJECT_SOURCE_DIR}/include/*
    ${PROJECT_SOURCE_DIR}/src/*.*
    )
add_library(
    ${PROJECT_NAME}
    ${PROJECT_SOURCES}
    )
target_include_directories(
    ${PROJECT_NAME}
    PUBLIC
    $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/include>
    $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/../bootmanager/include>
    $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
    )
target_compile_definitions(
    ${PROJECT_NAME}
    PRIVATE
    "-DCLUSTER_LIBRARY"
    )
if(TARGET bootdaemon OR bootmanager_FOUND)
    message("** CLUSTER_HAS_BOOT_DAEMON=true")
    target_compile_definitions(
        ${PROJECT_NAME}
        PRIVATE
        "-DCLUSTER_HAS_BOOT_DAEMON"
        )
    target_link_libraries(
        ${PROJECT_NAME}
        bootdaemon
        )
endif()
set_target_properties(
    ${PROJECT_NAME}
    PROPERTIES
    VERSION
    ${PROJECT_VERSION}
    SOVERSION
    ${PROJECT_VERSION_MAJOR}
    )
install(
    TARGETS
    ${PROJECT_NAME}
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
    ${PROJECT_SOURCE_DIR}/include/cluster
    DESTINATION
    ${CMAKE_INSTALL_INCLUDEDIR}
    )
