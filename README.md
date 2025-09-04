# ROS2 Virtual Environment Utility

A comprehensive ROS2 package for managing isolated Python virtual environments for individual ROS2 packages, ensuring dependency isolation while maintaining seamless ROS2 integration.

## Overview

The `ros2_venv_utility` provides tools to create and manage package-specific Python virtual environments that integrate seamlessly with ROS2 launch files. This allows each ROS2 package to have its own isolated Python dependencies while still accessing system ROS2 packages.

## Package Components

This utility consists of two complementary ROS2 packages:

### 1. `ros2_venv_scripts`
Contains bash scripts for virtual environment management:
- **`setup_env.bash`** - Creates and populates virtual environments
- **`check_venv_compatibility.bash`** - Validates virtual environment compatibility
- **`post_install_venv.cmake`** - CMake integration for post-installation setup

### 2. `ros2_venv_launch_util`
Provides Python utilities for launch file integration:
- **`launch_util.py`** - Functions to integrate virtual environments with ROS2 launch files

## Key Features

- ✅ **Isolated Dependencies**: Each ROS2 package maintains its own Python environment
- ✅ **System Integration**: Virtual environments retain access to ROS2 system packages via `--system-site-packages`
- ✅ **Automatic Management**: Virtual environments are created and managed automatically
- ✅ **Compatibility Checking**: Automatic detection and warning of package conflicts
- ✅ **Launch Integration**: Seamless integration with ROS2 launch files
- ✅ **Zero Configuration**: Works out-of-the-box once integrated

## Installation

### Prerequisites
- ROS2 (tested with ROS2 Humble/Iron/Jazzy)
- Python 3.8+
- colcon build system

### Build Instructions

1. Clone this repository into your ROS2 workspace:
   ```bash
   cd ~/your_ros2_ws/src
   git clone &lt;repository_url&gt; ros2_venv_utility
   ```

2. Build the packages:
   ```bash
   cd ~/your_ros2_ws
   colcon build --packages-select ros2_venv_scripts ros2_venv_launch_util
   ```

3. Source your workspace:
   ```bash
   source install/setup.bash
   ```

## Integration Guide

To integrate virtual environment support with an existing ROS2 package:

### Step 1: Update Package Dependencies

Add dependencies to your package's `package.xml`:

```xml
&lt;depend&gt;ros2_venv_launch_util&lt;/depend&gt;
&lt;depend&gt;ros2_venv_scripts&lt;/depend&gt;
```

### Step 2: Include Requirements File

For **Python packages** (`ament_python`), update your `setup.py`:

```python
setup(
    # ... other setup parameters
    data_files=[
        ("share/ament_index/resource_index/packages", ["resource/" + package_name]),
        ("share/" + package_name, ["package.xml"]),
        ("share/" + package_name + "/venv", ["requirements.txt"]),  # Add this line
    ],
    # ... rest of setup
)
```

### Step 3: Create Requirements File

Create a `requirements.txt` file in your package root with your Python dependencies:

```txt
numpy&lt;2
opencv-python&gt;=4.8.1.78
ultralytics==8.3.168
# ... other dependencies
```

### Step 4: Update Launch Files

Modify your launch files to use the virtual environment:

```python
from launch import LaunchDescription
from launch_ros.actions import Node
from ament_index_python.packages import get_package_share_directory
from ros2_venv_launch_util.launch_util import add_venv_to_current_env

def generate_launch_description():
    # Get package share directory and setup virtual environment
    pkg_share = get_package_share_directory('your_package_name')
    venv_env = add_venv_to_current_env(pkg_share)
    
    return LaunchDescription([
        Node(
            package='your_package_name',
            executable='your_node',
            name='your_node_name',
            env=venv_env,  # Add this line to use virtual environment
            # ... other node parameters
        )
    ])
```

## How It Works

### Virtual Environment Structure

When you launch your ROS2 nodes, the system creates this directory structure:

```
&lt;install_prefix&gt;/your_package/
├── share/your_package/
│   └── venv/
│       └── requirements.txt          # Your Python dependencies
└── venv/                             # Virtual environment root
    ├── py_venv/                      # Actual Python virtual environment
    │   ├── bin/
    │   │   ├── activate              # Activation script
    │   │   ├── python3               # Python executable
    │   │   └── pip3                  # Pip executable
    │   └── lib/
    │       └── python3.X/
    │           └── site-packages/    # Your isolated packages
    ├── requirements.txt              # Copy of requirements
    └── setup_env.log                 # Installation log
```

### Execution Flow

1. **Launch Detection**: When launching nodes, `add_venv_to_current_env()` is called
2. **Compatibility Check**: System verifies existing virtual environment compatibility
3. **Environment Creation**: If needed, creates virtual environment with `--system-site-packages`
4. **Dependency Installation**: Installs packages from `requirements.txt`
5. **Environment Setup**: Configures `VIRTUAL_ENV`, `PATH`, and `PYTHONPATH`
6. **Node Execution**: Runs ROS2 nodes within the isolated environment

## Example Use Cases

### Computer Vision Packages
Perfect for packages using specific versions of:
- OpenCV
- TensorFlow/PyTorch
- Ultralytics YOLO
- scikit-image

### Machine Learning Packages
Ideal for isolating:
- Different ML framework versions
- Specific model dependencies
- Training vs. inference environments

### Data Processing Packages
Great for managing:
- NumPy/SciPy versions
- Pandas compatibility
- Specialized data processing libraries

## Troubleshooting

### Virtual Environment Not Created
**Error**: `ERROR: No venv found at &lt;path&gt;/py_venv`

**Solution**: The virtual environment will be created on first launch. If it fails:
1. Check that `requirements.txt` is properly installed
2. Ensure write permissions in the install directory
3. Manually create: `mkdir -p &lt;install_path&gt;/venv`

### Package Conflicts
**Warning**: `WARNING: The package venv might not be compatible...`

**Solution**: Update your virtual environment:
1. Delete existing: `rm -rf &lt;install_path&gt;/venv/py_venv`
2. Rebuild package: `colcon build --packages-select your_package`
3. Launch again to recreate environment

### Import Errors
**Error**: `ModuleNotFoundError` for your dependencies

**Solution**: 
1. Check `setup_env.log` for installation errors
2. Verify `requirements.txt` format
3. Test manual installation:
   ```bash
   source &lt;install_path&gt;/venv/py_venv/bin/activate
   pip install -r &lt;install_path&gt;/venv/requirements.txt
   ```

## Compatibility

| ROS2 Distribution | Status | Python Version |
|-------------------|--------|----------------|
| Humble           | ✅ Tested | 3.8+ |
| Iron             | ✅ Tested | 3.8+ |
| Jazzy            | ✅ Tested | 3.8+ |

## Contributing

1. Create a feature branch: `git checkout -b feature/your-feature`
2. Make your changes
3. Test with a sample ROS2 package
4. Submit a pull request

## License

[Add your license here]

## Authors

- Marek Daniv (marekdaniv@googlemail.com)

---

*This utility was successfully tested with packages like `yolo_ros`, providing isolated environments for computer vision and machine learning workloads.*
