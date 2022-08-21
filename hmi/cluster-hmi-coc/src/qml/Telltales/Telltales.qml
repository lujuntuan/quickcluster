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
        parent: mainRect
        z:100
        width: row1.width
        height: 50
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 20
        Row {
            id:row1
            anchors.centerIn: parent
            spacing: 300
            TelltalesImage {
                name: "icon_left_signal"
            }
            TelltalesImage {
                name: "icon_right_signal"
            }
        }
    }
    Item {
        id: rect2
        parent: mainRect
        z:100
        width: row2.width
        height: 50
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 90
        Row {
            id:row2
            anchors.centerIn: parent
            spacing: 5
            TelltalesImage {
                name: "ibooster_fault"
            }
            TelltalesImage {
                name: "eps_amber"
            }
            TelltalesImage {
                name: "esc_off"
            }
            TelltalesImage {
                name: "esc"
            }
            TelltalesImage {
                name: "dfw"
            }
            TelltalesImage {
                name: "low_beam_lights"
            }
            TelltalesImage {
                name: "high_beam"
            }
            TelltalesImage {
                name: "position"
            }
            TelltalesImage {
                name: "front_fog"
            }
            TelltalesImage {
                name: "rear_fog"
            }
            TelltalesImage {
                name: "seat_belt"
            }
            TelltalesImage {
                name: "tire_pressure"
            }
            TelltalesImage {
                name: "hill_holder_green"
            }
            TelltalesImage {
                name: "autohold_g"
            }
            TelltalesImage {
                name: "park_brake"
            }
            TelltalesImage {
                name: "waring_y"
            }
        }
    }
    Item {
        id: rect3
        width: row3.width
        height: 50
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.leftMargin: 20
        anchors.bottomMargin: 20
        Row {
            id: row3
            anchors.centerIn: parent
            spacing: 5
            TelltalesImage {
                name: "ldw_activation"
            }
            TelltalesImage {
                name: "tja_g"
            }
            TelltalesImage {
                name: "acc_g"
            }
            TelltalesImage {
                name: "ready_g"
                width: 100
            }
            TelltalesImage {
                name: "battery_status"
            }
            TelltalesImage {
                name: "abs_fault"
            }
        }
    }
    Item {
        id: rect4
        width: row4.width
        height: 50
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.rightMargin: 20
        anchors.bottomMargin: 20
        Row {
            id:row4
            anchors.centerIn: parent
            spacing: 5
            TelltalesImage {
                name: "ebd_fault"
            }
            TelltalesImage {
                name: "icon_aeb_closed"
            }
            TelltalesImage {
                name: "icon_fcw_closed"
            }
            TelltalesImage {
                name: "bsd_fault"
            }
            TelltalesImage {
                name: "fule_green"
            }
            TelltalesImage {
                name: "cycle_g"
            }
            TelltalesImage {
                name: "battery_link"
            }
            TelltalesImage {
                name: "motor_fault"
            }
        }
    }
    Item {
        id: rect5
        width: 50
        height: column5.height
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.leftMargin: 20
        anchors.bottomMargin: 90
        Column {
            id:column5
            anchors.centerIn: parent
            spacing: 5
            TelltalesImage {
                name: "ohm"
            }
            TelltalesImage {
                name: "oil"
            }
            TelltalesImage {
                name: "water"
            }
            TelltalesImage {
                name: "ems"
            }
            TelltalesImage {
                name: "power_limit"
            }
        }
    }
    Item {
        id: rect6
        width: 50
        height: column6.height
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.rightMargin: 20
        anchors.bottomMargin: 90
        Column {
            id:column6
            anchors.centerIn: parent
            spacing: 5
            TelltalesImage {
                name: "power_system_fault"
            }
            TelltalesImage {
                name: "battery"
            }
            TelltalesImage {
                name: "battery_fault"
            }
            TelltalesImage {
                name: "battery_low"
            }
        }
    }
}
