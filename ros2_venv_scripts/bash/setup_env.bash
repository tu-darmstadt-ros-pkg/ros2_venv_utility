REQ_FILE="requirements.txt"
LOGFILE="setup_env.log"

cd $1

#Clean up old virtual environment if it exists
rm -rf "py_venv"

# Venv has access to system site packages
python3 -m venv "py_venv" --system-site-packages

if [[ ! -f "$REQ_FILE" ]]; then
    tee -a "$LOGFILE" "Error: $REQ_FILE not found!"
    exit 1
fi

source "py_venv/bin/activate"
pip3 install -r $2 > "$LOGFILE"
deactivate
