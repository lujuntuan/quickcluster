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

#ifndef CLUSTER_IMAGEPROVIDER_H
#define CLUSTER_IMAGEPROVIDER_H

#include <QQuickImageProvider>

class ClusterImageProvider : public QQuickImageProvider {
public:
    ClusterImageProvider();
    ~ClusterImageProvider();
    static inline QString getPrefixName()
    {
        return QStringLiteral("ClusterImage");
    }

protected:
    virtual QQuickTextureFactory* requestTexture(const QString& id, QSize* size, const QSize& requestedSize) override;

private:
    class ClusterImageWorkThread* m_workThread = nullptr;
};

#endif // CLUSTER_IMAGEPROVIDER_H
