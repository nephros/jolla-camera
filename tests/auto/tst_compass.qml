import QtQuick 2.0
import QtTest 1.0
import Sailfish.Silica 1.0
import com.jolla.camera 1.0

Item {
    id: main

    width: 640
    height: 480


    Compass {
        id: compass
    }

    TestCase {
        when: windowShown

        function init() {
            compass.leftAction.enabled = true
            compass.topAction.enabled = true
            compass.rightAction.enabled = true
            compass.bottomAction.enabled = true

            compass.keepSelection = false
            compass.closeMenu()
            tryCompare(compass, "expanded", false)
            tryCompare(compass, "animating", false)
        }

        function test_dimensions() {
            compare(compass.width, 180)
            compare(compass.height, 180)
        }

        // there is weirdness with mouseDrag/mouseMove in that it does enough to make
        // drag.active on a MouseArea true but doesn't move the target item.
//        function test_leftAction() {
        function leftAction() {
            var actionActivated = false
            var activate = function() { actionActivated = true }

            compass.leftAction.activated.connect(activate)

            // Dragging the the compass half its width to the right should activate the
            // left action, and then animate back to the neutral position.
            mouseDrag(compass, compass.width / 2, compass.height / 2, compass.width / 2, 0, Qt.LeftButton)
            mouseRelease(compass, compass.width, compass.height / 2, Qt.LeftButton)

            compare(actionActivated, true)
            compare(compass.animating, true)
            tryCompare(compass, "animating", false)

            // Dragging the compass a quarter its width wont activate, but will animate
            // back to the neutral position
            mouseDrag(compass, compass.width / 2, compass.height / 2, compass.width / 4, 0)
            mouseRelease(compass, compass.width * 3 / 4, compass.height / 2)

            compare(actionActivated, false)
            compare(compass.animating, true)
            tryCompare(compass, "animating", false)

            // If disabled, dragging the compass should do nothing
            compass.leftAction.enabled = false
            mouseDrag(compass, compass.width / 2, compass.height / 2, compass.width / 2, 0)
            mouseRelease(compass, compass.width, compass.height / 2)

            compare(actionActivated, false)
            compare(compass.animating, false)

            // Setting the keep selection property should prevent the compass from
            // animating back to the neutral position on release from the activated
            // position
            compass.leftAction.enabled = true

            compass.leftAction.activated.disconnect(activate)
            activate = function() {
                actionActivated = true
                compass.keepSelection = true
            }
            compass.leftAction.activated.connect(activate)

            mouseDrag(compass, compass.width / 2, compass.height / 2, compass.width / 2, 0)
            mouseRelease(compass, compass.width, compass.height / 2)

            compare(actionActivated, true)
            compass(compass.keepSelection, true)
            compare(compass.animating, false)

            compass.keepSelection = false
            compare(compass.animating, true)
            tryCompare(compass, "animating", false)

            // keepSelection shouldn't prevent the compass from returning to the neutral
            // position if no selection was made.
            compass.keepSelection = true
            mouseDrag(compass, compass.width / 2, compass.height / 2, compass.width / 4, 0)
            mouseRelease(compass, compass.width * 3 / 4, compass.height / 2)

            compare(actionActivated, false)
            compare(compass.animating, true)
            tryCompare(compass, "animating", false)

            compass.leftAction.activated.disconnect(activate)
        }
    }
}
