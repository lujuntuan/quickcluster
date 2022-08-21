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

#ifndef BOOT_MANAGER_H
#define BOOT_MANAGER_H

#include <QMutex>
#include <QObject>

class QSharedMemory;
class BootChecker;
class BootProcess;

class BootManager : public QObject {
    Q_OBJECT
public:
    explicit BootManager(QObject* parent = nullptr);
    ~BootManager();
    void init();
    void destroy();

private slots:
    void startDestroyWork();

private:
    void close();

private:
    friend class BootChecker;
    bool m_hasInit = false;
    BootChecker* m_checker = nullptr;
    QSharedMemory* m_clientMem = nullptr;
    QMutex m_checkMutex;
    QList<BootProcess*> m_listProcess;
    QList<BootProcess*> m_listDestroyProcess;
};

#endif // BOOT_MANAGER_H
