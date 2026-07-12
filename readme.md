# Venus OS Battery Time Estimator

This modification adds a native battery time estimator to the GUI v2 battery widget.

## Features

- Displays **Time to Full** while charging.
- Displays **Remaining Time** while discharging, calculated down to **20% SOC**.
- Shows **WARNING** at or below **25% SOC** instead of estimating runtime further.
- Changes the time text colour:
  - Amber below **35% SOC**
  - Red below **30% SOC**
- Uses the battery capacity reported by the BMS.
- No dbus-serialbattery installation required.

---

# Installation

SSH into your Venus OS device.

Download the installer:

```bash
wget https://raw.githubusercontent.com/Sarah-1331/Gui_v2-Battery-Widget-mod/main/install.sh -O /data/install.sh
```

Make executable:

```bash
chmod +x /data/install.sh
```

Run installer:

```bash
bash /data/install.sh
```

The installer will:

- Detect overlay-fs if present.
- Copy the factory QML to overlay if required.
- Create a timestamped backup of `BatteryWidget.qml`.
- Apply the battery time estimator modification.
- Restart the Venus OS GUI.

---

# Restore

To restore the original widget:

Download the restore script:

```bash
wget https://raw.githubusercontent.com/Sarah-1331/Gui_v2-Battery-Widget-mod/main/remove.sh -O /data/remove.sh
```

Make executable:

```bash
chmod +x /data/remove.sh
```

Run:

```bash
bash /data/remove.sh
```

The restore script will:

- Detect the correct widget location.
- Find the latest `BatteryWidget.qml` backup.
- Restore the original file.
- Restart the Venus OS GUI.

---

# Notes

- Backups are timestamped and stored next to the modified QML file.
- Only `BatteryWidget.qml` is modified.
- No other Venus OS GUI files are changed.
- The installer is self-contained; no separate patch file download is required.
- The modification uses the BMS reported capacity and current values directly from D-Bus.
