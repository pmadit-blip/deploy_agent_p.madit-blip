# Attendance Tracker Project Bootstrap

## Overview
This shell script automates the creation of a Student Attendance Tracker workspace, configures settings, and handles system signals gracefully.

## How to Run the Script

1. Clone repository like;
   git clone https://github.com/pmadit-blip/deploy_agent_p.madit-blip.git

2. Navigate into the same directory:
   cd deploy_agent_p.madit-blip

3. Then give the script execute permission:
   chmod +x setup_project.sh

4. Run the script:
   ./setup_project.sh

5. Follow the prompts:
   - Enter a project name
   - Choose whether to update attendance thresholds, yes/no write yes then
   - Enter Warning threshold (default: 75)
   - Enter Failure threshold (default: 50)

## How to Trigger the Archive Feature
The archive feature is triggered by pressing **Ctrl+C** during script execution.

When interrupted:
- The script catches the SIGINT signal
- Bundles the current project state into a .tar.gz archive named attendance_tracker_{input}_archive.tar.gz
- Deletes the incomplete directory to keep the workspace clean

## Requirements
- Bash shell
- Python3 installed on the system

## Directory Structure Created
attendance_tracker_{input}/
├── attendance_checker.py
├── Helpers/
│   ├── assets.csv
│   └── config.json
└── reports/
    └── reports.log
