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

find_package(QtAV QUIET)
search_3rdparty_begin(qtav)
find_path(QTAV_INCLUDE_DIR
    NAMES
    QtAV/QtAV.h
    HINTS
    /usr/include/qt
    PATHS
    ${3RD_INC_SEARCH_PATH}
    )
find_library(QTAV_LIBRARY
    NAMES
    QtAV
    libQtAV
    PATHS
    ${3RD_LIB_SEARCH_PATH}
    )
search_3rdparty_end()

if(QtAV_FOUND OR (QTAV_INCLUDE_DIR AND QTAV_LIBRARY))
    set(QTAV_ENABLE ON)
    if(QTAV_INCLUDE_DIR AND QTAV_LIBRARY)
        message(STATUS "QTAV_INCLUDE_DIR=${QTAV_INCLUDE_DIR}")
        message(STATUS "QTAV_LIBRARY=${QTAV_LIBRARY}")
    else()
        message(STATUS "")
    endif()
    message(STATUS "qtav found")
else()
    set(QTAV_ENABLE OFF)
    message(STATUS "qtav not found")
endif()

