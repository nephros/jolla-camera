#ifndef AMBIENCEINSTALLMODEL_H
#define AMBIENCEINSTALLMODEL_H

#include <QAbstractItemModel>
#include <QPointer>
#include <QUrl>

class CaptureModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(QObject *source READ source WRITE setSource NOTIFY sourceChanged)
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)
public:
    enum {
        Url,
        Title,
        MimeType,
        Orientation,
        RoleCount
    };

    CaptureModel(QObject *parent = 0);
    ~CaptureModel();

    QObject *source() const;
    void setSource(QObject *source);

    QHash<int, QByteArray> roleNames() const;
    QModelIndex index(int row, int column, const QModelIndex &parent) const;
    int rowCount(const QModelIndex &parent = QModelIndex()) const;
    QVariant data(const QModelIndex &index, int role) const;

public slots:
    void prependCapture(const QUrl &url, const QString &mimeType, int orientation);

signals:
    void sourceChanged();
    void countChanged();

private slots:
    void _q_rowsRemoved(const QModelIndex &parent, int begin, int end);
    void _q_rowsInserted(const QModelIndex &parent, int begin, int end);
    void _q_dataChanged(const QModelIndex &topLeft, const QModelIndex &bottomRight, const QVector<int> &roles);

private:
    struct Capture {
        QUrl url;
        QString mimeType;
        int orientation;
    };
    QVector<Capture> m_captures;
    QPointer<QAbstractItemModel> m_model;
    const QUrl m_fileUrl;
    int m_count;
    int m_roles[RoleCount];
};

#endif
