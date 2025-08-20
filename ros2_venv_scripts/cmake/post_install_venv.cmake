execute_process(
  COMMAND
    bash "${CMAKE_CURRENT_LIST_DIR}/setup_env.bash"
    "${CMAKE_INSTALL_PREFIX}/venv/"
    "${CMAKE_INSTALL_PREFIX}/venv/requirements.txt")
