// SPDX-FileCopyrightText: 2013 Jolla Ltd.
// SPDX-FileCopyrightText: 2025 Jolla Mobile Ltd
//
// SPDX-License-Identifier: BSD-3-Clause

.pragma library

function findItem(item, isItem) {
    if (isItem(item))
        return item
    for (var i = 0; i < item.children.length; ++i) {
        var child = findItem(item.children[i], isItem)
        if (child !== undefined)
            return child
    }
}

function findItemByName(item, name) {
    return findItem(item, function (item) { return item.objectName == name })
}
