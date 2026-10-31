import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kquickcontrols as KQControls
import org.kde.kcmutils as KCM

KCM.SimpleKCM {
    property alias cfg_autoFontSize: autoSize.checked
    property alias cfg_fontSize: sizeSpin.value
    property alias cfg_bold: boldCheck.checked
    property alias cfg_useCustomColor: customColor.checked
    property alias cfg_textColor: colorButton.color

    Kirigami.FormLayout {
        QQC2.CheckBox {
            id: autoSize
            Kirigami.FormData.label: "Tamaño de letra:"
            text: "Automático (tema del sistema)"
        }
        QQC2.SpinBox {
            id: sizeSpin
            enabled: !autoSize.checked
            from: 6
            to: 96
            textFromValue: (v) => v + " pt"
            valueFromText: (t) => parseInt(t)
        }
        QQC2.CheckBox {
            id: boldCheck
            text: "Negrita"
        }

        Item { Kirigami.FormData.isSection: true }

        QQC2.CheckBox {
            id: customColor
            Kirigami.FormData.label: "Color:"
            text: "Usar color personalizado"
        }
        KQControls.ColorButton {
            id: colorButton
            enabled: customColor.checked
            showAlphaChannel: true
        }
    }
}
