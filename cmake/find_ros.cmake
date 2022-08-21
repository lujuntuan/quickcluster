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

find_package(ament_cmake QUIET)
find_package(rclcpp QUIET)

if(ament_cmake_FOUND AND rclcpp_FOUND)
    set(ROS_ENABLE ON)
    message(STATUS "rclcpp found")
    message(STATUS "")
else()
    set(ROS_ENABLE OFF)
    message(STATUS "rclcpp not found")
endif()
