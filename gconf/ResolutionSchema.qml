import QtQuick 2.0
import com.jolla.gconf.schema 1.0

GConfSchema {
    id: imageSchema
    path: "image"
    owner: "jolla"
    type: GConfSchema.Pair
    carType: GConfSchema.Float
    cdrType: GConfSchema.Float
    GConfDescription { locale: "C" }
}
