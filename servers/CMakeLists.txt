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
include(${CMAKE_SOURCE_DIR}/cmake/find_fdbus.cmake)
include(${CMAKE_SOURCE_DIR}/cmake/find_vsomeip.cmake)
find_package(Qt${QT_VERSION_MAJOR} REQUIRED COMPONENTS
    Core Gui RemoteObjects
)
find_package(Threads REQUIRED)
link_libraries(
    Qt${QT_VERSION_MAJOR}::Core
    Qt${QT_VERSION_MAJOR}::Gui
    Qt${QT_VERSION_MAJOR}::RemoteObjects
    ${CMAKE_THREAD_LIBS_INIT}
    )
set(CMAKE_AUTOMOC ON)

##########

add_subdirectory("cluster-servers-${CLUSTER_SERVERS_PROJECT}")
