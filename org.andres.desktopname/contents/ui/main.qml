import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.extras as PlasmaExtras
import org.kde.kirigami as Kirigami
import org.kde.taskmanager as TaskManager

PlasmoidItem {
    id: root

    TaskManager.VirtualDesktopInfo { id: vdInfo }
    TaskManager.ActivityInfo { id: activityInfo }

    // Ventanas del escritorio y actividad actuales
    TaskManager.TasksModel {
        id: tasksModel
        virtualDesktop: vdInfo.currentDesktop
        activity: activityInfo.currentActivity
        filterByVirtualDesktop: true
        filterByActivity: true
        groupMode: TaskManager.TasksModel.GroupDisabled
        sortMode: TaskManager.TasksModel.SortLastActivated
    }

    readonly property int currentIndex: vdInfo.desktopIds.indexOf(vdInfo.currentDesktop)
    readonly property string desktopName:
        currentIndex >= 0 && currentIndex < vdInfo.desktopNames.length
            ? vdInfo.desktopNames[currentIndex]
            : ""

    preferredRepresentation: compactRepresentation
    toolTipMainText: desktopName
    toolTipSubText: "Escritorio " + (currentIndex + 1) + " de " + vdInfo.numberOfDesktops
        + "\nClic para ver las ventanas"

    compactRepresentation: Item {
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

        // Clic: abre/cierra la vista previa de ventanas
        TapHandler {
            onTapped: root.expanded = !root.expanded
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

    fullRepresentation: PlasmaExtras.Representation {
        id: popup

        readonly property int cellWidth: Kirigami.Units.gridUnit * 14
        readonly property int cellHeight: Kirigami.Units.gridUnit * 10
        readonly property int columns: Math.max(1, Math.min(3, grid.count))

        Layout.preferredWidth: columns * cellWidth + Kirigami.Units.smallSpacing * 2
        Layout.preferredHeight: header.implicitHeight
            + Math.max(1, Math.ceil(grid.count / columns)) * cellHeight
            + Kirigami.Units.smallSpacing * 4
        Layout.maximumHeight: Kirigami.Units.gridUnit * 40

        collapseMarginsHint: true

        header: PlasmaExtras.PlasmoidHeading {
            PlasmaExtras.Heading {
                anchors.fill: parent
                level: 4
                text: root.desktopName
                elide: Text.ElideRight
            }
        }

        PlasmaComponents.ScrollView {
            anchors.fill: parent

            GridView {
                id: grid
                model: tasksModel
                cellWidth: popup.cellWidth
                cellHeight: popup.cellHeight
                clip: true
                interactive: contentHeight > height

                delegate: WindowPreview {}
            }
        }

        PlasmaExtras.PlaceholderMessage {
            anchors.centerIn: parent
            width: parent.width - Kirigami.Units.gridUnit * 2
            visible: grid.count === 0
            iconName: "window"
            text: "No hay ventanas en este escritorio"
        }
    }

    component WindowPreview: Item {
        id: cell

        required property int index
        required property var model

        // En Wayland es un UUID (texto); en X11, un número
        readonly property var winId: model.WinIdList ? model.WinIdList[0] : undefined

        width: GridView.view.cellWidth
        height: GridView.view.cellHeight

        PlasmaExtras.Highlight {
            anchors.fill: parent
            anchors.margins: Kirigami.Units.smallSpacing
            hovered: mouse.containsMouse
            pressed: mouse.pressed
            visible: mouse.containsMouse || cell.model.IsActive
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Kirigami.Units.smallSpacing * 3
            spacing: Kirigami.Units.smallSpacing

            RowLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.smallSpacing

                Kirigami.Icon {
                    source: cell.model.decoration
                    Layout.preferredWidth: Kirigami.Units.iconSizes.small
                    Layout.preferredHeight: Kirigami.Units.iconSizes.small
                }
                PlasmaComponents.Label {
                    Layout.fillWidth: true
                    text: cell.model.display
                    elide: Text.ElideRight
                    font.bold: cell.model.IsActive
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                // Wayland: miniatura en vivo por PipeWire
                Loader {
                    id: pipeWireLoader
                    anchors.fill: parent
                    active: root.expanded && !cell.model.IsMinimized
                        && cell.winId !== undefined && !Number.isInteger(cell.winId)
                    source: "PipeWireThumbnail.qml"
                    onLoaded: item.uuid = Qt.binding(() => cell.winId)
                }

                // X11: miniatura nativa
                Loader {
                    anchors.fill: parent
                    active: root.expanded && !cell.model.IsMinimized && Number.isInteger(cell.winId)
                    sourceComponent: PlasmaCore.WindowThumbnail {
                        winId: cell.winId
                    }
                }

                // Sin miniatura (minimizada o aún cargando): icono de la aplicación
                Kirigami.Icon {
                    anchors.centerIn: parent
                    width: Kirigami.Units.iconSizes.huge
                    height: width
                    source: cell.model.decoration
                    visible: !(pipeWireLoader.item && pipeWireLoader.item.ready)
                        && !(Number.isInteger(cell.winId) && !cell.model.IsMinimized)
                    opacity: cell.model.IsMinimized ? 0.5 : 1
                }
            }
        }

        MouseArea {
            id: mouse
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.LeftButton | Qt.MiddleButton
            onClicked: (mouseEvent) => {
                const idx = tasksModel.makeModelIndex(cell.index)
                if (mouseEvent.button === Qt.MiddleButton) {
                    // Clic central: cerrar la ventana
                    tasksModel.requestClose(idx)
                } else {
                    tasksModel.requestActivate(idx)
                    root.expanded = false
                }
            }
        }
    }
}
