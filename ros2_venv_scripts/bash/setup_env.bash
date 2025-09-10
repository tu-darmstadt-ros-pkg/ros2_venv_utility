LOGFILE="setup_env.log"
PROJECT_NAME=$(basename "$1")

# <package_install_dir>/venv
cd $1/venv

# Clean up old virtual environment if it exists
rm -rf "$PROJECT_NAME"

if [[$2 -eq "--isolated"]]; then
    # Create a fully independent virtual environment
    tee -a "$LOGFILE" "Creating an isolated virtual environment in $PROJECT_NAME"
    python3 -m venv "$PROJECT_NAME"
else
    # Create a virtual environment with access to system site packages
    python3 -m venv "$PROJECT_NAME" --system-site-packages
fi

if [[ ! -f "requirements.txt" ]]; then
    tee -a "$LOGFILE" "Error: $1/venv/requirements.txt not found!"
    exit 1
fi

source "$PROJECT_NAME/bin/activate"
pip3 install -r requirements.txt > "$LOGFILE"
deactivate
