 Venus OS Battery Time Estimator

This patch adds a native battery time estimator to the GUI v2 battery widget.

## Features

- Displays **Time to Full** while charging.
- Displays **Remaining Time** while discharging, calculated down to **20% SOC**.
- Shows **WARNING** at or below 20% SOC instead of estimating runtime further.
- Changes the time text colour:
  - Amber below 35% SOC
  - Red below 30% SOC
- Uses the battery capacity reported by the BMS.
- No dbus-serialbattery installation required.

## Installation

SSH into your Venus OS device.

Download the installer:

```bash
wget https://raw.githubusercontent.com/Sarah-1331/Gui_v2-Battery-Widget-mod/main/install.sh -O /data/install.sh

Download the patch file:

wget https://raw.githubusercontent.com/Sarah-1331/Gui_v2-Battery-Widget-mod/main/battery-time-remaining.patch -O /data/battery-time-remaining.patch

Make the installer executable:

chmod +x /data/install.sh

Run the installer:

bash /data/install.sh

The installer will:

Detect overlay-fs if present.
Create a timestamped backup of BatteryWidget.qml.
Apply the battery estimator patch.
Restart the GUI.
Restore

To restore the original widget:

Download the restore script:

wget https://raw.githubusercontent.com/Sarah-1331/Gui_v2-Battery-Widget-mod/main/remove.sh -O /data/remove.sh

Make executable:

chmod +x /data/remove.sh

Run:

bash /data/remove.sh

The restore script will:

Find the latest BatteryWidget.qml backup.
Restore the original file.
Restart the GUI.
Notes
Backups are timestamped and stored next to the modified file.
Only BatteryWidget.qml is modified.
No other Venus OS GUI files are changed.
The patch method allows the modification to be reviewed and applied without distributing the full modified QML file.

One extra thing I would change in your repo naming:

Instead of:


remove.sh


I would call it:


restore.sh


because it matches what it actually does and avoids confusion with "uninstall/delete". Your `venus_custom_s
