#!/bin/bash
# Venus OS Widgets Direct Installer (NO overlay-fs)
# Safely edits factory QML files with timestamped backups in-place

# ------------------------------
# Overlay-aware widgets path logic
# ------------------------------



set -e

ORIG_WIDGET_DIR="/opt/victronenergy/gui-v2/Victron/VenusOS/components/widgets"
OVERLAY_UPPER="/data/apps/overlay-fs/data/gui-v2/upper"
OVERLAY_WIDGET_DIR="$OVERLAY_UPPER/Victron/VenusOS/components/widgets"

FILES=("BatteryWidget")

if [ -d "$OVERLAY_UPPER" ]; then
    echo "✅ Overlay upper found, using overlay widgets."

    # Ensure full directory structure exists
    mkdir -p "$OVERLAY_WIDGET_DIR"

    # Copy BOTH widget files if missing
    for file in "${FILES[@]}"; do
        if [ ! -f "$OVERLAY_WIDGET_DIR/$file" ]; then
            cp "$ORIG_WIDGET_DIR/$file" "$OVERLAY_WIDGET_DIR/$file" || {
                echo "❌ Failed to copy $file to overlay"
                exit 1
            }
            echo "📝 Copied $file to overlay."
        else
            echo "ℹ $file already exists in overlay."
        fi
    done

    TARGET_DIR="$OVERLAY_WIDGET_DIR"
else
    echo "⚠ Overlay not found, using original widgets."
    TARGET_DIR="$ORIG_WIDGET_DIR"
fi

TIMESTAMP="$(date +%Y%m%d-%H%M%S)"

echo "🚀 Starting Venus OS Widgets Direct Installer (no overlay-fs)"

# ------------------------------
# 1️⃣ Verify target directory
# ------------------------------
if [ ! -d "$TARGET_DIR" ]; then
    echo "❌ Target directory not found: $TARGET_DIR"
    exit 1
fi

cd "$TARGET_DIR"

# ------------------------------
# 2️⃣ Backup originals (in-place)
# ------------------------------
for file in "${FILES[@]}"; do
    if [ ! -f "$file" ]; then
        echo "❌ Missing file: $file"
        exit 1
    fi

    BACKUP="${file}.bak-${TIMESTAMP}"

    if [ ! -f "$BACKUP" ]; then
        cp "$file" "$BACKUP"
        echo "🕒 Backup created: $BACKUP"
    else
        echo "ℹ Backup already exists: $BACKUP"
    fi
done

# ------------------------------
# 3️⃣ Patch BatteryWidget.qml
#   
# ------------------------------
Battery="BatteryWidget.qml"

awk -v block="$(cat <<'EOB'

//start edit//
// AC INPUT CURRENT (real system value)
VeQuickItem {
    id: acCurrent
    uid: "dbus/com.victronenergy.system/Ac/Grid/L1/Current"
}

// VOLTAGE fallback (VE.Bus inverter output)
VeQuickItem {
    id: acVoltage
    uid: "dbus/com.victronenergy.vebus.ttyS4/Ac/Out/L1/V"
}

// FREQUENCY (VE.Bus output)
VeQuickItem {
    id: acFrequency
    uid: "dbus/com.victronenergy.vebus.ttyS4/Ac/Out/L1/F"
}


// SAFE OVERLAY (DOES NOT BREAK TILE MODES)
Item {
    anchors.fill: parent
    z: 999

    Label {
        text:
            (acVoltage.valid ? acVoltage.value.toFixed(0) + " V" : "--- V") + "  " +
            (acCurrent.valid ? acCurrent.value.toFixed(1) + " A" : "--.- A") + "  " +
            (acFrequency.valid ? acFrequency.value.toFixed(1) + " Hz" : "--.- Hz")

        font.pixelSize: 16
        color: Theme.color_font_primary

        anchors {
            horizontalCenter: parent.horizontalCenter
            bottom: parent.bottom
            bottomMargin: Theme.geometry_baseline_spacing
        }

        visible: root.inputOperational &&
                 root.input &&
                 root.input.connected
    }
}
//end edit//
EOB
)" '
/extraContentLoader\.sourceComponent: ThreePhaseDisplay/ {flag=1}
flag && /^\s*}\s*$/ {print; print block; flag=0; next}
1
' "$ACINPUT" > "${ACINPUT}.tmp" && mv "${ACINPUT}.tmp" "$ACINPUT"

echo "✅ BatteryWidget.qml patched"


# 5️⃣ Restart GUI
echo "Restarting GUI..."
svc -t /service/start-gui

echo "🎉 Done! Factory files modified safely with timestamped backups."
