/*********************************************************************************
 *Copyright(C): Juntuan.Lu, 2020-2030, All rights reserved.
 *Author:  Juntuan.Lu
 *Version: 1.0
 *Date:  2021/07/22
 *Email: 931852884@qq.com
 *Description:
 *Others:
 *Function List:
 *History:
 **********************************************************************************/

import QtQuick 2.15
import "../Common"

Item {
    id: telltales
    property var telltalesMap: ({})
    property string iconPath: "icon"
    property bool inited: false
    opacity: 0
    visible: opacity > 0
    Behavior on opacity {
        NumberAnimation {
            easing.type: Easing.OutCubic
            duration: 500
        }
    }
    function show() {
        telltales.opacity = 1
    }
    function hide() {
        telltales.opacity = 0
    }
    function init() {
        inited=true
    }
    Item {
        id: rect1
        width: 500
        height: 50
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.leftMargin: 50
        anchors.topMargin: 70
        Row {
            anchors.centerIn: parent
            spacing: 20
            TelltalesImage {
                name: "icon_engine_fault"
                anchors.verticalCenter: parent.verticalCenter
            }
            TelltalesImage {
                name: "icon_engine_oil_pressure_fault"
                anchors.verticalCenter: parent.verticalCenter
            }
            TelltalesImage {
                name: "icon_brake_system_fault"
                anchors.verticalCenter: parent.verticalCenter
            }
            TelltalesImage {
                name: "icon_sea_belt_warning"
                anchors.verticalCenter: parent.verticalCenter
            }
            TelltalesImage {
                name: "icon_sea_belt_warning_2"
                anchors.verticalCenter: parent.verticalCenter
            }
            TelltalesImage {
                name: "icon_airbag_fault"
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }
    Item {
        id: rect2
        width: 500
        height: 50
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.rightMargin: 50
        anchors.topMargin: 70
        Row {
            anchors.centerIn: parent
            spacing: 20
            TelltalesImage {
                name: "icon_parking_system_fault"
                anchors.verticalCenter: parent.verticalCenter
            }
            TelltalesImage {
                name: "icon_tire_pressure_monitoring_fault"
                nameList: ["icon_tire_pressure_monitoring_fault", "icon_tire_pressure_monitoring_fault_red"]
                anchors.verticalCenter: parent.verticalCenter
            }
            TelltalesImage {
                name: "icon_transmission_fault"
                anchors.verticalCenter: parent.verticalCenter
            }
            TelltalesImage {
                name: "icon_start_stop"
                nameList: ["icon_start_stop_Fault", "icon_start_stop_limited", "icon_start_stop_off", "icon_start_stop_work"]
                anchors.verticalCenter: parent.verticalCenter
            }
            TelltalesImage {
                name: "adas_smart_speed_limit_fault"
                anchors.verticalCenter: parent.verticalCenter
            }
            TelltalesImage {
                name: "icon_security_lights"
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }
    Item {
        id: rect3
        width: 500
        height: 50
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.leftMargin: 50
        anchors.bottomMargin: 70
        Row {
            anchors.centerIn: parent
            spacing: 20
            TelltalesImage {
                name: "icon_low_key_battery_power"
                anchors.verticalCenter: parent.verticalCenter
            }
            TelltalesImage {
                name: "icon_intelligent_system_fault"
                anchors.verticalCenter: parent.verticalCenter
            }
            TelltalesImage {
                name: "icon_abs_fault"
                anchors.verticalCenter: parent.verticalCenter
            }
            TelltalesImage {
                name: "icon_charging_fault_warnig"
                anchors.verticalCenter: parent.verticalCenter
            }
            TelltalesImage {
                name: "icon_unrecognized_key"
                anchors.verticalCenter: parent.verticalCenter
            }
            TelltalesImage {
                name: "icon_epb_fault"
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }
    Item {
        id: rect4
        width: 500
        height: 50
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.rightMargin: 50
        anchors.bottomMargin: 70
        Row {
            anchors.centerIn: parent
            spacing: 20
            TelltalesImage {
                name: "icon_eps_fault"
                nameList: ["icon_eps_fault", "icon_eps_fault_red"]
                anchors.verticalCenter: parent.verticalCenter
            }
            TelltalesImage {
                name: "icon_tcs_fault"
                anchors.verticalCenter: parent.verticalCenter
            }
            TelltalesImage {
                name: "icon_esp_off"
                anchors.verticalCenter: parent.verticalCenter
            }
            TelltalesImage {
                name: "icon_downhill_assistance"
                anchors.verticalCenter: parent.verticalCenter
            }
            TelltalesImage {
                name: "icon_epc"
                anchors.verticalCenter: parent.verticalCenter
            }
            TelltalesImage {
                name: "icon_warning"
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }
    Item {
        id: rect5
        width: 700
        height: 50
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 20
        Row {
            anchors.centerIn: parent
            spacing: 30
            TelltalesImage {
                name: "icon_left_signal"
                anchors.verticalCenter: parent.verticalCenter
            }
            TelltalesImage {
                name: "icon_high_beam"
                nameList: ["icon_high_beam", "icon_high_beam_grey"]
                anchors.verticalCenter: parent.verticalCenter
            }
            TelltalesImage {
                name: "icon_low_beam_lights"
                nameList: ["icon_low_beam_lights", "icon_low_beam_lights_grey"]
                anchors.verticalCenter: parent.verticalCenter
            }
            TelltalesImage {
                name: "icon_position_lights"
                nameList: ["icon_position_lights", "icon_position_lights_grey"]
                anchors.verticalCenter: parent.verticalCenter
            }
            TelltalesImage {
                name: "icon_front_fog_lamps"
                nameList: ["icon_front_fog_lamps", "icon_front_fog_lamps_grey"]
                anchors.verticalCenter: parent.verticalCenter
            }
            TelltalesImage {
                name: "icon_rear_fog_lamps"
                nameList: ["icon_rear_fog_lamps", "icon_rear_fog_lamps_grey"]
                anchors.verticalCenter: parent.verticalCenter
            }
            TelltalesImage {
                name: "icon_daytime_running_lamp"
                nameList: ["icon_daytime_running_lamp", "icon_daytime_running_lamp_grey"]
                anchors.verticalCenter: parent.verticalCenter
            }
            TelltalesImage {
                name: "icon_right_signal"
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }
    Item {
        id: rect6
        width: 80
        height: 120
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.horizontalCenterOffset: -390
        anchors.top: parent.top
        anchors.topMargin: 100
        Column {
            anchors.centerIn: parent
            spacing: 20
            TelltalesImage {
                name: "icon_cruise_information"
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }
    Item {
        id: rect7
        width: 80
        height: 120
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.horizontalCenterOffset: 390
        anchors.top: parent.top
        anchors.topMargin: 100
        Column {
            anchors.centerIn: parent
            spacing: 20
            TelltalesImage {
                name: "icon_sport"
                nameList: ["icon_sport", "icon_echo"]
                anchors.horizontalCenter: parent.horizontalCenter
            }
            TelltalesImage {
                name: "icon_autohold"
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }
}
