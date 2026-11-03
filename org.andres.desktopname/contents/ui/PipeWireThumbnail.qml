import QtQuick
import org.kde.pipewire as PipeWire
import org.kde.taskmanager as TaskManager

// Live window thumbnail (Wayland). Kept in a separate file so the widget
// still loads when PipeWire is not available.
PipeWire.PipeWireSourceItem {
    property alias uuid: request.uuid

    nodeId: request.nodeId

    TaskManager.ScreencastingRequest {
        id: request
    }
}
