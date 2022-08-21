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
import Cluster 1.0
import "Dashboard"
import "Telltales"

Item {
    id: mainRect
    width: 1920
    height: 720
    property string hmiSetPath: ClusterManager.platformDocPath + "/clusterhmi-coc.json"
    property var hmiSet: {
        "id": "clusterhmi",
        "skin": "dark"
    }
    Component.onCompleted: {
        readHmiSet()
        if(ClusterManager.skinList.length>0){
            if(ClusterManager.skinList.includes(hmiSet.skin)){
                ClusterManager.skin = hmiSet.skin
            }else{
                ClusterManager.skin=ClusterManager.skinList[0]
            }
            skinMask.init(ClusterManager.skin)
        }else{
            console.log("Can not find any skins!");
            ClusterManager.view.close()
        }
    }
    function readHmiSet() {
        if (ClusterManager.fileExists(hmiSetPath) === false) {
            saveHmiSet()
            return
        }
        var readData = ClusterManager.readJson(hmiSetPath)
        if (readData === undefined) {
            return
        }
        if (readData.id === undefined) {
            return
        }
        if (readData.id !== "clusterhmi") {
            return
        }
        hmiSet = readData
    }
    function saveHmiSet() {
        ClusterManager.saveJson(hmiSet, hmiSetPath)
    }
    Image {
        id: backgroundImg
        anchors.fill: parent
        source: ClusterManager.impSkinPath + "/main/bg.png"
        opacity: 1
        visible: opacity > 0
    }
    Dashboard {
        id: dashboard
        anchors.fill: parent
        speed: ClusterIvs.speed
        engine: ClusterIvs.engine
        fuel: ClusterIvs.fuel
        water: ClusterIvs.water
        avgFuel: ClusterIvs.avgFuel
        maxFuel: ClusterIvs.maxFuel
        opacity: 1
        visible: opacity > 0
        onInitFinished: {
            loader.active=true
        }
    }
    Telltales {
        id: telltales
        anchors.fill: parent
    }
    Loader {
        id: loader
        anchors.fill: parent
        sourceComponent: MainPart{

        }
        asynchronous: false
        active: false
        onLoaded: {
            telltales.telltalesMap = Qt.binding(function () {
                return ClusterIvs.telltalesMap
            })
            loader.item.init()
        }
    }
    SkinMask {
        id: skinMask
        z:1000
        onChanged: {
            ClusterManager.skin = skinMask.skin
            hmiSet.skin = ClusterManager.skin
            saveHmiSet()
        }
    }
    Connections {
        target: ClusterManager.view
        function onSceneGraphInitialized() {
            telltales.show()
            dashboard.playInitAni()
        }
    }
}
