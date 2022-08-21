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

#include "clusterimageprovider.h"
#include <QCryptographicHash>
#include <QDataStream>
#include <QDir>
#include <QFile>
#include <QImage>
#include <QMutexLocker>
#include <QQuickTextureFactory>
#include <QQuickWindow>
#include <QStandardPaths>
#include <QThread>
#include <QWaitCondition>

#define IMAGE_PROVIDER_DIRNAME QStringLiteral("imagecache")
#define IMAGE_PROVIDER_SUFFIX QStringLiteral(".imgc")
#define IMAGE_PROVIDER_BEGINSTR QStringLiteral("cluster-image-cache-begin")
#define IMAGE_PROVIDER_ENDSTR QStringLiteral("cluster-image-cache-end")
#define IMAGE_PROVIDER_VERSION QStringLiteral("1.0")
#define IMAGE_PROVIDER_LIMIT_SIZE 1024 * 64
#define IMAGE_PROVIDER_LIMIT_TIME 1000 * 1000 * 2 // ns

namespace ClusterImageSerialize {

static inline bool setBegin(QDataStream& stream)
{
    stream << IMAGE_PROVIDER_BEGINSTR;
    stream << IMAGE_PROVIDER_VERSION;
    return stream.status() == QDataStream::Ok;
}
static inline bool checkBegin(QDataStream& stream)
{
    QString beginStr;
    stream >> beginStr;
    if (beginStr != IMAGE_PROVIDER_BEGINSTR) {
        stream.setStatus(QDataStream::ReadCorruptData);
        return false;
    }
    QString versionStr;
    stream >> versionStr;
    if ((int)versionStr.toFloat() != (int)IMAGE_PROVIDER_VERSION.toFloat()) {
        stream.setStatus(QDataStream::ReadCorruptData);
        return false;
    }
    return stream.status() == QDataStream::Ok;
}
static inline bool setEnd(QDataStream& stream)
{
    stream << IMAGE_PROVIDER_ENDSTR;
    return stream.status() == QDataStream::Ok;
}
static inline bool checkEnd(QDataStream& stream)
{
    QString endStr;
    stream >> endStr;
    if (endStr != IMAGE_PROVIDER_ENDSTR) {
        return false;
    }
    return stream.status() == QDataStream::Ok;
}
static inline bool setImage(QDataStream& stream, const QImage& image)
{
    stream << (quint32)image.width();
    stream << (quint32)image.height();
    stream << (quint32)image.format();
    stream << (quint64)image.sizeInBytes();
    if (stream.status() != QDataStream::Ok) {
        return false;
    }
    int reval = stream.writeRawData((char*)image.bits(), image.sizeInBytes());
    if (reval < 0) {
        return false;
    }
    return stream.status() == QDataStream::Ok;
}
static inline bool getImage(QDataStream& stream, QImage& image)
{
    quint32 width = 0;
    quint32 height = 0;
    quint32 format = 0;
    quint64 sizeInBytes = 0;
    stream >> width;
    stream >> height;
    stream >> format;
    stream >> sizeInBytes;
    if (stream.status() != QDataStream::Ok) {
        return false;
    }
    if (width <= 0 || height <= 0 || format <= QImage::Format_Invalid || sizeInBytes <= 0) {
        return false;
    }
    image = QImage(width, height, (QImage::Format)format);
    if (image.sizeInBytes() != sizeInBytes) {
        return false;
    }
    int reval = stream.readRawData((char*)image.bits(), sizeInBytes);
    if (reval < 0) {
        return false;
    }
    return stream.status() == QDataStream::Ok;
}

}

class ClusterImageWorkThread : public QThread {
    Q_OBJECT
    using QThread::QThread;

protected:
    virtual void run() override
    {
        readAll();
        exec();
    }

public slots:
    void save(const QString& id, const QImage& image)
    {
        if (_idToImage.empty() && !_hasSave) {
            qDebug() << qUtf8Printable(QStringLiteral("ImageSaveThread cache image..."));
        }
        if (!_targetDir.exists()) {
            _targetDir.mkpath(_targetDir.path());
        }
        QFile file(_targetDir.path() + QStringLiteral("/") + getHexName(id) + IMAGE_PROVIDER_SUFFIX);
        QDataStream stream(&file);
        if (!file.open(QIODevice::WriteOnly)) {
            qWarning() << qUtf8Printable(QStringLiteral("ImageSaveThread save error (can not open)"));
            return;
        }
        if (!ClusterImageSerialize::setBegin(stream)) {
            qWarning() << qUtf8Printable(QStringLiteral("ImageSaveThread save error (invalid info-begin)"));
            file.close();
            file.remove();
            return;
        }
        if (!ClusterImageSerialize::setImage(stream, image)) {
            qWarning() << qUtf8Printable(QStringLiteral("ImageSaveThread save error (invalid image)"));
            file.close();
            file.remove();
            return;
        }
        if (!ClusterImageSerialize::setEnd(stream)) {
            qWarning() << qUtf8Printable(QStringLiteral("ImageSaveThread save error (invalid info-end)"));
            file.close();
            file.remove();
            return;
        }
        file.close();
        _hasSave = true;
    }
    void readAll()
    {
        const auto& fileList = _targetDir.entryInfoList(QStringList() << (QStringLiteral("*") + IMAGE_PROVIDER_SUFFIX), QDir::Files);
        for (const auto& fileInfo : fileList) {
            const QString& hex = fileInfo.baseName();
            if (hex.isEmpty()) {
                continue;
            }
            QFile file(_targetDir.path() + QStringLiteral("/") + hex + IMAGE_PROVIDER_SUFFIX);
            QDataStream stream(&file);
            QImage image;
            if (!file.open(QIODevice::ReadOnly)) {
                qWarning() << qUtf8Printable(QStringLiteral("ImageSaveThread read error (can not open)"));
                continue;
            }
            if (!ClusterImageSerialize::checkBegin(stream)) {
                qWarning() << qUtf8Printable(QStringLiteral("ImageSaveThread read error (invalid info-begin)"));
                file.close();
                file.remove();
                continue;
            }
            if (!ClusterImageSerialize::getImage(stream, image)) {
                qWarning() << qUtf8Printable(QStringLiteral("ImageSaveThread read error (invalid image)"));
                file.close();
                file.remove();
                continue;
            }
            if (!ClusterImageSerialize::checkEnd(stream)) {
                qWarning() << qUtf8Printable(QStringLiteral("ImageSaveThread read error (invalid info-end)"));
                file.close();
                file.remove();
                continue;
            }
            file.close();
            _idToImage.insert(hex, image);
            _hasCache = true;
        }
        _hasRead = true;
        _readCondition.wakeAll();
    }

public:
    inline QString getHexName(const QString& id) const
    {
        return QCryptographicHash::hash(id.toUtf8(), QCryptographicHash::Sha1).toHex();
    }
    inline bool hasCache() const
    {
        return _hasCache;
    }
    inline void waitForRead()
    {
        if (_hasRead) {
            return;
        }
        QMutexLocker locker(&_readMutex);
        (void)locker;
        _readCondition.wait(&_readMutex);
    }
    inline bool getImage(const QString& id, QImage* image) const
    {
        if (!image) {
            return false;
        }
        auto it = _idToImage.find(getHexName(id));
        if (it == _idToImage.end()) {
            return false;
        }
        *image = *it;
        return true;
    }

public:
    QWaitCondition _readCondition;
    QMutex _readMutex;
    QMap<QString, QImage> _idToImage;
    bool _hasCache = false;
    bool _hasRead = false;
    bool _hasSave = false;
    QDir _targetDir = QStandardPaths::writableLocation(QStandardPaths::CacheLocation) + QStringLiteral("/") + IMAGE_PROVIDER_DIRNAME;
};

class ImageTextureFactory : public QQuickTextureFactory {
public:
    ImageTextureFactory(const QImage& image, const QSize& size)
        : _image(image)
        , _size(size)
    {
    }

protected:
    virtual QSGTexture* createTexture(QQuickWindow* window) const override
    {
        return window->createTextureFromImage(_image, QQuickWindow::TextureCanUseAtlas);
    }
    virtual QSize textureSize() const override
    {
        return _size;
    }
    virtual int textureByteCount() const override
    {
        return _size.width() * _size.height() * 4;
    }
    virtual QImage image() const override
    {
        return _image;
    }

public:
    QImage _image;
    QSize _size;
};

ClusterImageProvider::ClusterImageProvider()
    : QQuickImageProvider(QQmlImageProviderBase::Texture)
    , m_workThread(new ClusterImageWorkThread)
{
    m_workThread->start();
}

ClusterImageProvider::~ClusterImageProvider()
{
    m_workThread->requestInterruption();
    m_workThread->quit();
    m_workThread->wait();
    delete m_workThread;
}

QQuickTextureFactory* ClusterImageProvider::requestTexture(const QString& id, QSize* size, const QSize& requestedSize)
{
    m_workThread->waitForRead();
    QImage image;
    QSize imageSize;
    if (!m_workThread->getImage(id, &image)) {
        QString path;
        if (id.startsWith(QStringLiteral("qrc:/"))) {
            path = QStringLiteral(":") + QUrl(id).path();
        } else if (id.startsWith(QStringLiteral("file:/"))) {
            path = QUrl(id).toLocalFile();
        } else if (id.startsWith(QStringLiteral(":/"))) {
            path = id;
        } else {
            qWarning() << QStringLiteral("ImageImageProvider: invaild path(%1)").arg(id);
            return nullptr;
        }
        QElapsedTimer timer;
        timer.start();
        bool ok = image.load(path);
        qint64 loadTime = timer.nsecsElapsed();
        if (!ok) {
            qWarning() << QStringLiteral("ImageImageProvider: invaild image(%1)").arg(id);
            return nullptr;
        }
        if (image.format() != QImage::Format_ARGB32_Premultiplied && image.format() != QImage::Format_RGB32) {
            image = image.convertToFormat(QImage::Format_ARGB32_Premultiplied);
        }
        if (requestedSize.isValid()) {
            image = image.scaled(requestedSize, Qt::IgnoreAspectRatio, Qt::SmoothTransformation);
        }
        bool needSave = true;
        if (image.sizeInBytes() < IMAGE_PROVIDER_LIMIT_SIZE) {
            needSave = false;
        } else if (loadTime < IMAGE_PROVIDER_LIMIT_TIME) {
            needSave = false;
        }
        if (needSave) {
            QMetaObject::invokeMethod(m_workThread, "save", Qt::QueuedConnection, Q_ARG(QString, id), Q_ARG(QImage, image));
        }
    }
    *size = image.size();
    return new ImageTextureFactory(image, *size);
}

#include "clusterimageprovider.moc"
