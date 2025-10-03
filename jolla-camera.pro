# SPDX-FileCopyrightText: 2013 - 2017 Jolla Ltd.
# SPDX-FileCopyrightText: 2024 - 2025 Jolla Mobile Ltd
#
# SPDX-License-Identifier: BSD-3-Clause

TEMPLATE = subdirs

SUBDIRS = \
        application.pro \
        lockscreen \
        quickactions \
        src \
        settings \
        translations \
        tests

OTHER_FILES = rpm/*.spec
