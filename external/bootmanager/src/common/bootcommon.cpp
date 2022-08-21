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

#include "bootcommon.h"
#include <QDataStream>
#include <QDebug>
#include <QIODevice>
#include <QSharedMemory>
#include <QSystemSemaphore>
#include <QThread>
#include <chrono>
#include <functional>

namespace BootCommon {

qint64 getCurrentTimeMs()
{
    const auto& now = std::chrono::steady_clock().now();
    const auto& duration = std::chrono::duration_cast<std::chrono::milliseconds>(now.time_since_epoch());
    return (qint64)duration.count();
}

bool waitSemaphore(const QString& key)
{
    QSystemSemaphore sema(key + BOOT_SEMA_FSTR, 0, QSystemSemaphore::Open);
    for (int i = 0; i < BOOT_RETRY_TIMES; i++) {
        if (sema.acquire() == true) {
            return true;
        }
        QThread::msleep(CLUSTER_SLEEP_CHECK_INTERVAL);
    }
    qWarning() << "Failed to wait semaphore";
    return false;
}

bool releaseSemaphore(const QString& key)
{
    QSystemSemaphore sema(key + BOOT_SEMA_FSTR, 0, QSystemSemaphore::Open);
    for (int i = 0; i < BOOT_RETRY_TIMES; i++) {
        if (sema.release(1) == true) {
            return true;
        }
        QThread::msleep(CLUSTER_SLEEP_CHECK_INTERVAL);
    }
    qWarning() << "Failed to release semaphore";
    return false;
}

bool clearMemory(QSharedMemory* mem)
{
    if (!mem) {
        return false;
    }
    if (!mem->isAttached()) {
        return false;
    }
    mem->lock();
    memset((char*)mem->data(), 0, mem->size());
    mem->unlock();
    return true;
}

bool writeMemory(QSharedMemory* mem, int type, const QVariant& content, bool force)
{
    auto writeFunction = [&]() {
        if (!mem) {
            return false;
        }
        if (!mem->isAttached()) {
            return false;
        }
        QByteArray byteArray;
        QDataStream stream(&byteArray, QIODevice::ReadWrite);
        if (force == false) {
            mem->lock();
            byteArray.setRawData((char*)mem->constData(), mem->size());
            mem->unlock();
            QString flagStr;
            stream >> flagStr;
            if (stream.status() != QDataStream::Ok) {
                return false;
            }
            if (flagStr != BOOT_CANWRITE_FSTR) {
                return false;
            }
            byteArray.resize(0);
            stream.device()->seek(0);
        }
        if (force == true) {
            stream << BOOT_CANWRITE_FSTR;
        } else {
            stream << BOOT_CANREAD_FSTR;
        }
        if (stream.status() != QDataStream::Ok) {
            return false;
        }
        stream << getCurrentTimeMs();
        if (stream.status() != QDataStream::Ok) {
            return false;
        }
        stream << type;
        if (stream.status() != QDataStream::Ok) {
            return false;
        }
        stream << content;
        if (stream.status() != QDataStream::Ok) {
            return false;
        }
        mem->lock();
        memcpy((char*)mem->data(), byteArray.data(), qMin(mem->size(), byteArray.size()));
        mem->unlock();
        return true;
    };
    for (int i = 0; i < BOOT_RETRY_TIMES; i++) {
        if (writeFunction() == true) {
            return true;
        }
        QThread::msleep(CLUSTER_SLEEP_CHECK_INTERVAL);
    }
    qWarning() << "Failed to write memory";
    return false;
}

bool readMemory(QSharedMemory* mem, int* type, QVariant* content, qint64* time, bool force)
{
    auto readFunction = [&]() {
        if (!mem) {
            return false;
        }
        if (!mem->isAttached()) {
            return false;
        }
        QByteArray byteArray;
        QDataStream stream(&byteArray, QIODevice::ReadWrite);
        if (force == false) {
            mem->lock();
            byteArray.setRawData((char*)mem->constData(), mem->size());
            mem->unlock();
            QString flagStr;
            stream >> flagStr;
            if (stream.status() != QDataStream::Ok) {
                return false;
            }
            if (flagStr != BOOT_CANREAD_FSTR) {
                return false;
            }
        }
        qint64 _time;
        stream >> _time;
        if (stream.status() != QDataStream::Ok) {
            return false;
        }
        if (time) {
            *time = _time;
        }
        if (type) {
            stream >> *type;
            if (stream.status() != QDataStream::Ok) {
                return false;
            }
        }
        if (content) {
            stream >> *content;
            if (stream.status() != QDataStream::Ok) {
                return false;
            }
        }
        byteArray.clear();
        stream.device()->seek(0);
        if (force == true) {
            stream << BOOT_CANREAD_FSTR;
        } else {
            stream << BOOT_CANWRITE_FSTR;
        }
        if (stream.status() != QDataStream::Ok) {
            return false;
        }
        mem->lock();
        memcpy((char*)mem->data(), byteArray.data(), qMin(mem->size(), byteArray.size()));
        mem->unlock();
        return true;
    };
    for (int i = 0; i < 1; i++) {
        if (readFunction() == true) {
            return true;
        }
        QThread::msleep(CLUSTER_SLEEP_CHECK_INTERVAL);
    }
    // qWarning() << "Failed to read memory";
    return false;
}

}
