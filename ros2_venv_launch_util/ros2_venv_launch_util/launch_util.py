import subprocess
from ament_index_python.resources import get_resource
import sys
import os


def check_venv_compatibility(venv_dir: str) -> bool:
    compatibility_script_path = os.path.join(
        get_resource("ros2_venv_utility_scripts", "ros2_venv_scripts")[0],
        "check_venv_compatibility.bash",
    )
    compatibility_result = subprocess.run(
        ["bash", compatibility_script_path, venv_dir], capture_output=True, text=True
    )

    if compatibility_result.returncode == 1:
        print("\033[93m" + compatibility_result.stdout.strip() + "\033[0m")

    if compatibility_result.returncode == 2:
        print("\033[91m" + compatibility_result.stdout.strip() + "\033[0m")
        sys.exit(1)


def add_venv_to_current_env(pkg_share: str) -> dict:
    """
    Build environment dict for launching node in a virtualenv,
    preserving existing environment variables.
    """
    env = os.environ.copy()
    venv_dir = os.path.join(pkg_share, "..", "..", "venv")
    venv_path = os.path.join(venv_dir, "py_venv")

    check_venv_compatibility(venv_dir)

    python_version = f"python{sys.version_info.major}.{sys.version_info.minor}"
    site_packages = os.path.join(venv_path, "lib", python_version, "site-packages")

    env["VIRTUAL_ENV"] = venv_path
    env["PATH"] = os.path.join(venv_path, "bin") + os.pathsep + env.get("PATH", "")
    env["PYTHONPATH"] = site_packages + os.pathsep + env.get("PYTHONPATH", "")
    return env
