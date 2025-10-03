# SPDX-FileCopyrightText: 2025 Jolla Mobile Ltd
#
# SPDX-License-Identifier: BSD-3-Clause

TEMPLATE = aux

setting_entries.files = *.json
setting_entries.path = /usr/share/jolla-settings/entries

OTHER_FILES += $$setting_entries translations.js

INSTALLS += setting_entries
