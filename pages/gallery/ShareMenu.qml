import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Ambience 1.0
import Sailfish.TransferEngine 1.0
import com.jolla.settings.accounts 1.0

ShareMethodList {
    id: menuList

    property bool isImage
    property string title

    property Item page

    signal deleteFile

    //% "Share"
    listHeader: qsTrId("camera-la-share")

    PullDownMenu {
        id: pullDownMenu
        MenuItem {
            //% "Details"
            text: qsTrId("camera-me-details")
            visible: false  // JB#7882
        }

        MenuItem {
            //% "Delete"
            text: qsTrId("camera-me-delete")
            onClicked: menuList.deleteFile()
        }

        MenuItem {
            //% "Create ambience"
            text: qsTrId("camera-me-create_ambience")

            visible: menuList.isImage
            onClicked: Ambience.source = menuList.url
        }
    }

    header: Label {
        text: menuList.title

        x: menuList.width * 0.3
        width: menuList.width * 0.7
        height: Theme.itemSizeLarge
        truncationMode: TruncationMode.Fade
        color: Theme.highlightColor
        horizontalAlignment: Text.AlignRight
        verticalAlignment: Text.AlignVCenter
        font {
            pixelSize: Theme.fontSizeLarge
            family: Theme.fontFamilyHeading
        }
    }

    // Add "add account" to the footer. User must be able to
    // create accounts in a case there are none.
    footer: BackgroundItem {
        Label {
            //% "Add account"
            text: qsTrId("camera-la-add_account")
            x: Theme.paddingLarge
            anchors.verticalCenter: parent.verticalCenter
            color: highlighted ? Theme.highlightColor : Theme.primaryColor
        }

        onClicked: {
            jolla_signon_ui_service.inProcessParent = menuList.page
            menuList.page.pageStack.push(accountsPage)
        }
    }

    Component {
        id: accountsPage
        AccountsPage { }
    }
}
