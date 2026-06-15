#!/bin/bash

# === SIGNAL TRAP ===
trap 'echo -e "\n[INTERRUPTED] Archiving and cleaning up..."; \
      tar -czf "attendance_tracker_${input}_archive.tar.gz" "attendance_tracker_${input}" 2>/dev/null; \
      rm -rf "attendance_tracker_${input}"; \
      echo "Archive created. Incomplete directory removed."; \
      exit 1' SIGINT

# === USER INPUT ===
read -p "Enter project name: " input

DIR="attendance_tracker_${input}"

# === DIRECTORY ARCHITECTURE ===
mkdir -p "$DIR/Helpers" "$DIR/reports"
sleep 2

# === CREATE FILES ===
cat attendance_checker.py > "$DIR/attendance_checker.py" 2>/dev/null || echo "# attendance_checker.py" > "$DIR/attendance_checker.py"
cat assets.csv > "$DIR/Helpers/assets.csv" 2>/dev/null || echo "student_id,name,attendance" > "$DIR/Helpers/assets.csv"
cat reports.log > "$DIR/reports/reports.log" 2>/dev/null || echo "" > "$DIR/reports/reports.log"

# === CONFIG.JSON ===
cat > "$DIR/Helpers/config.json" <<EOF
{
  "warning_threshold": 75,
  "failure_threshold": 50
}
EOF

# === DYNAMIC CONFIGURATION ===
read -p "Do you want to update attendance thresholds? (yes/no): " update_choice

if [[ "$update_choice" == "yes" ]]; then
  read -p "Enter new Warning threshold (default 75): " warning
  read -p "Enter new Failure threshold (default 50): " failure

  if [[ "$warning" =~ ^[0-9]+$ ]] && [[ "$failure" =~ ^[0-9]+$ ]]; then
    sed -i "s/\"warning_threshold\": [0-9]*/\"warning_threshold\": $warning/" "$DIR/Helpers/config.json"
    sed -i "s/\"failure_threshold\": [0-9]*/\"failure_threshold\": $failure/" "$DIR/Helpers/config.json"
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
