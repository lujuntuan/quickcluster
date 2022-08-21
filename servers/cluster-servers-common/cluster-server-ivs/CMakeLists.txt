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

start_rep_project(source clusterivs)

file(GLOB
    PROJECT_SOURCES
    ${PROJECT_SOURCE_DIR}/src/*.*
    )
add_executable(
    ${PROJECT_NAME}
    ${PROJECT_SOURCES}
    )

if(EXISTS ${PROJECT_SOURCE_DIR}/etc)
    cluster_install_etc(${PROJECT_NAME})
endif()

end_rep_project()
