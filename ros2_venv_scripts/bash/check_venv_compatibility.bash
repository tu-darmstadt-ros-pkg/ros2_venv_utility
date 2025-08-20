REQ_FILE="requirements.txt"
LOGFILE="setup_env.log"

cd $1

if [[ ! -d "py_venv" ]]; then
    echo "ERROR: No venv found at $1/py_venv"
    exit 2
fi

source "py_venv/bin/activate"
# Capture dry-run output to check if any new or packages with different versions would be installed
output=$(pip3 install --dry-run -r requirements.txt 2>&1)
deactivate

# Extract the last line
last_line=$(echo "$output" | tail -n 1)

if [[ "$last_line" == "Would install"* ]]; then
    echo -e "WARNING: The package venv might not be compatible to the current system-interpreter-package-configuration:\n$last_line\nPlease update the venv manually or run hector update if you encounter issues."
    exit 1
else
    exit 0
fi
