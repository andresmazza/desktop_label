import QtQuick
import org.kde.pipewire as PipeWire
import org.kde.taskmanager as TaskManager

// Miniatura en vivo de una ventana (Wayland). Va en un archivo aparte para
// que el widget siga cargando aunque PipeWire no esté disponible.
PipeWire.PipeWireSourceItem {
    property alias uuid: request.uuid

    nodeId: request.nodeId

    TaskManager.ScreencastingRequest {
        id: request
    }
}
