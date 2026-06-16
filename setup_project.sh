#!/bin/bash

# === SIGNAL TRAP ===
trap archive_backup SIGINT 

archive_backup(){
    echo -e "\n[INTERRUPTED] Archiving and cleaning up...";
    tar -czf "attendance_tracker_${input}_archive.tar.gz" "attendance_tracker_${input}" 2>/dev/null;    
    rm -rf "attendance_tracker_${input}";
    echo "Archive created. Incomplete directory removed.";
    exit 1
}


# === USER INPUT ===
while true 
do 
       read -p "Enter project name: " input
     if [ -n "$input" ]
      then 
	      break
     fi 
     echo "there is no input repeat again"
 done 

DIR="attendance_tracker_${input}"

# === DIRECTORY ARCHITECTURE ===
mkdir -p "$DIR/Helpers" "$DIR/reports"
sleep 2

cp "attendance_checker.py" "$DIR"
echo "attendance_checker.py is created in $DIR"

cp "assets.csv" "$DIR/Helpers"
echo "assets.csv is created in $DIR"

cp "config.json" "$DIR/Helpers"
echo "config.json is created in $DIR"

cp "reports.log" "$DIR/reports"
echo "reports.log is created in $DIR"

# === CREATE FILES ===

# === DYNAMIC CONFIGURATION ===
read -p "Do you want to update attendance thresholds? (yes/no): " update_choice

if [[ "$update_choice" == "yes" ]]; then
  read -p "Enter new Warning threshold (default 75): " Warning
  read -p "Enter new Failure threshold (default 50): " Failure

  if [[ "$Warning" =~ ^[0-9]+$ ]] && [[ "$Failure" =~ ^[0-9]+$ ]]; then
    sed -i "s/\"warning\": [0-9]*/\"warning\": $Warning/" "$DIR/Helpers/config.json"
    sed -i "s/\"failure\": [0-9]*/\"failure\": $Failure/" "$DIR/Helpers/config.json"
    echo "Thresholds updated successfully."
  else
    echo "[WARNING] Numbers are only allowed for Thresholds. Keeping default thresholds."
  fi
fi

# === ENVIRONMENT VALIDATION ===
echo -e "\n--- Health Check ---"
if python3 --version 2>/dev/null; then
  echo "[OK] Python3 is installed."
else
  echo "[WARNING] Python3 is NOT installed."
fi

# Verify directory structure
echo -e "\n--- Directory Structure Check ---"
for path in "$DIR/attendance_checker.py" "$DIR/Helpers/assets.csv" "$DIR/Helpers/config.json" "$DIR/reports/reports.log"; do
  if [[ -f "$path" ]]; then
    echo "[OK] $path"
  else
    echo "[MISSING] $path"
  fi
done

echo -e "\n[DONE] Project '$DIR' created successfully!"
