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

#include "clusterivs.h"
#include <QCoreApplication>
#include <QPropertyAnimation>
#include <QThread>
#include <QTimerEvent>

extern bool __ENABLE_TEST;

static int timerID1 = -1;
static int timerID2 = -1;
static uint testID1 = 0;
static uint testID2 = 0;

#define ANIMATION_DURATION 2000

ClusterIvs::ClusterIvs(QObject* parent)
    : ClusterIvsSimpleSource(parent)
    , m_speedAnimation(new QPropertyAnimation(this, "speed"))
    , m_engineAnimation(new QPropertyAnimation(this, "engine"))
    , m_batteryAnimation(new QPropertyAnimation(this, "battery"))
    , m_fuelAnimation(new QPropertyAnimation(this, "fuel"))
    , m_waterAnimation(new QPropertyAnimation(this, "water"))
{
    m_speedAnimation->setDuration(ANIMATION_DURATION);
    m_speedAnimation->setEasingCurve(QEasingCurve::OutQuad);
    m_engineAnimation->setDuration(ANIMATION_DURATION);
    m_engineAnimation->setEasingCurve(QEasingCurve::OutQuad);
    m_batteryAnimation->setDuration(ANIMATION_DURATION);
    m_batteryAnimation->setEasingCurve(QEasingCurve::OutQuad);
    m_fuelAnimation->setDuration(ANIMATION_DURATION);
    m_fuelAnimation->setEasingCurve(QEasingCurve::OutQuad);
    m_waterAnimation->setDuration(ANIMATION_DURATION);
    m_waterAnimation->setEasingCurve(QEasingCurve::OutQuad);

    if (__ENABLE_TEST) {
        timerID1 = this->startTimer(2400, Qt::CoarseTimer);
        timerID2 = this->startTimer(400, Qt::CoarseTimer);
        //
        setConnected(true);
        setTemp(-5);
        setTotal(99999.0f);
        setTrip(1999.8f);
        setAvgSpeed(45.0f);
        setAvgFuel(8.0f);
        setMaxFuel(60.0f);
        setTireFrontLeft(Tire(-3, 2.1f));
        setTireFrontRight(Tire(-1, 2.2f));
        setTireBehindLeft(Tire(0, 2.3f));
        setTireBehindRight(Tire(-2, 1.4f));
        setDate(QDateTime(QDate(2022, 1, 1), QTime(8, 30)));
        QVariantMap varMap = {
            { "icon_autohold", 1 },
            { "icon_high_beam", 1 },
            { "icon_sport", 1 },
            { "icon_sea_belt_warning", 1 },
            { "icon_charging_fault_warnig", 1 },
            { "icon_transmission_fault", 1 },
            { "icon_warning", 1 },
            { "icon_epc", 1 },
            { "icon_engine_fault", 1 },
            { "icon_engine_oil_pressure_fault", 1 },
            { "icon_front_fog_lamps", 1 },
            { "icon_low_key_battery_power", 1 },
            { "icon_start_stop", 1 },
            { "position", 1 },
            { "autohold_g", 1 },
            { "low_beam_lights", 1 },
            { "seat_belt", 1 },
            { "smart_key", 1 },
        };
        setTelltalesMap(varMap);
    }
}

ClusterIvs::~ClusterIvs()
{
}

void ClusterIvs::playSpeed(float value)
{
    m_speedAnimation->setStartValue(m_speedAnimation->currentValue());
    m_speedAnimation->setEndValue(value);
    m_speedAnimation->start();
}

void ClusterIvs::playEngine(float value)
{
    m_engineAnimation->setStartValue(m_engineAnimation->currentValue());
    m_engineAnimation->setEndValue(value);
    m_engineAnimation->start();
}

void ClusterIvs::playBattery(float value)
{
    m_batteryAnimation->setStartValue(m_batteryAnimation->currentValue());
    m_batteryAnimation->setEndValue(value);
    m_batteryAnimation->start();
}

void ClusterIvs::playFuel(float value)
{
    m_fuelAnimation->setStartValue(m_fuelAnimation->currentValue());
    m_fuelAnimation->setEndValue(value);
    m_fuelAnimation->start();
}

void ClusterIvs::playWater(float value)
{
    m_waterAnimation->setStartValue(m_waterAnimation->currentValue());
    m_waterAnimation->setEndValue(value);
    m_waterAnimation->start();
}

void ClusterIvs::timerEvent(QTimerEvent* event)
{
    Q_UNUSED(event)
    if (__ENABLE_TEST == false) {
        return;
    }
    if (event->timerId() == timerID1) {
        if (testID1 % 7 == 0) {
            playSpeed(10);
            playEngine(1600);
            playFuel(50);
            playBattery(20);
            playWater(-10);
            setGear(GEAR_P);
            setDrive(DRIVE_COMFORT);
            setBatteryState(BATTERY_NORMAL);
        } else if (testID1 % 7 == 1) {
            playSpeed(30);
            playEngine(1700);
            playFuel(40);
            playBattery(45.5);
            playWater(0);
            setGear(GEAR_R);
            setDrive(DRIVE_SUPPORT);
            setBatteryState(BATTERY_NORMAL);
        } else if (testID1 % 7 == 2) {
            playSpeed(90);
            playEngine(3500);
            playFuel(20);
            playBattery(9.5);
            playWater(12);
            setGear(GEAR_R);
            setDrive(DRIVE_SUPPORT);
            setBatteryState(BATTERY_NORMAL);
        } else if (testID1 % 7 == 3) {
            playSpeed(120);
            playEngine(2200);
            playFuel(0);
            playBattery(100);
            playWater(58);
            setGear(GEAR_D);
            setDrive(DRIVE_SUPPORT);
            setBatteryState(BATTERY_FILL);
        } else if (testID1 % 7 == 4) {
            playSpeed(160);
            playEngine(6000);
            playFuel(30);
            playBattery(5);
            playWater(80);
            setGear(GEAR_D);
            setDrive(DRIVE_ECO);
            setBatteryState(BATTERY_ERROR);
        } else if (testID1 % 7 == 5) {
            playSpeed(100);
            playEngine(2000);
            playFuel(45);
            playBattery(80);
            playWater(99);
            setGear(GEAR_D);
            setDrive(DRIVE_ECO);
            setBatteryState(BATTERY_NORMAL);
        } else if (testID1 % 7 == 6) {
            playSpeed(60);
            playEngine(1800);
            playFuel(60);
            playBattery(50);
            playWater(48);
            setGear(GEAR_N);
            setDrive(DRIVE_COMFORT);
            setBatteryState(BATTERY_NORMAL);
        }
        testID1++;
        if (testID1 >= 10000) {
            testID1 = 0;
        }
    } else if (event->timerId() == timerID2) {
        if (testID2 % 2 == 0) {
            QVariantMap varMap = telltalesMap();
            varMap.insert(QStringLiteral("icon_left_signal"), 1);
            varMap.insert(QStringLiteral("icon_right_signal"), 1);
            setTelltalesMap(varMap);
        } else {
            QVariantMap varMap = telltalesMap();
            varMap.insert(QStringLiteral("icon_left_signal"), 0);
            varMap.insert(QStringLiteral("icon_right_signal"), 0);
            setTelltalesMap(varMap);
        }
        testID2++;
        if (testID2 >= 10000) {
            testID2 = 0;
        }
    }
}

void ClusterIvs::receiveClientCommand(const QString& command)
{
    qDebug() << command;
    QStringList paras = command.split("=");
    if (paras.length() != 2) {
        return;
    }
    QString key = paras.at(0).toLower().trimmed();
    QString value = paras.at(1).toLower().trimmed();
    if (key == QStringLiteral("connected")) {
        setConnected(value.toInt());
    } else if (key == QStringLiteral("test")) {
        __ENABLE_TEST = (bool)value.toInt();
    } else if (key == QStringLiteral("speed")) {
        playSpeed(value.toFloat());
    } else if (key == QStringLiteral("engine")) {
        playEngine(value.toFloat());
    } else if (key == QStringLiteral("fuel")) {
        playFuel(value.toFloat());
    } else if (key == QStringLiteral("water")) {
        playWater(value.toFloat());
    } else if (key == QStringLiteral("total")) {
        setTotal(value.toFloat());
    } else if (key == QStringLiteral("trip")) {
        setTrip(value.toFloat());
    } else if (key == QStringLiteral("temp")) {
        setTemp(value.toFloat());
    } else if (key == QStringLiteral("date")) {
        setDate(QDateTime::fromString(value));
    } else if (key == QStringLiteral("gear")) {
        if (value == QStringLiteral("p")) {
            setGear(GEAR_P);
        } else if (value == QStringLiteral("r")) {
            setGear(GEAR_R);
        } else if (value == QStringLiteral("n")) {
            setGear(GEAR_N);
        } else if (value == QStringLiteral("d")) {
            setGear(GEAR_D);
        }
    } else if (key == QStringLiteral("telltalesmap")) {
        QStringList valueList = value.split(",");
        if (valueList.length() != 2) {
            return;
        }
        QVariantMap varMap = telltalesMap();
        varMap.insert(valueList.at(0), valueList.at(1));
        setTelltalesMap(varMap);
    }
    ClusterServerProxy<ClusterIvs>::receiveClientCommand(command);
}
