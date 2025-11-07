import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root

    property var pluginService: null

    ScrollView {
        anchors.fill: parent
        clip: true
        contentWidth: availableWidth
        
        Column {
            width: parent.width
            spacing: 20
            padding: 20

        // Header
        Rectangle {
            width: parent.width - 40
            height: headerColumn.implicitHeight + 32
            radius: 12
            color: "#2A2A2A"

            Column {
                id: headerColumn
                anchors.centerIn: parent
                width: parent.width - 32
                spacing: 12

                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 12

                    Text {
                        text: "🔍"
                        font.pixelSize: 32
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: "GNOME Search Providers"
                        font.pixelSize: 18
                        font.weight: Font.Bold
                        color: "#FFFFFF"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                Text {
                    width: parent.width
                    text: "Search across multiple GNOME applications from DMS launcher"
                    font.pixelSize: 12
                    color: "#AAAAAA"
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                }
            }
        }

        // Trigger Configuration
        Rectangle {
            width: parent.width - 40
            height: triggerColumn.implicitHeight + 24
            radius: 12
            color: "#2A2A2A"

            Column {
                id: triggerColumn
                anchors.centerIn: parent
                width: parent.width - 24
                spacing: 12

                Text {
                    text: "Trigger Configuration"
                    font.pixelSize: 14
                    font.weight: Font.Medium
                    color: "#FFFFFF"
                }

                Text {
                    width: parent.width
                    text: "By default, this plugin has no trigger - search results appear alongside regular apps."
                    font.pixelSize: 11
                    color: "#AAAAAA"
                    wrapMode: Text.WordWrap
                }

                CheckBox {
                    id: useTriggerToggle
                    text: "Use custom trigger prefix"
                    checked: loadSettings("useTrigger", false)

                    contentItem: Text {
                        text: useTriggerToggle.text
                        font.pixelSize: 12
                        color: "#CCFFFFFF"
                        leftPadding: useTriggerToggle.indicator.width + useTriggerToggle.spacing
                        verticalAlignment: Text.AlignVCenter
                    }

                    onCheckedChanged: {
                        saveSettings("useTrigger", checked)
                        if (checked) {
                            saveSettings("trigger", triggerField.text || "g")
                        } else {
                            saveSettings("trigger", "")
                        }
                    }
                }

                Row {
                    visible: useTriggerToggle.checked
                    spacing: 12
                    width: parent.width

                    Text {
                        text: "Trigger:"
                        font.pixelSize: 12
                        color: "#CCFFFFFF"
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    TextField {
                        id: triggerField
                        width: 100
                        height: 32
                        text: loadSettings("trigger", "g")
                        placeholderText: "g"
                        enabled: useTriggerToggle.checked
                        
                        background: Rectangle {
                            color: "#1A1A1A"
                            border.color: triggerField.activeFocus ? "#4A4A4A" : "#2A2A2A"
                            border.width: 1
                            radius: 4
                        }
                        
                        color: "#FFFFFF"
                        font.pixelSize: 12

                        onTextEdited: {
                            saveSettings("trigger", text || "g")
                        }
                    }

                    Text {
                        text: "Type '" + (triggerField.text || "g") + "' to filter to these providers"
                        font.pixelSize: 11
                        color: "#888888"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }
        }

        // Search Providers Configuration
        Rectangle {
            width: parent.width - 40
            height: providersColumn.implicitHeight + 24
            radius: 12
            color: "#2A2A2A"

            Column {
                id: providersColumn
                anchors.centerIn: parent
                width: parent.width - 24
                spacing: 12

                Text {
                    text: "Enabled Search Providers"
                    font.pixelSize: 14
                    font.weight: Font.Medium
                    color: "#FFFFFF"
                }

                Text {
                    width: parent.width
                    text: "Select which search providers to query:"
                    font.pixelSize: 11
                    color: "#AAAAAA"
                    wrapMode: Text.WordWrap
                }

                Column {
                    width: parent.width
                    spacing: 8

                    Repeater {
                        model: [
                            {service: "io.github.kolunmi.Bazaar", name: "Bazaar (Flatpak Store)", icon: "🛍️"},
                            {service: "org.gnome.Nautilus.SearchProvider", name: "Files (Nautilus)", icon: "📁"},
                            {service: "org.gnome.Calculator.SearchProvider", name: "Calculator", icon: "🧮"},
                            {service: "org.gnome.Characters.SearchProvider", name: "Characters", icon: "😊"},
                            {service: "org.gnome.Settings.SearchProvider", name: "Settings", icon: "⚙️"}
                        ]

                        CheckBox {
                            id: providerCheckbox
                            text: modelData.icon + " " + modelData.name
                            checked: isProviderEnabled(modelData.service)

                            contentItem: Text {
                                text: providerCheckbox.text
                                font.pixelSize: 12
                                color: "#CCFFFFFF"
                                leftPadding: providerCheckbox.indicator.width + providerCheckbox.spacing
                                verticalAlignment: Text.AlignVCenter
                            }

                            onCheckedChanged: {
                                updateProviderEnabled(modelData.service, checked)
                            }
                        }
                    }
                }
            }
        }

        // Settings
        Rectangle {
            width: parent.width - 40
            height: settingsColumn.implicitHeight + 24
            radius: 12
            color: "#2A2A2A"

            Column {
                id: settingsColumn
                anchors.centerIn: parent
                width: parent.width - 24
                spacing: 12

                Text {
                    text: "Search Settings"
                    font.pixelSize: 14
                    font.weight: Font.Medium
                    color: "#FFFFFF"
                }

                Row {
                    spacing: 12
                    width: parent.width

                    Text {
                        text: "Max results per provider:"
                        font.pixelSize: 12
                        color: "#CCFFFFFF"
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    SpinBox {
                        id: maxResultsSpinBox
                        from: 1
                        to: 20
                        value: loadSettings("maxResultsPerProvider", 5)
                        editable: true

                        onValueChanged: {
                            saveSettings("maxResultsPerProvider", value)
                        }

                        contentItem: TextInput {
                            text: maxResultsSpinBox.textFromValue(maxResultsSpinBox.value, maxResultsSpinBox.locale)
                            font.pixelSize: 12
                            color: "#FFFFFF"
                            horizontalAlignment: Qt.AlignHCenter
                            verticalAlignment: Qt.AlignVCenter
                            readOnly: !maxResultsSpinBox.editable
                            validator: maxResultsSpinBox.validator
                            inputMethodHints: Qt.ImhFormattedNumbersOnly
                        }
                    }
                }
            }
        }

        // Usage Instructions
        Rectangle {
            width: parent.width - 40
            height: usageColumn.implicitHeight + 24
            radius: 12
            color: "#1A3A1A"

            Column {
                id: usageColumn
                anchors.centerIn: parent
                width: parent.width - 24
                spacing: 8

                Text {
                    text: "💡 How to Use"
                    font.pixelSize: 14
                    font.weight: Font.Medium
                    color: "#FFFFFF"
                }

                Text {
                    text: "1. Open DMS Launcher (Ctrl+Space)"
                    font.pixelSize: 12
                    color: "#CCFFFFFF"
                }

                Text {
                    text: useTriggerToggle.checked ? "2. Type '" + (triggerField.text || "g") + "' followed by your search" : "2. Type your search query normally"
                    font.pixelSize: 12
                    color: "#CCFFFFFF"
                }

                Text {
                    text: "3. Results from enabled providers appear in the list"
                    font.pixelSize: 12
                    color: "#CCFFFFFF"
                }

                Text {
                    text: "4. Select a result and press Enter to open"
                    font.pixelSize: 12
                    color: "#CCFFFFFF"
                }
            }
        }

        // Example Searches
        Rectangle {
            width: parent.width - 40
            height: examplesColumn.implicitHeight + 24
            radius: 12
            color: "#3A2A1A"

            Column {
                id: examplesColumn
                anchors.centerIn: parent
                width: parent.width - 24
                spacing: 8

                Text {
                    text: "🔍 Example Searches"
                    font.pixelSize: 14
                    font.weight: Font.Medium
                    color: "#FFFFFF"
                }

                Column {
                    width: parent.width
                    spacing: 4

                    Text {
                        text: "• firefox - Find Firefox in Bazaar"
                        font.pixelSize: 11
                        color: "#CCFFFFFF"
                    }
                    Text {
                        text: "• 2+2 - Calculate with Calculator"
                        font.pixelSize: 11
                        color: "#CCFFFFFF"
                    }
                    Text {
                        text: "• heart - Find heart emoji in Characters"
                        font.pixelSize: 11
                        color: "#CCFFFFFF"
                    }
                    Text {
                        text: "• wifi - Open WiFi settings"
                        font.pixelSize: 11
                        color: "#CCFFFFFF"
                    }
                    Text {
                        text: "• documents - Find in Files"
                        font.pixelSize: 11
                        color: "#CCFFFFFF"
                    }
                }
            }
        }
        }  // End Column
    }  // End ScrollView

    function saveSettings(key, value) {
        if (pluginService) {
            pluginService.savePluginData("gnomeSearchProviders", key, value)
        }
    }

    function loadSettings(key, defaultValue) {
        if (pluginService) {
            return pluginService.loadPluginData("gnomeSearchProviders", key, defaultValue)
        }
        return defaultValue
    }

    function isProviderEnabled(service) {
        const enabled = loadSettings("enabledProviders", [])
        return enabled.length === 0 || enabled.includes(service)
    }

    function updateProviderEnabled(service, enabled) {
        let providers = loadSettings("enabledProviders", [])
        
        if (enabled) {
            if (!providers.includes(service)) {
                providers.push(service)
            }
        } else {
            providers = providers.filter(s => s !== service)
        }
        
        saveSettings("enabledProviders", providers)
    }
}
