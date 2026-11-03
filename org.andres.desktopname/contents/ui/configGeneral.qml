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
            Kirigami.FormData.label: i18n("Font size:")
            text: i18n("Automatic (system theme)")
        }
        QQC2.SpinBox {
            id: sizeSpin
            enabled: !autoSize.checked
            from: 6
            to: 96
            textFromValue: (v) => i18n("%1 pt", v)
            valueFromText: (t) => parseInt(t)
        }
        QQC2.CheckBox {
            id: boldCheck
            text: i18n("Bold")
        }

        Item { Kirigami.FormData.isSection: true }

        QQC2.CheckBox {
            id: customColor
            Kirigami.FormData.label: i18n("Color:")
            text: i18n("Use custom color")
        }
        KQControls.ColorButton {
            id: colorButton
            enabled: customColor.checked
            showAlphaChannel: true
        }
    }
}
