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

if(VSOMEIP_INCLUDE_DIR AND VSOMEIP_LIBRARY)
    message("** CLUSTER_HAS_VSOMEIP=true")
    add_definitions(
        "-DCLUSTER_HAS_VSOMEIP"
        )
    include_directories(
        ${VSOMEIP_INCLUDE_DIR}
        ${PROTOBUF_INCLUDE_DIR}
        )
    link_libraries(
        $<BUILD_INTERFACE:${VSOMEIP_LIBRARY}>
        $<BUILD_INTERFACE:${PROTOBUF_LIBRARY}>
        )
elseif(FDBUS_INCLUDE_DIR AND FDBUS_LIBRARY)
    message("** CLUSTER_HAS_FDBUS=true")
    add_definitions(
        "-DCLUSTER_HAS_FDBUS"
        )
    include_directories(
        ${FDBUS_INCLUDE_DIR}
        ${PROTOBUF_INCLUDE_DIR}
        )
    link_libraries(
        $<BUILD_INTERFACE:${FDBUS_LIBRARY}>
        $<BUILD_INTERFACE:${PROTOBUF_LIBRARY}>
        )
    if(MSVC)
        add_definitions(
            "-D__WIN32__"
            )
        link_libraries(
            ws2_32
            )
        foreach(var
                CMAKE_C_FLAGS CMAKE_C_FLAGS_DEBUG CMAKE_C_FLAGS_RELEASE
                CMAKE_C_FLAGS_MINSIZEREL CMAKE_C_FLAGS_RELWITHDEBINFO
                CMAKE_CXX_FLAGS CMAKE_CXX_FLAGS_DEBUG CMAKE_CXX_FLAGS_RELEASE
                CMAKE_CXX_FLAGS_MINSIZEREL CMAKE_CXX_FLAGS_RELWITHDEBINFO
                )
            if(${var} MATCHES "/MD")
                string(REGEX REPLACE "/MD" "/MT" ${var} "${${var}}")
            endif()
        endforeach()
    endif()
endif()

file(GLOB SUB_DIRS RELATIVE "${CMAKE_CURRENT_LIST_DIR}" ${CMAKE_CURRENT_LIST_DIR}/*)
foreach(SUB_PROJECT ${SUB_DIRS})
    if(IS_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/${SUB_PROJECT})
        add_subdirectory(${SUB_PROJECT})
    endif()
endforeach()
