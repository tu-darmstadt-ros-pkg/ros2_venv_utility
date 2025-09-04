# ROS2 Virtual Environment Utility

A ROS2 package for managing isolated Python virtual environments for individual ROS2 packages.

## Overview

The `ros2_venv_utility` provides tools to create and manage package-specific Python virtual environments that integrate with ROS2 launch files. This allows each ROS2 package to have its own isolated Python dependencies while still accessing system ROS2 packages.

## Package Components

This utility consists of two ROS2 packages:

### 1. `ros2_venv_scripts`
Contains bash scripts for virtual environment management:
- **`setup_env.bash`** - Creates and populates virtual environments
- **`check_venv_compatibility.bash`** - Validates virtual environment compatibility
- **`post_install_venv.cmake`** - CMake integration for post-installation setup

### 2. `ros2_venv_launch_util`
Provides Python utilities for launch file integration:
- **`launch_util.py`** - Functions to integrate virtual environments with ROS2 launch files

## Installation

### Build Instructions

1. Clone this repository into your ROS2 workspace:
   ```bash
   cd ~/your_ros2_ws/src
   git clone git@git.sim.informatik.tu-darmstadt.de:hector/ros2_venv_utility.git
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

### Step 1: Convert to ament_cmake Package

Update your `package.xml` to use `ament_cmake` build type:

```xml
<buildtool_depend>ament_cmake</buildtool_depend>

<depend>ament_cmake</depend>
<depend>rclpy</depend>
<!-- your other dependencies -->
<depend>ros2_venv_scripts</depend>

<export>
  <build_type>ament_cmake</build_type>
</export>
```

### Step 2: Create/ Change CMakeLists.txt

Create/ Change a `CMakeLists.txt` with virtual environment integration:

```cmake
cmake_minimum_required(VERSION 3.8)
project(your_package_name)

# Find dependencies
find_package(ament_cmake REQUIRED)
find_package(ament_cmake_python REQUIRED)
find_package(ros2_venv_scripts REQUIRED)

# Install Python package
ament_python_install_package(${PROJECT_NAME})

# Install Python executables
install(PROGRAMS 
  your_package_name/your_node.py
  DESTINATION lib/${PROJECT_NAME}
)

# Virtual environment setup with configurable skip option
set(SKIP_VENV
    OFF
    CACHE BOOL "Whether to skip the venv setup. Should be True for distribution builds.")

if(SKIP_VENV)
  message(STATUS "Skipping venv setup")
else()
  ament_index_get_resource(venv_util_scripts_path "ros2_venv_utility_scripts" "ros2_venv_scripts")
  install(FILES "${CMAKE_CURRENT_SOURCE_DIR}/requirements.txt" DESTINATION "venv")
  install(SCRIPT "${venv_util_scripts_path}/post_install_venv.cmake")
endif()

ament_package()
```

### Step 3: Create Requirements File

Create a `requirements.txt` file in your package root.


### Step 4: Update Launch Files

For **launch packages**, add `ros2_venv_launch_util` dependency and use the virtual environment:

**package.xml** (launch package):
```xml
<depend>ros2_venv_launch_util</depend>
```

**Launch file**:
```python
from launch import LaunchDescription
from launch_ros.actions import Node
from ament_index_python.packages import get_package_share_directory
from ros2_venv_launch_util.launch_util import add_venv_to_current_env

def generate_launch_description():
    pkg_share = get_package_share_directory('your_package_name')
    env = add_venv_to_current_env(pkg_share)
    
    return LaunchDescription([
        Node(
            package='your_package_name',
            executable='your_node.py',
            name='your_node_name',
            env=env,  # Virtual environment is applied here
            # ... other parameters
        )
    ])
```

## Authors

- Marek Daniv (marekdaniv@googlemail.com)

