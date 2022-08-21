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
include(${CMAKE_SOURCE_DIR}/cmake/repproject.cmake)
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
set(CMAKE_AUTORCC ON)

##########

option(CLUSTER_IMAGE_CACHE "Cluster use image cache" ON)
if(CLUSTER_IMAGE_CACHE)
    add_definitions(
        "-DCLUSTER_IMAGE_CACHE"
        )
    message("** CLUSTER_IMAGE_CACHE=true")
endif()
if(QTAV_ENABLE)
    option(CLUSTER_QTAV_ANIMATION "Cluster use qtav animation" OFF)
    option(CLUSTER_QTAV_NAVI "Cluster use qtav navi" OFF)
    if(CLUSTER_QTAV_ANIMATION)
        add_definitions(
            "-DCLUSTER_QTAV_ANIMATION"
            )
        message("** CLUSTER_QTAV_ANIMATION=true")
    endif()
    if(CLUSTER_QTAV_NAVI)
        add_definitions(
            "-DCLUSTER_QTAV_NAVI"
            )
        message("** CLUSTER_QTAV_NAVI=true")
    endif()
endif()

##########

add_subdirectory("cluster-hmi-${CLUSTER_HMI_PROJECT}")
