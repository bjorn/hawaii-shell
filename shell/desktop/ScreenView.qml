/****************************************************************************
 * This file is part of Hawaii.
 *
 * Copyright (C) 2014-2016 Pier Luigi Fiorini
 *
 * Author(s):
 *    Pier Luigi Fiorini <pierluigi.fiorini@gmail.com>
 *
 * $BEGIN_LICENSE:GPL2+$
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * $END_LICENSE$
 ***************************************************************************/

import QtQuick 2.0
import QtGraphicalEffects 1.0
import GreenIsland 1.0 as GreenIsland
import Fluid.Ui 1.0 as FluidUi
import org.hawaiios.misc 0.1 as Misc
import ".."
import "../components"
import "../indicators"

Item {
    property var layers: QtObject {
        readonly property alias workspaces: workspacesLayer
        readonly property alias fullScreen: fullScreenLayer
        readonly property alias overlays: overlaysLayer
        readonly property alias notifications: notificationsLayer
    }

    readonly property alias currentWorkspace: workspacesLayer.currentItem
    readonly property var panel: shellLoader.item ? shellLoader.item.panel : null
    property alias windowsSwitcher: windowSwitcherLoader

    id: screenView

    /*
     * Hot corners
     */

    HotCorners {
        id: hotCorners
        anchors.fill: parent
        z: 2000
        onTopLeftTriggered: workspacesLayer.selectPrevious()
        onTopRightTriggered: workspacesLayer.selectNext()
        onBottomLeftTriggered: currentWorkspace.state = "present";
    }

    /*
     * Workspace
     */

    // Background image or color
    Background {
        id: backgroundLayer
        anchors.fill: parent
        z: 0

        // Desktop applets
        Desktop {
            id: desktopLayer
            anchors.fill: parent
            z: 1
        }

        // Workspaces
        WorkspacesView {
            id: workspacesLayer
            anchors.fill: parent
            z: 2
        }

        // Panels
        Loader {
            id: shellLoader
            anchors.fill: parent
            asynchronous: true
            active: primary
            sourceComponent: Shell {}

            z: 3
        }
    }

    // Full screen windows can cover application windows and panels
    Rectangle {
        id: fullScreenLayer
        anchors.fill: parent
        color: "black"
        z: 10
        opacity: children.length > 0 ? 1.0 : 0.0

        Behavior on opacity {
            NumberAnimation {
                easing.type: Easing.InSine
                duration: FluidUi.Units.mediumDuration
            }
        }
    }

    // Overlays are above the panel
    Overlay {
        id: overlaysLayer
        anchors.centerIn: parent
        z: 5
    }

    // Notifications are behind the panel
    Item {
        id: notificationsLayer
        anchors.fill: parent
        z: 5
    }

    // Windows switcher
    Loader {
        id: windowSwitcherLoader
        anchors {
            horizontalCenter: parent.horizontalCenter
            verticalCenter: parent.verticalCenter
        }
        active: false
        asynchronous: true
        source: "../WindowSwitcher.qml"
        z: 1000

        Connections {
            target: windowSwitcherLoader.item
            onClosed: windowSwitcherLoader.active = false
        }

        function previous() {
            if (item)
                item.previous();
        }

        function next() {
            if (item)
                item.next();
        }
    }

    function setAvailableGeometry(h) {
        // Set available geometry so that windows are maximized properly
        if (h > 0) {
            output.availableGeometry = Qt.rect(0, 0, output.window.width, output.window.height - h);
            console.debug("Available geometry for", output.model, "is:", output.availableGeometry);
        } else {
            console.warn("Trying to set available geometry from invalid height", h);
        }
    }
}
