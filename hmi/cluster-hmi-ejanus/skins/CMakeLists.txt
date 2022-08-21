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

find_package(Qt${QT_VERSION_MAJOR} REQUIRED COMPONENTS Core)
link_libraries(
    Qt${QT_VERSION_MAJOR}::Core
    )
set(CMAKE_AUTORCC ON)

##########

file(GLOB SUB_QRCS RELATIVE "${CMAKE_CURRENT_LIST_DIR}" "${CMAKE_CURRENT_LIST_DIR}/*.qrc")
foreach(SUB_QRC ${SUB_QRCS})
    if(EXISTS ${CMAKE_CURRENT_LIST_DIR}/${SUB_QRC})
        get_filename_component(SUB_NAME ${SUB_QRC} NAME_WE)
        project(${SUB_NAME} VERSION ${CMAKE_PROJECT_VERSION} LANGUAGES C CXX)
        set(LIBRARY_NAME "${REP_PROJECT_NAME}-skin-${SUB_NAME}")
        set(IMG_SOURCES "")
        add_library(
            ${LIBRARY_NAME}
            "${CMAKE_CURRENT_LIST_DIR}/${SUB_QRC}"
            )
         set_target_properties(
             ${LIBRARY_NAME}
             PROPERTIES
             LINKER_LANGUAGE
             CXX
             LIBRARY_OUTPUT_DIRECTORY
             ${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/cluster-skins
             ARCHIVE_OUTPUT_DIRECTORY
             ${CMAKE_ARCHIVE_OUTPUT_DIRECTORY}/cluster-skins
             RUNTIME_OUTPUT_DIRECTORY
             ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/cluster-skins
             )
         set_target_properties(
             ${LIBRARY_NAME}
             PROPERTIES
             PREFIX
             ""
         )
         install(
             TARGETS
             ${LIBRARY_NAME}
             ARCHIVE
             DESTINATION
             ${CMAKE_INSTALL_LIBDIR}/cluster-skins
             LIBRARY
             DESTINATION
             ${CMAKE_INSTALL_LIBDIR}/cluster-skins
             )
    endif()
endforeach()
