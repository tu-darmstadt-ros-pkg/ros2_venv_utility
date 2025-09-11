import subprocess
from ament_index_python.resources import get_resource
from ament_index_python.packages import get_package_share_directory
import sys
import os


def check_venv_compatibility(pkg_name: str) -> bool:
    venv_dir = os.path.join(get_package_share_directory(pkg_name), "..", "..", "venv")

    compatibility_script_path = os.path.join(
        get_resource("ros2_venv_utility_scripts", "ros2_venv_scripts")[0],
        "check_venv_compatibility.bash",
    )
    compatibility_result = subprocess.run(
        ["bash", compatibility_script_path, venv_dir, pkg_name],
        capture_output=True,
        text=True,
    )

    if compatibility_result.returncode == 1:
        print("\033[93m" + compatibility_result.stdout.strip() + "\033[0m")

    if compatibility_result.returncode == 2:
        print("\033[91m" + compatibility_result.stdout.strip() + "\033[0m")
        sys.exit(1)


def add_venv_to_current_env(pkg_name: str) -> dict:
    """
    Build environment dict for launching node in a virtualenv,
    preserving existing environment variables.
    """
    env = os.environ.copy()
    venv_dir = os.path.join(get_package_share_directory(pkg_name), "..", "..", "venv")
    venv_path = os.path.join(venv_dir, pkg_name)

    check_venv_compatibility(pkg_name)

    python_version = f"python{sys.version_info.major}.{sys.version_info.minor}"
    site_packages = os.path.join(venv_path, "lib", python_version, "site-packages")

    env["VIRTUAL_ENV"] = venv_path
    env["PATH"] = os.path.join(venv_path, "bin") + os.pathsep + env.get("PATH", "")
    env["PYTHONPATH"] = site_packages + os.pathsep + env.get("PYTHONPATH", "")
    return env
