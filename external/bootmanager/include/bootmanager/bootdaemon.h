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

#ifndef BOOT_DAEMON_H
#define BOOT_DAEMON_H

#if defined(BOOTDAEMON_LIBRARY_STATIC)
#define BOOTDAEMON_EXPORT
#else
#if (defined _WIN32 || defined _WIN64)
#if defined(BOOTDAEMON_LIBRARY)
#define BOOTDAEMON_EXPORT __declspec(dllexport)
#else
#define BOOTDAEMON_EXPORT __declspec(dllimport)
#endif
#else
#define BOOTDAEMON_EXPORT
#endif
#endif

#ifdef __cplusplus
extern "C" {
#endif

typedef void (*boot_daemon_callback_t)(const char* command, void* ptr);

BOOTDAEMON_EXPORT int boot_create_heartbeat(const char* name);
BOOTDAEMON_EXPORT int boot_send_heartbeat(const char* name);
BOOTDAEMON_EXPORT int boot_remove_heartbeat(const char* name);
BOOTDAEMON_EXPORT int boot_create_bootwatch(const char* name, boot_daemon_callback_t fun, void* ptr = 0);
#if defined(BOOTDAEMON_LIBRARY) || defined(QT_VERSION)
BOOTDAEMON_EXPORT int boot_create_bootwatch_inqtloop(const char* name, boot_daemon_callback_t fun, void* ptr = 0);
#endif
BOOTDAEMON_EXPORT int boot_remove_bootwatch(const char* shareMemAddress);
BOOTDAEMON_EXPORT int boot_unlock(const char* name);

#ifdef __cplusplus
}
#endif

#endif // BOOT_DAEMON_H
