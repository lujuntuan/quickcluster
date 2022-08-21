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

#ifndef BOOT_CHECKER_H
#define BOOT_CHECKER_H

#include <QThread>

class BootManager;
class QSharedMemory;
class QBuffer;
class QDataStream;
class QMutex;

class BootChecker : public QThread {
public:
    enum CfgCommand {
        CFG_LIST = 0,
        CFG_ENABLE = 1,
        CFG_DISABLE = 2,
        CFG_MOVEUP = 3,
        CFG_MOVEDOWN = 4,
        CFG_DETAIL = 5
    };
    BootChecker(BootManager* manager);
    ~BootChecker();

protected:
    void run() override;

private:
    void dealClientCommand(const QString& command1, const QString& command2);
    void setCfgFile(const QString& name, const CfgCommand& cfgCommand);

public:
    void initComponent();
    void initClientMem();
    void runChecking();
    void startDestroy();

private:
    BootManager* m_manager = nullptr;
    QString m_cfgPath;
    QString m_cfgDir;
    QString m_checkStr;
};

#endif // BOOT_CHECKER_H
