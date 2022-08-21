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

include(${CMAKE_CURRENT_LIST_DIR}/find_protobuf.cmake)

search_3rdparty_begin(fdbus)
find_path(FDBUS_INCLUDE_DIR
    NAMES
    fdbus/fdbus.h
    common_base/fdbus.h
    PATHS
    ${3RD_INC_SEARCH_PATH}
    PATH_SUFFIXES
    usr
    )
find_library(FDBUS_LIBRARY
    NAMES
    fdbus
    libfdbus
    common_base
    libcommon_base
    PATHS
    ${3RD_LIB_SEARCH_PATH}
    PATH_SUFFIXES
    usr
    )
mark_as_advanced(FDBUS_INCLUDE_DIR FDBUS_LIBRARY)
search_3rdparty_end()

if(FDBUS_INCLUDE_DIR AND FDBUS_LIBRARY AND PROTOBUF_ENABLE)
    set(FDBUS_ENABLE ON)
    message(STATUS "fdbus found")
    message(STATUS "FDBUS_INCLUDE_DIR=${FDBUS_INCLUDE_DIR}")
    message(STATUS "FDBUS_LIBRARY=${FDBUS_LIBRARY}")
    if(FDBUS_LIBRARY MATCHES ".*fdbus.*")
        set(FDBUS_NEW_INTERFACE ON)
    else()
        set(FDBUS_NEW_INTERFACE OFF)
    endif()
    message(STATUS "FDBUS_NEW_INTERFACE=${FDBUS_NEW_INTERFACE}")
    get_filename_component(FDBUS_LIBRARY_SUFFIX ${FDBUS_LIBRARY} EXT)
    if(WIN32 OR (${FDBUS_LIBRARY_SUFFIX} MATCHES ".a"))
        add_library(fdbus STATIC IMPORTED)
    else()
        add_library(fdbus SHARED IMPORTED)
    endif()
    get_filename_component(FDBUS_LIBRARY_NAME ${FDBUS_LIBRARY} NAME)
    set_target_properties(
        fdbus
        PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES
        ${FDBUS_INCLUDE_DIR}
        IMPORTED_LOCATION
        ${FDBUS_LIBRARY}
        IMPORTED_SONAME
        ${FDBUS_LIBRARY_NAME}
    )
else()
    set(FDBUS_ENABLE OFF)
    message(STATUS "fdbus not found")
endif()
