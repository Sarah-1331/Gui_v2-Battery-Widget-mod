# Venus OS Battery Time Estimator

This patch adds a native battery time estimator to the GUI v2 battery widget.

## Features

- Displays **Time to Full** while charging.
- Displays **Remaining Time** while discharging, calculated down to **20% SOC**.
- Shows **WARNING** at or below 20% SOC instead of estimating runtime further.
- Changes the time text color to amber below 35% SOC and red below 30% SOC.
- Uses the battery capacity reported by the BMS; no additional services or drivers are required.

## Installation

Generate or obtain the patch file and apply it to your own copy of `BatteryWidget.qml`:


SSH into your Venus OS device and run the following commands:

# Download the installer
wget https://raw.githubusercontent.com/Sarah-1331/Gui_v2-Battery-Widget-mod/blob/main/install.sh -O /data/install_widgets.sh

# Make it executable
chmod +x /data/install.sh

# Run the installer
bash /data/install.sh
🔹 Restore the Originals 🛠️
If you ever want to revert to the original system files:

# Download the restore script

wget https://raw.githubusercontent.com/Sarah-1331/Gui_v2-Battery-Widget-mod/blob/main/remove.sh -O /data/remove.sh

# Run it to restore backups
bash /data/remove.sh
This restores all backed-up QMLs (widgets) to their original state safely. 🕒

Notes 📝
All backups are timestamped and stored next to the original files.
The installer only modifies the widgets; other GUI files are untouched.
Works safely on Venus OS without overlay-fs.
