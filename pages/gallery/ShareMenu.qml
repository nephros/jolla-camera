import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Ambience 1.0
import Sailfish.TransferEngine 1.0
import com.jolla.settings.accounts 1.0
import com.jolla.signonuiservice 1.0

ShareMethodList {
    id: menuList

    property bool isImage
    property string title
    property alias resolved: detailsItem.enabled

    property Item page

    signal deleteFile
    signal showDetails

    pressDelay: 0

    //% "Share"
    listHeader: qsTrId("camera-la-share")

    PullDownMenu {
        id: pullDownMenu
        MenuItem {
            id: detailsItem
            //% "Details"
            text: qsTrId("camera-me-details")
            onClicked: menuList.showDetails()
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
            onClicked: Ambience.source = menuList.source
        }
    }

    header: Label {
        text: menuList.title

        anchors { right: menuList.contentItem.right; rightMargin: Theme.paddingLarge }
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
            accountCreator.startAccountCreation()
        }
    }

    SignonUiService {
        id: jolla_signon_ui_service
        inProcessServiceName: "com.jolla.camera"
        inProcessObjectPath: "/JollaCameraSignonUi"
    }

    AccountCreationManager {
        id: accountCreator
        serviceFilter: ["sharing"]
        endDestination: menuList.page
        endDestinationAction: PageStackAction.Pop
    }
}
