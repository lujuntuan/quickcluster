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

start_rep_project(source clusterivi)

if(PROTOBUF_ENABLE)
    if(VSOMEIP_INCLUDE_DIR AND VSOMEIP_LIBRARY)
        proto_generate_src(
            ${PROJECT_BINARY_DIR}
            PROTO_IDL_SRC
            ${CMAKE_CURRENT_LIST_DIR}/idl/vsomeip/*
            )
    elseif(FDBUS_INCLUDE_DIR AND FDBUS_LIBRARY)
        proto_generate_src(
            ${PROJECT_BINARY_DIR}
            PROTO_IDL_SRC
            ${CMAKE_CURRENT_LIST_DIR}/idl/fdbus/*
            )
    endif()
endif()
file(GLOB
    PROJECT_SOURCES
    ${PROJECT_SOURCE_DIR}/src/*.*
    )
add_executable(
    ${PROJECT_NAME}
    ${PROJECT_SOURCES}
    ${PROTO_IDL_SRC}
    )
target_include_directories(
    ${PROJECT_NAME}
    PRIVATE
    ${PROJECT_BINARY_DIR}
    )

if(EXISTS ${PROJECT_SOURCE_DIR}/etc)
    cluster_install_etc(${PROJECT_NAME})
endif()

end_rep_project()
