import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami
import org.kde.taskmanager as TaskManager

PlasmoidItem {
    id: root

    TaskManager.VirtualDesktopInfo { id: vdInfo }

    readonly property int currentIndex: vdInfo.desktopIds.indexOf(vdInfo.currentDesktop)
    readonly property string desktopName:
        currentIndex >= 0 && currentIndex < vdInfo.desktopNames.length
            ? vdInfo.desktopNames[currentIndex]
            : ""

    preferredRepresentation: fullRepresentation
    toolTipMainText: desktopName
    toolTipSubText: "Escritorio " + (currentIndex + 1) + " de " + vdInfo.numberOfDesktops

    fullRepresentation: Item {
        readonly property bool vertical: Plasmoid.formFactor === PlasmaCore.Types.Vertical

        Layout.minimumWidth: label.implicitWidth + Kirigami.Units.smallSpacing * 2
        Layout.preferredWidth: Layout.minimumWidth
        Layout.minimumHeight: label.implicitHeight

        PlasmaComponents.Label {
            id: label
            anchors.centerIn: parent
            text: root.desktopName
            font.bold: Plasmoid.configuration.bold
            font.pointSize: Plasmoid.configuration.autoFontSize
                ? Kirigami.Theme.defaultFont.pointSize
                : Plasmoid.configuration.fontSize
            color: Plasmoid.configuration.useCustomColor
                ? Plasmoid.configuration.textColor
                : Kirigami.Theme.textColor
        }

        // Rueda del ratón: cambia de escritorio
        WheelHandler {
            onWheel: (event) => {
                const n = vdInfo.desktopIds.length
                if (n < 2) return
                const step = event.angleDelta.y < 0 ? 1 : -1
                const next = (root.currentIndex + step + n) % n
                vdInfo.requestActivate(vdInfo.desktopIds[next])
            }
        }
    }
}
