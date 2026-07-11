#!/bin/bash

set -e

ORIG_DIR="/opt/victronenergy/gui-v2/Victron/VenusOS/components/widgets"
OVERLAY="/data/apps/overlay-fs/data/gui-v2/upper"
FILE="BatteryWidget.qml"

# Pick active location
if [ -d "$OVERLAY" ]; then
    TARGET_DIR="$OVERLAY/Victron/VenusOS/components/widgets"
    echo "✅ Overlay detected"
else
    TARGET_DIR="$ORIG_DIR"
    echo "⚠ No overlay detected"
fi

mkdir -p "$TARGET_DIR"

TARGET="$TARGET_DIR/$FILE"

# Copy factory file to overlay if needed
if [ ! -f "$TARGET" ]; then
    cp "$ORIG_DIR/$FILE" "$TARGET"
fi

# Backup
cp "$TARGET" "$TARGET.bak-$(date +%Y%m%d-%H%M%S)"

echo "Applying Battery Widget patch..."

cd "$TARGET_DIR"

patch --forward "$FILE" < /path/to/battery-time-remaining.patch

echo "Restarting GUI..."
svc -t /service/start-gui

echo "✅ Battery time remaining installed"
