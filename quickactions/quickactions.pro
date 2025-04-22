TEMPLATE = aux

setting_entries.files = *.json
setting_entries.path = /usr/share/jolla-settings/entries

OTHER_FILES += $$setting_entries translations.js

INSTALLS += setting_entries
