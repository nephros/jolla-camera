import QtQuick 1.1
import Sailfish.Silica 1.0
import Sailfish.TransferEngine 1.0
import com.jolla.components.accounts 1.0
import com.jolla.components.views 1.0

SplitViewPage {
    id: page

    property QtObject model
    property Component delegate
    property alias menus: menuList.children
    property Item _currentItem

    allowedOrientations: Orientation.Portrait | Orientation.Landscape

    SailfishTransferMethodsModel {
        id: transferMethodsModel
        filter: page._currentItem.mimeType
    }

    // This is the share method list, but it also
    // includes the pulley menu
    ShareMethodList {
        id: menuList

        model:  transferMethodsModel
        source: page._currentItem.url

        anchors {
            left: parent.left
            top: parent.top
            right: isPortrait ? parent.right : parent.horizontalCenter
            bottom: isPortrait ? parent.verticalCenter : parent.bottom
        }

        //% "Share"
        listHeader: qsTrId("camera-la-share")

        header: Item {
            height: theme.itemSizeLarge
            width: menuList.width * 0.7 - theme.paddingLarge
            x: menuList.width * 0.3

            Label {
                text: page._currentItem.title
                width: parent.width
                truncationMode: TruncationMode.Fade
                color: theme.highlightColor
                anchors.verticalCenter: parent.verticalCenter
                horizontalAlignment: Text.AlignRight
                font {
                    pixelSize: theme.fontSizeLarge
                    family: theme.fontFamilyHeading
                }
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
                color: parent.down ? theme.highlightColor : theme.primaryColor
            }

            onClicked: {
                jolla_signon_ui_service.inProcessParent = page
                pageStack.push(accountsPage)
            }
        }

        Component {
            id: accountsPage
            AccountsPage { }
        }
    }

    contentItem: ListView {
        orientation: ListView.Horizontal
        snapMode: ListView.SnapOneItem

        onCurrentItemChanged: page._currentItem = currentItem

        model: page.model
        delegate: page.delegate
    }
}
