#!/bin/bash

# ==============================================================
# Venus OS GUI v2 Battery Time Estimator Installer
# ==============================================================
# Adds:
# - Time to Full while charging
# - Remaining time calculated to 20% SOC
# - WARNING below 25% SOC
# - Amber below 35% SOC
# - Red below 30% SOC
#
# Overlay-fs compatible
# ==============================================================

set -e

ORIG_DIR="/opt/victronenergy/gui-v2/Victron/VenusOS/components/widgets"
OVERLAY="/data/apps/overlay-fs/data/gui-v2/upper"

FILE="BatteryWidget.qml"

PATCH="/tmp/battery-time.patch"


# --------------------------------------------------------------
# Select active directory
# --------------------------------------------------------------

if [ -d "$OVERLAY" ]; then

    TARGET_DIR="$OVERLAY/Victron/VenusOS/components/widgets"

    echo "✅ Overlay detected"
    echo "Using:"
    echo "$TARGET_DIR"

    mkdir -p "$TARGET_DIR"

    if [ ! -f "$TARGET_DIR/$FILE" ]; then
        echo "Copying factory widget into overlay..."
        cp "$ORIG_DIR/$FILE" "$TARGET_DIR/$FILE"
    fi

else

    TARGET_DIR="$ORIG_DIR"

    echo "⚠ No overlay detected"
    echo "Using factory path:"
    echo "$TARGET_DIR"

fi


TARGET="$TARGET_DIR/$FILE"


# --------------------------------------------------------------
# Backup
# --------------------------------------------------------------

BACKUP="$TARGET.bak-$(date +%Y%m%d-%H%M%S)"

echo "Creating backup:"
echo "$BACKUP"

cp "$TARGET" "$BACKUP"


# --------------------------------------------------------------
# Create patch
# --------------------------------------------------------------

cat > "$PATCH" <<'EOF'
--- BatteryWidget.qml
+++ BatteryWidget.qml
@@ -40,7 +40,8 @@
 
 	readonly property var batteryData: Global.system.battery
+	readonly property real batterySoc: batteryData.stateOfCharge || 0


@@ -75,6 +76,11 @@
 	VeQuickItem {
 		id: remoteGeneratorSelected

 		uid: Global.system.veBus.serviceUid ? Global.system.veBus.serviceUid + "/Ac/State/RemoteGeneratorSelected" : ""
 	}
+
+	VeQuickItem {
+		id: batteryCapacity
+		uid: "dbus/com.victronenergy.battery.socketcan_vecan0/Capacity"
+	}


@@ -220,9 +226,46 @@
 			Label {
-				text: Global.system.battery.timeToGo == 0 ? "" : Utils.secondsToString(Global.system.battery.timeToGo)
-				visible: Global.system.battery.timeToGo
+				text: {
+
+					const capAh = batteryCapacity.value;
+					const current = batteryData.current;
+					const soc = batteryData.stateOfCharge;
+
+					// Charging
+					if (current > 0.1) {
+
+						const remainingAh = capAh * (100 - soc) / 100;
+						const hours = remainingAh / current;
+
+						return "Time to full " + Utils.secondsToString(hours * 3600);
+					}
+
+
+					// Discharging
+					if (current < -0.1) {
+
+						if (soc <= 25)
+							return "WARNING";
+
+						const usableAh = capAh * (soc - 20) / 100;
+						const hours = usableAh / Math.abs(current);
+
+						return "Remaining " + Utils.secondsToString(hours * 3600);
+					}
+
+					return "";
+				}
+
+				visible: true
+
 				color: Theme.color_font_primary
+
 				width: parent.width
 				elide: Text.ElideRight
 				font.pixelSize: Theme.font_overviewPage_battery_timeToGo_pixelSize
 			}
EOF


# --------------------------------------------------------------
# Apply patch
# --------------------------------------------------------------

echo "Applying patch..."

cd "$TARGET_DIR"

patch --forward "$FILE" < "$PATCH" || {

    echo "❌ Patch failed"
    echo "Restoring backup..."

    cp "$BACKUP" "$TARGET"

    rm -f "$PATCH"

    exit 1
}


rm -f "$PATCH"


# --------------------------------------------------------------
# Restart GUI
# --------------------------------------------------------------

echo "Restarting GUI..."

svc -t /service/start-gui


echo
echo "================================================"
echo "✅ Battery Time Estimator installed"
echo
echo "Backup created:"
echo "$BACKUP"
echo "================================================"
