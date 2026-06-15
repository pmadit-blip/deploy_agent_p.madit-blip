#!/bin/bash

# === SIGNAL TRAP ===
trap 'echo -e "\n[INTERRUPTED] Archiving and cleaning up..."; \
      tar -czf "attendance_tracker_${input}_archive.tar.gz" "attendance_tracker_${input}" 2>/dev/null; \
      rm -rf "attendance_tracker_${input}"; \
      echo "Archive created. Incomplete directory removed."; \
      exit 1' SIGINT

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

# === CREATE FILES ===
touch $DIR/attendence_checker.py $DIR/Helpers/assets.csv $DIR/Helpers/config.json $DIR/reports/reports.log

cat > "$DIR/attendance_checker.py" << 'PYEOF' 
import csv
import json
import os
from datetime import datetime
def run_attendance_check():
# 1. Load Config
with open('Helpers/config.json', 'r') as f:
config = json.load(f)
# 2. Archive old reports.log if it exists
if os.path.exists('reports/reports.log'):
timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
os.rename('reports/reports.log',
f'reports/reports_{timestamp}.log.archive')
# 3. Process Data
with open('Helpers/assets.csv', mode='r') as f, open('reports/reports.log',
'w') as log:
reader = csv.DictReader(f)
total_sessions = config['total_sessions']
log.write(f"--- Attendance Report Run: {datetime.now()} ---\n")
for row in reader:
name = row['Names']
email = row['Email']
attended = int(row['Attendance Count'])
# Simple Math: (Attended / Total) * 100
attendance_pct = (attended / total_sessions) * 100
message = ""
if attendance_pct < config['thresholds']['failure']:
message = f"URGENT: {name}, your attendance is {attendance_pct:.1f}
%. You will fail this class."
elif attendance_pct < config['thresholds']['warning']:
message = f"WARNING: {name}, your attendance is
{attendance_pct:.1f}%. Please be careful."
if message:
if config['run_mode'] == "live":
log.write(f"[{datetime.now()}] ALERT SENT TO {email}: {message}
\n")
print(f"Logged alert for {name}")
else:
print(f"[DRY RUN] Email to {email}: {message}")
if __name__ == "__main__":
run_attendance_check()
PYEOF

cat > "$DIR/Helpers/assets.csv" << 'CSVEOF'
 Email                              Names                Attendance Count              Absence Count
alice@example.com                       Alice Johnson            14                                1
bob@example.com                         Bob Smith                 7                                8
charlie@example.com                    Charlie Davis              4                               11
diana@example.com                      Diana Prince              15                                0
CSVEOF

cat > "$DIR/Helpers/config.json" << 'JSONEOF'
{
    "thresholds": {
        "warning": 75,
        "failure": 50
    },
    "run_mode": "live",
    "total_sessions": 15
}
JSONEOF

 cat > "$DIR/reports/reports.log" << 'LOGEOF' 
    --- Attendance Report Run: 2026-02-06 18:10:01.468726 ---
[2026-02-06 18:10:01.469363] ALERT SENT TO bob@example.com: URGENT: Bob Smith, your
attendance is 46.7%. You will fail this class.
[2026-02-06 18:10:01.469424] ALERT SENT TO charlie@example.com: URGENT: Charlie
Davis, your attendance is 26.7%. You will fail this class.
LOGEOF

# === DYNAMIC CONFIGURATION ===
read -p "Do you want to update attendance thresholds? (yes/no): " update_choice

if [[ "$update_choice" == "yes" ]]; then
  read -p "Enter new Warning threshold (default 75): " Warning
  read -p "Enter new Failure threshold (default 50): " Failure

  if [[ "$Warning" =~ ^[0-9]+$ ]] && [[ "$Failure" =~ ^[0-9]+$ ]]; then
    sed -i "s/\"warning_threshold\": [0-9]*/\"warning_threshold\": $Warning/" "$DIR/Helpers/config.json"
    sed -i "s/\"failure_threshold\": [0-9]*/\"failure_threshold\": $Failure/" "$DIR/Helpers/config.json"
    echo "Thresholds updated successfully."
  else
    echo "[WARNING] Invalid input. Keeping default thresholds."
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
