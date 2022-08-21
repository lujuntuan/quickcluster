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

#ifndef CLUSTER_SINGLETON_H
#define CLUSTER_SINGLETON_H

template <typename T>
class ClusterSingleton {
public:
    static T* getInstance()
    {
        return m_instance;
    }
    static void setInstance(T* instance)
    {
        m_instance = instance;
    }

private:
    static T* m_instance;
};

template <typename T>
T* ClusterSingleton<T>::m_instance = nullptr;

#endif // CLUSTER_SINGLETON_H
