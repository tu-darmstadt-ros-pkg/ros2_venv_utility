LOGFILE="setup_env.log"
PROJECT_NAME=$(basename "$1")

# <package_install_dir>/venv
cd $1/venv

# Clean up old virtual environment if it exists
rm -rf "$PROJECT_NAME"
:> $LOGFILE

if [[ $2 == "--isolated" ]]; then
    # Create a fully independent virtual environment
    echo "Creating an isolated virtual environment in $PROJECT_NAME" >> $LOGFILE
    python3 -m venv "$PROJECT_NAME"
else
    # Create a virtual environment with access to system site packages
    echo "Creating an virtual environment with access to system packages in $PROJECT_NAME" >> $LOGFILE
    python3 -m venv "$PROJECT_NAME" --system-site-packages
fi

if [[ ! -f "requirements.txt" ]]; then
    echo "Error: $1/venv/requirements.txt not found!" >> $LOGFILE
    exit 1
fi

source "$PROJECT_NAME/bin/activate" || exit 1
pip3 install -r requirements.txt >> "$LOGFILE"
deactivate
