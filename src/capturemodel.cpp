#include "capturemodel.h"

#include <QDebug>
#include <QFile>
#include <QUrl>

CaptureModel::CaptureModel(QObject *parent)
    : QAbstractListModel(parent)
    , m_fileUrl(QUrl::fromLocalFile(QLatin1String("/")))
    , m_count(0)
{
}

CaptureModel::~CaptureModel()
{
}

QObject *CaptureModel::source() const
{
    return m_model.data();
}

void CaptureModel::setSource(QObject *source)
{
    if (m_model.data() != source) {
        const int count = m_count + m_captures.count();

        if (m_count > 0) {
            beginRemoveRows(QModelIndex(), m_captures.count(), m_captures.count() + m_count - 1);
        }

        if (m_model) {
            disconnect(m_model.data(), &QAbstractItemModel::rowsRemoved,
                    this, &CaptureModel::_q_rowsRemoved);
            disconnect(m_model.data(), &QAbstractItemModel::rowsInserted,
                    this, &CaptureModel::_q_rowsInserted);
            disconnect(m_model.data(), &QAbstractItemModel::dataChanged,
                    this, &CaptureModel::_q_dataChanged);
            m_model = 0;
        }

        if (m_count > 0) {
            m_count = 0;
            endRemoveRows();
        }

        if (QAbstractItemModel *model = qobject_cast<QAbstractItemModel *>(source)) {
            int count = model ? model->rowCount() : 0;
            if (count > 0) {
                beginInsertRows(QModelIndex(), m_captures.count(), m_captures.count() + count - 1);

                const QHash<int, QByteArray> roleNames = model->roleNames();
                m_roles[Url] = roleNames.key("url");
                m_roles[Title] = roleNames.key("title");
                m_roles[MimeType] = roleNames.key("mimeType");
                m_roles[Orientation] = roleNames.key("orientation");
                m_roles[Duration] = roleNames.key("duration");
            }

            m_model = model;
            m_count = count;

            connect(m_model.data(), &QAbstractItemModel::rowsRemoved,
                    this, &CaptureModel::_q_rowsRemoved);
            connect(m_model.data(), &QAbstractItemModel::rowsInserted,
                    this, &CaptureModel::_q_rowsInserted);
            connect(m_model.data(), &QAbstractItemModel::dataChanged,
                    this, &CaptureModel::_q_dataChanged);

            if (count > 0) {
                endInsertRows();
            }
        }

        if (count != m_count + m_captures.count()) {
            emit countChanged();
        }
    }
}

void CaptureModel::deleteFile(int index)
{
    QUrl url;
    if (index < 0) {
    } else if (index < m_captures.count()) {
        url = m_captures.at(index).url;
        beginRemoveRows(QModelIndex(), index, index);
        m_captures.remove(index);
        endRemoveRows();
    } else if (index < m_captures.count() + m_count) {
        index -= m_captures.count();
        url = m_model->index(index, 0).data(m_roles[Url]).toUrl();
    }

    if (url.isLocalFile()) {
        QFile::remove(url.toLocalFile());
    }
}

QHash<int, QByteArray> CaptureModel::roleNames() const
{
    QHash<int, QByteArray> roleNames;
    roleNames.insert(Url, "url");
    roleNames.insert(Title, "title");
    roleNames.insert(MimeType, "mimeType");
    roleNames.insert(Orientation, "orientation");
    roleNames.insert(Duration, "duration");
    return roleNames;
}

QModelIndex CaptureModel::index(int row, int column, const QModelIndex &parent) const
{
    return !parent.isValid() && row >= 0 && row < m_count + m_captures.count() && column == 0
                ? createIndex(row, column)
                : QModelIndex();
}

int CaptureModel::rowCount(const QModelIndex &parent) const
{
    return !parent.isValid() ? m_count + m_captures.count() : 0;
}

QVariant CaptureModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid()) {
        return QVariant();
    } else if (index.row() < m_captures.count()) {
        const Capture &capture = m_captures.at(index.row());
        if (role == Url) {
            return capture.url;
        } else if (role == Title) {
            return QString();
        } else if (role == MimeType) {
            return capture.mimeType;
        } else if (role == Orientation){
            return capture.orientation;
        } else if (role == Duration) {
            return capture.duration;
        } else {
            return QVariant();
        }
    } else if (role >= 0 && role < RoleCount) {
        return m_model ? m_model->index(index.row() - m_captures.count(), 0).data(m_roles[role]) : QVariant();
    } else {
        return QVariant();
    }
}

void CaptureModel::_q_rowsRemoved(const QModelIndex &parent, int begin, int end)
{
    if (!parent.isValid()) {
        beginRemoveRows(QModelIndex(), m_captures.count() + begin, m_captures.count() + end);
        m_count -= end - begin + 1;
        endRemoveRows();

        emit countChanged();
    }
}

void CaptureModel::_q_rowsInserted(const QModelIndex &parent, int begin, int end)
{
    if (parent.isValid()) {
        return;
    }

    if (m_count == 0) {
        const QHash<int, QByteArray> roleNames = m_model->roleNames();
        m_roles[Url] = roleNames.key("url");
        m_roles[Title] = roleNames.key("title");
        m_roles[MimeType] = roleNames.key("mimeType");
        m_roles[Orientation] = roleNames.key("orientation");
        m_roles[Duration] = roleNames.key("duration");
    }

    const int count = m_count + m_captures.count();

    for (int i = begin; i <= end; ++i) {
        const QUrl url = m_model->index(i, 0).data(m_roles[Url]).toUrl();
        for (int from = 0; from < m_captures.count(); ++from) {
            if (m_captures.at(from).url != url) {
                continue;
            }

            int to = m_captures.count() + i;
            if (begin < i) {
                beginInsertRows(QModelIndex(), m_captures.count() + begin, to - 1);
                m_count += i - begin;
                endInsertRows();
            }

            begin = i + 1;

            const bool moved = beginMoveRows(QModelIndex(), from, from, QModelIndex(), to);

            if (to >= m_captures.count())
                to -= 1;

            m_captures.remove(from--);
            m_count += 1;
            if (moved) {
                endMoveRows();
            }
            emit dataChanged(createIndex(to, to), createIndex(to, to));
        }
    }

    if (begin <= end) {
        beginInsertRows(QModelIndex(), begin + m_captures.count(), end + m_captures.count());
        m_count += end - begin + 1;
        endInsertRows();
    }

    if (count != m_count + m_captures.count()) {
        emit countChanged();
    }
}

void CaptureModel::_q_dataChanged(
            const QModelIndex &topLeft, const QModelIndex &bottomRight, const QVector<int> &roles)
{
    if (!topLeft.parent().isValid() && topLeft.column() == 0) {
        emit dataChanged(
                    createIndex(topLeft.row() + m_captures.count(), 0),
                    createIndex(bottomRight.row() + m_captures.count(), 0), roles);
    }
}

void CaptureModel::prependCapture(
        const QUrl &url, const QString &mimeType, int orientation, qint64 duration)
{
    QUrl resolvedUrl = m_fileUrl.resolved(url);

    // This is almost guaranteed to never happen but it possible an item could be indexed before
    // we prepend, so perform a quick check of the most recent items for duplicates.
    int existingCount = qMin(10, m_model ? m_model->rowCount() : 0);
    for (int i = 0; i < existingCount; ++i) {
        if (m_model->index(i, 0).data(m_roles[Url]).toUrl() == resolvedUrl) {
            return;
        }
    }
    beginInsertRows(QModelIndex(), 0, 0);
    Capture capture = { resolvedUrl, mimeType, orientation, duration };
    m_captures.prepend(capture);
    endInsertRows();

    emit countChanged();
}
