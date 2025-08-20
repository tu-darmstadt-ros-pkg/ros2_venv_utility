cmake_minimum_required(VERSION 3.8)
project(ros2_venv_scripts)

# Default to C++17
if(NOT CMAKE_CXX_STANDARD)
  set(CMAKE_CXX_STANDARD 17)
endif()

if(CMAKE_COMPILER_IS_GNUCXX OR CMAKE_CXX_COMPILER_ID MATCHES "Clang")
  add_compile_options(-Wall -Wextra -Wpedantic)
endif()

find_package(ament_cmake REQUIRED)

ament_index_register_resource(
  "ros2_venv_utility_scripts" CONTENT
  "${CMAKE_INSTALL_PREFIX}/lib/${PROJECT_NAME}/scripts")

install(
  PROGRAMS "${CMAKE_SOURCE_DIR}/bash/setup_env.bash"
           "${CMAKE_SOURCE_DIR}/bash/check_venv_compatibility.bash"
           "${CMAKE_SOURCE_DIR}/cmake/post_install_venv.cmake"
  DESTINATION ${CMAKE_INSTALL_PREFIX}/lib/${PROJECT_NAME}/scripts)

ament_package()
