import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasma5support as Plasma5Support
import org.kde.kcmutils as KCM
import org.kde.taskmanager as TaskManager
import org.kde.kirigami as Kirigami

PlasmoidItem {
    id: root
    
    preferredRepresentation: fullRepresentation
    compactRepresentation: fullRepresentation
    Component.onCompleted: updateLayout()
    
    readonly property QtObject virtualDesktopInfo: TaskManager.VirtualDesktopInfo {
        id: virtualDesktopInfo
    }
    
    property int currentDesktop: {
        let desktop = virtualDesktopInfo.currentDesktop
        if (typeof desktop === 'string') {
            return Math.max(0, virtualDesktopInfo.desktopIds.indexOf(desktop))
        }
        return Math.max(0, (desktop || 1) - 1)
    }
    
    property int desktopCount: virtualDesktopInfo.numberOfDesktops
    
    property int dotSize: Math.max(2, plasmoid.configuration.dotSizeCustom || 8)
    property real spacingFactor: Math.max(0.5, plasmoid.configuration.spacingFactor || 1.5)
    property int activeWidth: Math.max(dotSize, plasmoid.configuration.activeSizeW || 20)
    property int activeHeight: Math.max(dotSize, plasmoid.configuration.activeSizeH || 20)
    property bool wrapOn: plasmoid.configuration.desktopWrapOn !== false
    property bool customColors: plasmoid.configuration.customColorsEnabled || false
    // We use a helper function to validate the color string
property color activeColor: {
    if (!customColors) return Kirigami.Theme.highlightColor;
    let c = Color.transparent; // default fallback
    c = plasmoid.configuration.activeColor;
    // If the string is invalid, c will be invalid. Return highlight as fallback.
    return !isNaN(c.r) ? c : Kirigami.Theme.highlightColor;
}

property color inactiveColor: {
    if (!customColors) return Kirigami.Theme.textColor;
    let c = plasmoid.configuration.inactiveColor;
    return !isNaN(c.r) ? c : Kirigami.Theme.textColor;
}

    property int animDuration: Math.max(0, plasmoid.configuration.animationDuration || 300)
    property bool canAddDesktops: plasmoid.configuration.canAddDesktops !== false
    
    property real spacing: spacingFactor * dotSize
    property bool isHorizontal: plasmoid.formFactor !== PlasmaCore.Types.Vertical
    property int wheelDelta: 0
    
    function updateLayout() {
        root.implicitWidth = Qt.binding(function() { return Layout.minimumWidth })
        root.implicitHeight = Qt.binding(function() { return Layout.minimumHeight })
    }
    
    onDotSizeChanged: updateLayout()
    onSpacingFactorChanged: updateLayout()
    onActiveWidthChanged: updateLayout()
    onActiveHeightChanged: updateLayout()
    onDesktopCountChanged: updateLayout()
    
    Layout.minimumWidth: isHorizontal ? 
        (desktopCount * dotSize) + ((desktopCount - 1) * spacing) + (activeWidth - dotSize) : activeWidth
        
    Layout.minimumHeight: !isHorizontal ? 
        (desktopCount * dotSize) + ((desktopCount - 1) * spacing) + (activeHeight - dotSize) : activeHeight
        
    Layout.preferredWidth: Layout.minimumWidth
    Layout.preferredHeight: Layout.minimumHeight

    function switchToDesktop(index) {
        let desktopNumber = index + 1
        let service = "org.kde.KWin"
        let path = "/KWin"
        let kwinIface = "org.kde.KWin" 
        
        let call = 'qdbus6 ' + service + ' ' + path + ' ' + kwinIface + '.setCurrentDesktop ' + desktopNumber + ' 2>/dev/null || ' +
                   'qdbus ' + service + ' ' + path + ' ' + kwinIface + '.setCurrentDesktop ' + desktopNumber + ' 2>/dev/null || ' +
                   'kdotool set_desktop ' + desktopNumber + ' 2>/dev/null'
        
        executable.connectSource(call)
    }
    
    function addDesktop() {
        if (!canAddDesktops) return
        let call = 'qdbus6 org.kde.KWin /KWin org.kde.KWin.addDesktop 2>/dev/null || ' +
                   'qdbus org.kde.KWin /KWin org.kde.KWin.addDesktop 2>/dev/null'
        executable.connectSource(call)
    }
    
    function removeDesktop() {
        if (!canAddDesktops || desktopCount <= 1) return
        let call = 'qdbus6 org.kde.KWin /KWin org.kde.KWin.removeDesktop 2>/dev/null || ' +
                   'qdbus org.kde.KWin /KWin org.kde.KWin.removeDesktop 2>/dev/null'
        executable.connectSource(call)
    }

    Plasma5Support.DataSource {
        id: executable
        engine: "executable"
        connectedSources: []
        onNewData: function(source, data) {
            disconnectSource(source)
        }
    }

    Item {
        id: mainContainer
        anchors.fill: parent
        
        Repeater {
            id: desktopRepeater
            model: desktopCount
            
            delegate: Item {
                id: delegateItem
                x: isHorizontal ? (index < currentDesktop ? index * (dotSize + spacing) : (index > currentDesktop ? (index * (dotSize + spacing)) + (activeWidth - dotSize) : index * (dotSize + spacing))) : (parent.width - width) / 2
                y: !isHorizontal ? (index < currentDesktop ? index * (dotSize + spacing) : (index > currentDesktop ? (index * (dotSize + spacing)) + (activeHeight - dotSize) : index * (dotSize + spacing))) : (parent.height - height) / 2
                
                width: isHorizontal ? (index === currentDesktop ? activeWidth : dotSize) : dotSize
                height: !isHorizontal ? (index === currentDesktop ? activeHeight : dotSize) : dotSize
                
                Rectangle {
                    id: desktopDot
                    anchors.fill: parent
                    color: index === currentDesktop ? activeColor : inactiveColor
                    opacity: index === currentDesktop ? 1.0 : 0.6
                    radius: height * 0.5
                    
                    Behavior on color { ColorAnimation { duration: animDuration; easing.type: Easing.InOutQuad } }
                    Behavior on opacity { NumberAnimation { duration: animDuration; easing.type: Easing.InOutQuad } }
                    
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: switchToDesktop(index)
                    }
                }
                
                Behavior on x { NumberAnimation { duration: animDuration; easing.type: Easing.OutQuad } }
                Behavior on y { NumberAnimation { duration: animDuration; easing.type: Easing.OutQuad } }
                Behavior on width { NumberAnimation { duration: animDuration; easing.type: Easing.OutQuad } }
                Behavior on height { NumberAnimation { duration: animDuration; easing.type: Easing.OutQuad } }
            }
        }
        
        MouseArea {
            id: wheelArea
            anchors.fill: parent
            acceptedButtons: Qt.NoButton
            onWheel: function(wheel) {
                let delta = wheel.angleDelta.y || wheel.angleDelta.x
                wheelDelta += delta
                let steps = 0
                while (wheelDelta >= 120) { wheelDelta -= 120; steps-- }
                while (wheelDelta <= -120) { wheelDelta += 120; steps++ }
                
                if (steps !== 0) {
                    let targetDesktop = currentDesktop + steps
                    if (wrapOn) {
                        targetDesktop = ((targetDesktop % desktopCount) + desktopCount) % desktopCount
                    } else {
                        targetDesktop = Math.max(0, Math.min(desktopCount - 1, targetDesktop))
                    }
                    if (targetDesktop !== currentDesktop) switchToDesktop(targetDesktop)
                }
                wheel.accepted = true
            }
        }
    }

    Plasmoid.contextualActions: [
        PlasmaCore.Action {
            text: i18n("Add Virtual Desktop")
            icon.name: "list-add"
            enabled: canAddDesktops
            onTriggered: addDesktop()
        },
        PlasmaCore.Action {
            text: i18n("Remove Virtual Desktop")
            icon.name: "list-remove"
            enabled: canAddDesktops && desktopCount > 1
            onTriggered: removeDesktop()
        },
        PlasmaCore.Action {
            text: i18n("Configure Virtual Desktops…")
            icon.name: "configure"
            onTriggered: KCM.KCMLauncher.openSystemSettings("kcm_kwin_virtualdesktops")
        }
    ]
}