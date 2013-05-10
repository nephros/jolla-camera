import QtQuick 1.1
import Sailfish.Silica 1.0
import Sailfish.TransferEngine 1.0
import com.jolla.components.accounts 1.0

ShareMethodList {
    id: menuList

    property bool isImage
    property string title

    property Item page

    //% "Share"
    listHeader: qsTrId("camera-la-share")

    PullDownMenu {
        id: pullDownMenu
        MenuItem {
            //% "Details"
            text: qsTrId("camera-me-details")
        }

        MenuItem {
            //% "Delete"
            text: qsTrId("camera-me-delete")
        }

        MenuItem {
            //% "Create ambience"
            text: qsTrId("camera-me-create_ambience")

            visible: menuList.isImage
        }
    }

    header: Label {
        text: menuList.title

        x: menuList.width * 0.3
        width: menuList.width * 0.7
        height: theme.itemSizeLarge
        truncationMode: TruncationMode.Fade
        color: theme.highlightColor
        horizontalAlignment: Text.AlignRight
        verticalAlignment: Text.AlignVCenter
        font {
            pixelSize: theme.fontSizeLarge
            family: theme.fontFamilyHeading
        }
    }

    // Add "add account" to the footer. User must be able to
    // create accounts in a case there are none.
    footer: BackgroundItem {
        Label {
            //% "Add account"
            text: qsTrId("camera-la-add_account")
            x: theme.paddingLarge
            anchors.verticalCenter: parent.verticalCenter
            color: highlighted ? theme.highlightColor : theme.primaryColor
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
