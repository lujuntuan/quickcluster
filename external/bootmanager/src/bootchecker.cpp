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

#include "bootchecker.h"
#include "bootlog.h"
#include "bootmanager.h"
#include "bootprocess.h"
#include "common/bootcommon.h"
#include <QAtomicInt>
#include <QCoreApplication>
#include <QDebug>
#include <QDir>
#include <QFile>
#include <QJsonDocument>
#include <QSharedMemory>
#include <QTextStream>
#include <QThread>
#include <QVariantMap>

#ifdef Q_OS_UNIX
#include <unistd.h>
#endif

extern QAtomicInt _bootCloseFlag;

BootChecker::BootChecker(BootManager* manager)
    : m_manager(manager)
{
    // qRegisterMetaType<QSharedMemory*>("QSharedMemory*");
}

BootChecker::~BootChecker()
{
}

void BootChecker::run()
{
    initComponent();
    initClientMem();
    runChecking();
}

void BootChecker::dealClientCommand(const QString& command1, const QString& command2)
{
    QString arg1 = command1.trimmed().toLower();
    QString arg2 = command2.trimmed().toLower();
    if (arg2.isEmpty()) {
        if (arg1 == QStringLiteral("scan")) {
            QString printStr = "";
            QDir dir(m_cfgDir);
            QFileInfoList fileInfoList = dir.entryInfoList(QStringList() << "*.json");
            for (int i = 0; i < fileInfoList.length(); i++) {
                const QFileInfo& fileInfo = fileInfoList.at(i);
                printStr.append(fileInfo.filePath());
                if (i < fileInfoList.length() - 1) {
                    printStr.append(QStringLiteral("\n"));
                }
            }
            BootLog::printDebug(printStr, true, false);
            return;
        } else if (arg1 == QStringLiteral("list")) {
            setCfgFile("", CFG_LIST);
        } else if (arg1 == QStringLiteral("poweroff") || arg1 == QStringLiteral("shutdown")) {
            _bootCloseFlag = 1;
            startDestroy();
        } else if (arg1 == QStringLiteral("reboot") || arg1 == QStringLiteral("reset")) {
            _bootCloseFlag = 2;
            startDestroy();
        } else if (arg1 == QStringLiteral("stop") || arg1 == QStringLiteral("exit") || arg1 == QStringLiteral("close")) {
            _bootCloseFlag = 3;
            startDestroy();
        } else {
            BootLog::printCritical(QStringLiteral("The second parameter cannot be empty!"), true, false);
        }
    } else {
        if (arg2 == QStringLiteral("enable")) {
            setCfgFile(command1, CFG_ENABLE);
        } else if (arg2 == QStringLiteral("disable")) {
            setCfgFile(command1, CFG_DISABLE);
        } else if (arg2 == QStringLiteral("moveup")) {
            setCfgFile(command1, CFG_MOVEUP);
        } else if (arg2 == QStringLiteral("movedown")) {
            setCfgFile(command1, CFG_MOVEDOWN);
        } else if (arg2 == QStringLiteral("detail")) {
            setCfgFile(command1, CFG_DETAIL);
        } else {
            BootProcess* process = nullptr;
            for (BootProcess* e : qAsConst(m_manager->m_listProcess)) {
                if (e->jsonName() == command1
                    || e->baseName() == command1) {
                    process = e;
                    break;
                }
            }
            if (!process) {
                BootLog::printCritical(QStringLiteral("<%1> Can not find!").arg(command1), true, false);
                return;
            }
            if (arg2 == QStringLiteral("stop") || arg2 == QStringLiteral("exit") || arg2 == QStringLiteral("close")) {
                if (!process->hasExec()) {
                    BootLog::printCritical(QStringLiteral("<%1> Has not exec!").arg(command1), true, false);
                    return;
                }
                if (!process->isRunning()) {
                    BootLog::printCritical(QStringLiteral("<%1> Is inactivated!").arg(command1), true, false);
                    return;
                }
                BootLog::printDebug(QStringLiteral("<%1> Stopping...").arg(command1), true, false);
                QMetaObject::invokeMethod(process, "stop", Qt::QueuedConnection);
            } else if (arg2 == QStringLiteral("start") || arg2 == QStringLiteral("run") || arg2 == QStringLiteral("open")) {
                if (!process->hasExec()) {
                    BootLog::printCritical(QStringLiteral("<%1> Has not exec!").arg(command1), true, false);
                    return;
                }
                BootLog::printDebug(QStringLiteral("<%1> Starting...").arg(command1), true, false);
                QMetaObject::invokeMethod(process, "start", Qt::QueuedConnection);
            } else {
                if (!process->hasClientMem()) {
                    BootLog::printCritical(QStringLiteral("<%1> Has not share memory!").arg(command1), true, false);
                    return;
                }
                if (!process->isRunning()) {
                    BootLog::printCritical(QStringLiteral("<%1> Is inactivated!").arg(command1), true, false);
                    return;
                }
                if (process->hasClientMem()) {
                    QMetaObject::invokeMethod(process, "writeToClientMem", Qt::QueuedConnection, Q_ARG(QString, command2));
                } else {
                    BootLog::printCritical(QStringLiteral("Can not send message to ") + command1 + QStringLiteral(" !"), true, false);
                }
            }
        }
    }
}

void BootChecker::setCfgFile(const QString& name, const CfgCommand& cfgCommand)
{
    QDir dir(m_cfgDir);
    bool hasCom = false;
    QStringList componentList;
    const auto& infoList = dir.entryInfoList(QStringList() << QStringLiteral("*json"));
    for (const QFileInfo& fileInfo : infoList) {
        componentList.append(fileInfo.baseName());
        if (fileInfo.baseName() == name) {
            hasCom = true;
        }
    }
    if (cfgCommand != CFG_LIST && hasCom == false) {
        BootLog::printCritical(QStringLiteral("<%1> Can not find!").arg(name), true, false);
        return;
    }
    if (cfgCommand == CFG_DETAIL) {
        QFile jsonFile(QStringLiteral("%1/%2.json").arg(m_cfgDir, name));
        if (jsonFile.exists() == false) {
            BootLog::printCritical(QStringLiteral("<%1> Can not find!").arg(name), true, false);
            return;
        }
        if (jsonFile.open(QFile::ReadOnly | QFile::Text) == false) {
            BootLog::printCritical(QStringLiteral("<%1> Can not open!").arg(name), true, false);
            return;
        }
        QString jsonStr = jsonFile.readAll();
        BootLog::printDebug(QStringLiteral("\n%1\n").arg(jsonStr), true, false);
        jsonFile.close();
        return;
    }
    QFile cfgFile(m_cfgPath);
    if (!cfgFile.exists()) {
        BootLog::printCritical(QStringLiteral("%1 Not exits").arg(cfgFile.fileName()), true, false);
        return;
    }
    if (!cfgFile.open(QFile::ReadOnly | QFile::Text)) {
        BootLog::printCritical(QStringLiteral("%1 Read open error").arg(cfgFile.fileName()), true, false);
        return;
    }
    QString cfgReadStr = cfgFile.readAll();
    cfgFile.close();
    cfgReadStr.replace("\r\n", "\n");
    const QStringList& cfgReadList = cfgReadStr.split("\n");
    QStringList cfgCacheList;
    QStringList cfgWiteList;
    bool canmove = false;
    for (QString str : cfgReadList) {
        str = str.trimmed();
        if (str.isEmpty()) {
            continue;
        }
        if (!cfgCacheList.contains(str)) {
            cfgCacheList.append(str);
        }
        if (cfgCommand == CFG_MOVEUP || cfgCommand == CFG_MOVEDOWN) {
            if (str == name) {
                canmove = true;
            }
        }
    }
    if (cfgCommand == CFG_MOVEUP || cfgCommand == CFG_MOVEDOWN) {
        if (canmove == false) {
            BootLog::printCritical(QStringLiteral("<%1> Is not enabled!").arg(name), true, false);
            return;
        }
    }
    bool hasEnabled = false;
    bool hasZs = false;
    bool isMove = false;
    QString pstr;
    QString fstr;
    QString cstr;
    int cacheIndex = -1;
    for (const QString& str : cfgCacheList) {
        isMove = false;
        pstr = str;
        fstr = str;
        hasZs = false;
        if (str.startsWith("#")) {
            pstr = pstr.replace("#", "").trimmed();
            hasZs = true;
        }
        if (!componentList.contains(pstr)) {
            continue;
        }
        //
        if (cfgCommand == CFG_ENABLE) {
            if (pstr == name) {
                fstr = pstr;
                hasEnabled = true;
            }
        } else if (cfgCommand == CFG_DISABLE) {
            if (str == name && hasZs == false) {
                fstr = QStringLiteral("#%1").arg(str);
            }
        } else if (cfgCommand == CFG_MOVEUP) {
            if (str == name) {
                for (int i = cfgWiteList.length() - 1; i >= 0; i--) {
                    const QString& tstr = cfgWiteList.at(i);
                    if (tstr.startsWith("#")) {
                        continue;
                    }
                    cstr = name;
                    cacheIndex = i;
                    isMove = true;
                    break;
                }
            }
        } else if (cfgCommand == CFG_MOVEDOWN) {
            if (str == name) {
                for (int i = cfgWiteList.length(); i < cfgCacheList.length(); i++) {
                    const QString& tstr = cfgCacheList.at(i);
                    if (tstr.startsWith("#")) {
                        continue;
                    }
                    cstr = name;
                    cacheIndex = i + 1;
                    isMove = true;
                    break;
                }
            }
        }
        if (isMove == false) {
            cfgWiteList.append(fstr);
        }
    }
    if (!cstr.isEmpty()) {
        if (cacheIndex < 0) {
            cacheIndex = 0;
        }
        if (cacheIndex > cfgWiteList.length()) {
            cacheIndex = cfgWiteList.length();
        }
        cfgWiteList.insert(cacheIndex, cstr);
    }
    if (cfgCommand == CFG_ENABLE && hasEnabled == false) {
        cfgWiteList.append(name);
    }
    if (cfgWiteList != cfgReadList) {
        QFile::copy(m_cfgPath, QStringLiteral("%1.bak").arg(m_cfgPath));
    }
    const QString& cfgWriteStr = cfgWiteList.join("\n");
    //
    if (!cfgFile.open(QFile::WriteOnly | QFile::Text | QFile::Truncate)) {
        BootLog::printCritical(QStringLiteral("%1 Write open error").arg(cfgFile.fileName()), true, false);
        return;
    }
    cfgFile.write(cfgWriteStr.toUtf8());
    cfgFile.close();
#ifdef Q_OS_UNIX
    sync();
#endif
    //
    QString spStr1 = QStringLiteral("****************************************************");
    QString spStr2 = QStringLiteral("----------------------------------------------------");
    QString printStr = QStringLiteral("\n%1\n[Component]        [Enable] [Active] [Daemon] [Type]\n%2\n").arg(spStr1, spStr2);
    for (QString str : qAsConst(cfgWiteList)) {
        QString enbaleStr = QStringLiteral("true  ");
        QString activeStr = QStringLiteral("---   ");
        QString daemonStr = QStringLiteral("---   ");
        QString typeStr = QStringLiteral("---   ");
        if (str.startsWith("#")) {
            str.replace("#", "");
            enbaleStr = QStringLiteral("false ");
        }
        for (BootProcess* process : qAsConst(m_manager->m_listProcess)) {
            if (process->jsonName() == str) {
                if (process->isRunning() == true) {
                    activeStr = QStringLiteral("true  ");
                } else {
                    activeStr = QStringLiteral("false ");
                }
                if (process->isDaemon() == true) {
                    daemonStr = QStringLiteral("true  ");
                } else {
                    daemonStr = QStringLiteral("false ");
                }
                if (process->isDestroyType() == false) {
                    typeStr = QStringLiteral("normal");
                } else {
                    typeStr = QStringLiteral("delete");
                }
                break;
            }
        }
        for (BootProcess* process : qAsConst(m_manager->m_listDestroyProcess)) {
            if (process->jsonName() == str) {
                if (process->isDestroyType() == false) {
                    typeStr = QStringLiteral("normal");
                } else {
                    typeStr = QStringLiteral("delete");
                }
                break;
            }
        }
        QString pStr = str;
        int maxLength = 16;
        if (pStr.length() > maxLength) {
            pStr = pStr.left(maxLength) + QStringLiteral("..");
        } else {
            for (int i = str.length(); i < maxLength; i++) {
                pStr.append(QStringLiteral(" "));
            }
            pStr.append(QStringLiteral("  "));
        }
        printStr.append(QStringLiteral("%1 %2   %3   %4   %5\n").arg(pStr, enbaleStr, activeStr, daemonStr, typeStr));
    }
    printStr.append(spStr1);
    BootLog::printDebug(printStr, true, false);
}

void BootChecker::initComponent()
{
    QDir dir(QStringLiteral("/etc/bootmanager"));
    if (!dir.exists() || dir.isEmpty()) {
        dir.setPath(QStringLiteral("../etc/bootmanager"));
        if (!dir.exists() || dir.isEmpty()) {
            dir.setPath(QStringLiteral("../../etc/bootmanager"));
            if (!dir.exists() || dir.isEmpty()) {
                dir.setPath(QStringLiteral("./etc/bootmanager"));
                if (!dir.exists() || dir.isEmpty()) {
                    BootLog::printCritical(QStringLiteral("Can not find bootmanager root dir!"));
                    startDestroy();
                    return;
                }
            }
        }
    }
    //    if (dir.exists(PLATFORM_NAME)) {
    //        dir.cd(PLATFORM_NAME);
    //    } else if (dir.exists(QStringLiteral("common"))) {
    //        dir.cd(QStringLiteral("common"));
    //    } else {
    //        BootLog::printCritical(QStringLiteral("Can not find bootmanager target dir!"));
    //        startDestroy();
    //        return;
    //    }
    QFile cfgFile(dir.path() + QStringLiteral("/boot.cfg"));
    if (!cfgFile.exists()) {
        BootLog::printCritical(QStringLiteral("%1 not exits").arg(cfgFile.fileName()));
        startDestroy();
        return;
    }
    if (!cfgFile.open(QFile::ReadOnly | QFile::Text)) {
        BootLog::printCritical(QStringLiteral("%1 open error").arg(cfgFile.fileName()));
        startDestroy();
        return;
    }
    m_cfgDir = dir.absolutePath();
    m_cfgPath = cfgFile.fileName();
    QTextStream cfgStream(&cfgFile);
    QString line;
    QFile jsonFile;
    int index = 0;
    QString scriptsDir = m_cfgDir + "/scripts/";
#ifdef Q_OS_UNIX
    if (qEnvironmentVariableIsEmpty("PATH")) {
        qputenv("PATH", "/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin");
    }
    qputenv("PATH", QStringLiteral("%1:%2").arg(qgetenv("PATH"), scriptsDir).toLocal8Bit());
#endif
#ifdef Q_OS_WINDOWS
    qputenv("PATH", QStringLiteral("%1;%2").arg(qgetenv("PATH"), scriptsDir).toLocal8Bit());
#endif
    while (cfgStream.readLineInto(&line)) {
        if (isInterruptionRequested() == true) {
            break;
        }
        line = line.trimmed();
        if (line.isEmpty()) {
            continue;
        }
        if (line.startsWith(QStringLiteral("#"))) {
            continue;
        }
        if (jsonFile.isOpen()) {
            jsonFile.close();
        }
        jsonFile.setFileName(QStringLiteral("%1/%2.json").arg(dir.path(), line));
        if (!jsonFile.exists()) {
            BootLog::printCritical(QStringLiteral("<%1> Not exits!").arg(line));
            continue;
        }
        if (!jsonFile.open(QFile::ReadOnly | QFile::Text)) {
            BootLog::printCritical(QStringLiteral("<%1> Open error!").arg(line));
            continue;
        }
        QJsonDocument doc = QJsonDocument::fromJson(jsonFile.readAll());
        if (doc.isEmpty()) {
            BootLog::printCritical(QStringLiteral("<%1> Doc is empty!").arg(line));
            continue;
        }
        QVariantMap varMap = doc.toVariant().toMap();
        if (varMap.isEmpty()) {
            BootLog::printCritical(QStringLiteral("<%1> Var is empty!").arg(line));
            continue;
        }
        if (!varMap.contains(QStringLiteral("exePath"))) {
            BootLog::printCritical(QStringLiteral("<%1> Has not exec!").arg(line));
            continue;
        }
        BootProcess* process = new BootProcess(index, jsonFile.fileName(), varMap, 0);
        if (process->isDestroyType()) {
            process->moveToThread(qApp->thread());
            m_manager->m_listDestroyProcess.append(process);
        } else {
            process->prepare();
            process->moveToThread(qApp->thread());
            m_manager->m_listProcess.append(process);
            QMetaObject::invokeMethod(process, "init", Qt::QueuedConnection);
            process->waitCondition(true);
        }
        index++;
    }
    if (jsonFile.isOpen()) {
        jsonFile.close();
    }
    if (cfgFile.isOpen()) {
        cfgFile.close();
    }
    if (index <= 0) {
        BootLog::printCritical(QStringLiteral("Has not startup items!"));
        // startDestroy();
    }
}

void BootChecker::initClientMem()
{
#ifdef Q_OS_UNIX
    QSharedMemory removeMem;
    removeMem.setKey(BOOT_CTRLKEY_FSTR);
    if (removeMem.attach(QSharedMemory::ReadOnly) == true) {
        removeMem.detach();
    }
#endif
    m_manager->m_clientMem->setKey(BOOT_CTRLKEY_FSTR);
    if (m_manager->m_clientMem->create(BOOT_SIZE, QSharedMemory::ReadWrite) == false) {
        return;
    }
    if (BootCommon::writeMemory(m_manager->m_clientMem, BootCommon::UNKNOWN, QVariant(), true) == false) {
        BootLog::printCritical(QStringLiteral("Init Client Memory error!"));
        return;
    }
}

void BootChecker::runChecking()
{
    qDebug();
    BootLog::printWarning(QStringLiteral("Bootmanager Initialized."));
    qDebug();
    BootCommon::releaseSemaphore(BOOT_RUN_FSTR + BOOT_SEMA_FSTR);
    qint64 clientTime = 0;
    int clientType = 0;
    QVariant clientContent;
    qint64 lastClientTime = -1;
    int lastClientType = 0;
    QVariant lastClientContent;
    qint64 readTime;
    bool firstLoop = true;
    for (;;) {
        if (firstLoop == true) {
            firstLoop = false;
            for (BootProcess* process : qAsConst(m_manager->m_listProcess)) {
                if (!process) {
                    continue;
                }
                if (process->isRunning() == false) {
                    continue;
                }
                if (process->hasInit() == false) {
                    continue;
                }
                QMetaObject::invokeMethod(process, "initHeartbeatMem", Qt::QueuedConnection);
            }
        } else {
            BootCommon::waitSemaphore(BOOT_CTRLKEY_FSTR);
        }
        if (this->isInterruptionRequested() == true || _bootCloseFlag != 0) {
            QThread::yieldCurrentThread();
            break;
        }
        if (BootCommon::readMemory(m_manager->m_clientMem, &clientType, &clientContent, &clientTime) == true) {
            if (lastClientTime != clientTime || lastClientType != clientType || lastClientContent != clientContent) {
                QStringList commands = clientContent.toStringList();
                if (clientType == BootCommon::DOUBLE_COMMAND && commands.size() == 2) {
                    QString clientCommand1 = commands.at(0);
                    QString clientCommand2 = commands.at(1);
                    dealClientCommand(clientCommand1, clientCommand2);
                    if (this->isInterruptionRequested() == true || _bootCloseFlag != 0) {
                        QThread::yieldCurrentThread();
                        break;
                    }
                }
            }
        }
        lastClientTime = clientTime;
        lastClientType = clientType;
        lastClientContent = clientContent;
        for (BootProcess* process : qAsConst(m_manager->m_listProcess)) {
            if (!process) {
                continue;
            }
            if (process->isRunning() == false) {
                continue;
            }
            if (process->hasInit() == false) {
                continue;
            }
            const auto& shareMemList = process->getShareMemList();
            for (QSharedMemory* shareMem : shareMemList) {
                if (!shareMem) {
                    continue;
                }
                int type = 0;
                if (BootCommon::readMemory(shareMem, &type, nullptr, &readTime) == true) {
                    if (type == BootCommon::HEARDBEAT) {
                        process->dealHeartbeat(shareMem, readTime);
                    }
                }
            }
        }
    }
}

void BootChecker::startDestroy()
{
    for (BootProcess* process : qAsConst(m_manager->m_listProcess)) {
        if (!process) {
            continue;
        }
        process->destroyPrepare();
    }
    QMetaObject::invokeMethod(m_manager, "startDestroyWork", Qt::QueuedConnection);
}
