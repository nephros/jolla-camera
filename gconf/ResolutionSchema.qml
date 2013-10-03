import QtQuick 2.0
import com.jolla.gconf.schema 1.0


GConfSchema {
    owner: "jolla"

    property alias image: imageSchema.defaultValue
    property alias video: videoSchema.defaultValue
    property alias viewfinder: viewfinderSchema.defaultValue

    GConfSchema {
        id: imageSchema
        path: "image"
        owner: "jolla"
        type: GConfSchema.Pair
        carType: GConfSchema.Float
        cdrType: GConfSchema.Float
        GConfDescription { locale: "C" }
    }

    GConfSchema {
        id: videoSchema
        path: "video"
        owner: "jolla"
        type: GConfSchema.Pair
        carType: GConfSchema.Float
        cdrType: GConfSchema.Float
        GConfDescription { locale: "C" }
    }

    GConfSchema {
        id: viewfinderSchema
        path: "viewfinder"
        owner: "jolla"
        type: GConfSchema.Pair
        carType: GConfSchema.Float
        cdrType: GConfSchema.Float
        GConfDescription { locale: "C" }
    }
}
