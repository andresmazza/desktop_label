# Desktop Name

A **KDE Plasma 6** widget (plasmoid) that shows the name of the current virtual desktop.

![Demo: the widget in the top panel showing desktop "2"](screenshots/demo.png)

## Features

- Shows the name of the active virtual desktop and updates when you switch desktops.
- Tooltip with the desktop position (for example, "Desktop 2 of 4").
- Click the widget to see a preview of the windows on the current desktop. Click a preview to switch to that window; middle-click to close it.
- Scroll over the widget to switch desktops (wraps around).
- Configurable font size, bold and text color.
- Works on Wayland and X11.

## Requirements

- KDE Plasma 6.0 or later

## Installation

### From the KDE Store

1. Right-click the panel or desktop → **Add or Manage Widgets**.
2. **Get New Widgets** → **Download New Plasma Widgets**.
3. Search for **"Desktop Name"** and install it.

### From the `.plasmoid` file

```bash
kpackagetool6 -t Plasma/Applet -i org.andres.desktopname.plasmoid
```

### From source

```bash
git clone https://github.com/andresmazza/desktop_label.git
cd desktop_label
kpackagetool6 -t Plasma/Applet -i org.andres.desktopname
```

If the widget does not show up in the list, restart Plasma:

```bash
plasmashell --replace &
```

## Usage

1. Right-click the panel or desktop → **Add or Manage Widgets**.
2. Search for **"Desktop Name"** and drag it wherever you want.
3. Click the widget to see the windows on the current desktop.
4. Scroll over the widget to switch desktops.

Desktop names are changed in **System Settings → Virtual Desktops**.

### Window preview

Clicking the widget opens a panel with a thumbnail of each window on the current desktop and activity. The most recently used windows come first.

| Action | Result |
|---|---|
| Click the widget | Opens or closes the panel |
| Click a thumbnail | Switches to that window and closes the panel |
| Middle-click a thumbnail | Closes that window |

- Thumbnails update in real time while the panel is open. They are not generated while it is closed, so they use no resources.
- The active window is highlighted and its title is shown in bold.
- Minimized windows are shown with the application icon.
- On Wayland, thumbnails come from PipeWire, just like in the Plasma task manager. If PipeWire is not available, the application icon is shown instead.

## Configuration

Right-click the widget → **Configure Desktop Name…**

| Option | Description | Default |
|---|---|---|
| Font size | Automatic (theme size) or manual, from 6 to 96 pt | Automatic |
| Bold | Shows the text in bold | On |
| Color | Theme color or a custom one (supports transparency) | Theme color |

## Translations

The widget follows your system language. Available languages: English and Spanish.

To add or update a translation:

1. Run `python3 translate/build.py` to refresh `translate/template.pot` with the current strings.
2. Copy `template.pot` to `translate/<lang>.po` (for example `fr.po`) or edit an existing one, and fill in every `msgstr`.
3. Run `python3 translate/build.py` again. It reports missing strings and compiles the translation into `contents/locale/`.
4. Optionally add `"Name[<lang>]"` and `"Description[<lang>]"` to `metadata.json`.

## Update

```bash
kpackagetool6 -t Plasma/Applet -u org.andres.desktopname.plasmoid
```

## Uninstall

```bash
kpackagetool6 -t Plasma/Applet -r org.andres.desktopname
```

## Structure

```
.
├── README.md
├── LICENSE
├── screenshots/                       # Screenshots for the README
├── translate/                         # Translation sources
│   ├── build.py                       # Extracts strings and compiles translations
│   ├── template.pot                   # Strings to translate (generated)
│   └── es.po                          # Spanish translation
└── org.andres.desktopname/            # Widget package
    ├── metadata.json                  # Widget name, version and icon
    └── contents/
        ├── locale/                    # Compiled translations (generated)
        ├── config/
        │   ├── main.xml               # Options and default values
        │   └── config.qml             # Registers the settings page
        └── ui/
            ├── main.qml               # Widget
            ├── PipeWireThumbnail.qml  # Window thumbnail (Wayland)
            └── configGeneral.qml      # Settings form
```

### Building the `.plasmoid` file

```bash
cd org.andres.desktopname
zip -r ../org.andres.desktopname.plasmoid metadata.json contents
```

## License

GPL-2.0-or-later. See the [LICENSE](LICENSE) file.
