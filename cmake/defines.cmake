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

add_definitions(
    "-DCLUSTER_VERSION=\"${CLUSTER_VERSION}\""
    "-DCLUSTER_COMMITID=\"${CLUSTER_COMMITID}\""
    "-DCLUSTER_PLATFORM_NAME=\"${CLUSTER_PLATFORM_NAME}\""
    "-DCLUSTER_CLOSESIG_STR=\"\{**CLOSE**\}\""
    "-DCLUSTER_LOG_STR=\"\{**BOOTLOG**\}\""
    "-DCLUSTER_SLEEP_CHECK_INTERVAL=10"
    "-DCLUSTER_DEBUG_LOG=0"
    "-DCLUSTER_HEARTBEART_INTERVAL=1000"
    "-DCLUSTER_RECONNECT_INTERVAL=250"
    )
