import QtQuick 2.0
import QtTest 1.0
import Sailfish.Silica 1.0
import com.jolla.camera 1.0

Item {
    id: main

    width: 540
    height: 960

    CaptureModel {
        id: captureModel

        source: ListModel {
            id: sourceModel
            ListElement { url: "file:///pictures/image_03.jpg"; title: "image3"; mimeType: "image/jpeg"; orientation: 270 }
            ListElement { url: "file:///videos/movie_02.jpg"; title: "movie2"; mimeType: "video/mpeg"; orientation: 180 }
            ListElement { url: "file:///pictures/image_01.jpg"; title: "image1"; mimeType: "image/jpeg"; orientation: 0 }

        }
    }

    VisualDataModel {
        id: visualModel

        model: captureModel
        delegate: Item {
            property url url: model.url
            property string title: model.title
            property string mimeType: model.mimeType
            property int orientation: model.orientation
        }
    }

    TestCase {

        function test_prepend() {
            var item

            compare(visualModel.items.count, 3)

            item = visualModel.items.get(0)
            compare(item.model.url, "file:///pictures/image_03.jpg")
            compare(item.model.title, "image3")
            compare(item.model.mimeType, "image/jpeg")
            compare(item.model.orientation, 270)

            item = visualModel.items.get(1)
            compare(item.model.url, "file:///videos/movie_02.jpg")
            compare(item.model.title, "movie2")
            compare(item.model.mimeType, "video/mpeg")
            compare(item.model.orientation, 180)

            item = visualModel.items.get(2)
            compare(item.model.url, "file:///pictures/image_01.jpg")
            compare(item.model.title, "image1")
            compare(item.model.mimeType, "image/jpeg")
            compare(item.model.orientation, 0)

            captureModel.prependCapture("file:///pictures/image_04.jpg", "image/jpeg", 0)
            captureModel.prependCapture("file:///videos/movie_05.jpg", "video/mpeg", 0)
            captureModel.prependCapture("file:///pictures/image_06.jpg", "image/jpeg", 0)
            compare(visualModel.items.count, 6)

            item = visualModel.items.get(0)
            compare(item.model.url, "file:///pictures/image_06.jpg")
            compare(item.model.title, "")
            compare(item.model.mimeType, "image/jpeg")
            compare(item.model.orientation, 0)

            item = visualModel.items.get(1)
            compare(item.model.url, "file:///videos/movie_05.jpg")
            compare(item.model.title, "")
            compare(item.model.mimeType, "video/mpeg")
            compare(item.model.orientation, 0)

            item = visualModel.items.get(2)
            compare(item.model.url, "file:///pictures/image_04.jpg")
            compare(item.model.title, "")
            compare(item.model.mimeType, "image/jpeg")
            compare(item.model.orientation, 0)

            item = visualModel.items.get(3)
            compare(item.model.url, "file:///pictures/image_03.jpg")
            compare(item.model.title, "image3")
            compare(item.model.mimeType, "image/jpeg")
            compare(item.model.orientation, 270)

            compare(visualModel.items.get(0).model.url, "file:///pictures/image_06.jpg")
            compare(visualModel.items.get(1).model.url, "file:///videos/movie_05.jpg")
            compare(visualModel.items.get(2).model.url, "file:///pictures/image_04.jpg")
            compare(visualModel.items.get(3).model.url, "file:///pictures/image_03.jpg")
            compare(visualModel.items.get(4).model.url, "file:///videos/movie_02.jpg")
            compare(visualModel.items.get(5).model.url, "file:///pictures/image_01.jpg")

            sourceModel.insert(1, { url: "file:///videos/movie_05.jpg", title: "movie5", mimeType: "video/mpeg", orientation: 90 })
            sourceModel.insert(0, { url: "file:///pictures/image_07.jpg", title: "image7", mimeType: "image/jpeg", orientation: 90 })
            sourceModel.insert(0, { url: "file:///pictures/image_04.jpg", title: "image4", mimeType: "image/jpeg", orientation: 90 })
            sourceModel.insert(0, { url: "file:///pictures/image_06.jpg", title: "image6", mimeType: "image/jpeg", orientation: 90 })

            compare(visualModel.items.count, 7)

            compare(visualModel.items.get(0).model.url, "file:///pictures/image_06.jpg")
            compare(visualModel.items.get(1).model.url, "file:///pictures/image_04.jpg")
            compare(visualModel.items.get(2).model.url, "file:///pictures/image_07.jpg")
            compare(visualModel.items.get(3).model.url, "file:///pictures/image_03.jpg")
            compare(visualModel.items.get(4).model.url, "file:///videos/movie_05.jpg")
            compare(visualModel.items.get(5).model.url, "file:///videos/movie_02.jpg")
            compare(visualModel.items.get(6).model.url, "file:///pictures/image_01.jpg")
        }
    }
}
