#include "capturemodel.h"

#include <QDebug>
#include <QUrl>

CaptureModel::CaptureModel(QObject *parent)
    : QAbstractListModel(parent)
    , m_fileUrl(QUrl::fromLocalFile(QLatin1String("/")))
    , m_urlRole(-1)
    , m_titleRole(-1)
    , m_mimeTypeRole(-1)
    , m_orientationRole(-1)
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
                m_urlRole = roleNames.key("url");
                m_titleRole = roleNames.key("title");
                m_mimeTypeRole = roleNames.key("mimeType");
                m_orientationRole = roleNames.key("orientation");
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
    }
}

QHash<int, QByteArray> CaptureModel::roleNames() const
{
    QHash<int, QByteArray> roleNames;
    if (m_model) {
        roleNames = m_model->roleNames();
    }
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
        if (role == m_urlRole) {
            return capture.url;
        } else if (role == m_titleRole) {
            return QString();
        } else if (role == m_mimeTypeRole) {
            return capture.mimeType;
        } else if (role == m_orientationRole){
            return capture.orientation;
        } else {
            return QVariant();
        }
    } else {
        return m_model ? m_model->index(index.row() - m_captures.count(), 0).data(role) : QVariant();

    }
}

void CaptureModel::_q_rowsRemoved(const QModelIndex &parent, int begin, int end)
{
    if (!parent.isValid()) {
        beginRemoveRows(QModelIndex(), begin, end);
        m_count -= end - begin + 1;
        endRemoveRows();
    }
}

void CaptureModel::_q_rowsInserted(const QModelIndex &parent, int begin, int end)
{
    if (parent.isValid()) {
        return;
    }

    if (m_count == 0) {
        const QHash<int, QByteArray> roleNames = m_model->roleNames();
        m_urlRole = roleNames.key("url");
        m_titleRole = roleNames.key("title");
        m_mimeTypeRole = roleNames.key("mimeType");
        m_orientationRole = roleNames.key("orientation");
    }

    for (int i = begin; i <= end; ++i) {
        const QUrl url = m_model->index(i, 0).data(m_urlRole).toUrl();
        for (int from = 0; from < m_captures.count(); ++from) {
            if (m_captures.at(from).url != url) {
                continue;
            }

            const int to = m_captures.count() + i;
            if (begin < i) {
                beginInsertRows(QModelIndex(), m_captures.count() + begin, to - 1);
                m_count += i - begin;
                endInsertRows();
            }

            begin = i + 1;

            const bool moved = beginMoveRows(QModelIndex(), from, from, QModelIndex(), to);

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

void CaptureModel::prependCapture(const QUrl &url, const QString &mimeType, int orientation)
{
    QUrl resolvedUrl = m_fileUrl.resolved(url);

    // This is almost guaranteed to never happen but it possible an item could be indexed before
    // we prepend, so perform a quick check of the most recent items for duplicates.
    int existingCount = qMin(10, m_model ? m_model->rowCount() : 0);
    for (int i = 0; i < existingCount; ++i) {
        if (m_model->index(i, 0).data(m_urlRole).toUrl() == resolvedUrl) {
            return;
        }
    }
    beginInsertRows(QModelIndex(), 0, 0);
    Capture capture = { resolvedUrl, mimeType, orientation };
    m_captures.prepend(capture);
    endInsertRows();
}
