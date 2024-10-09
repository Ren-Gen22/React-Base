#!/bin/bash

check_node_npm() {
  # Check if Node.js is installed
  if command -v node >/dev/null 2>&1; then
    echo "Node.js is installed: $(node -v)"
  else
    echo "Node.js is not installed"
  fi

  # Check if npm is installed
  if command -v npm >/dev/null 2>&1; then
    echo "npm is installed: $(npm -v)"
  else
    echo "npm is not installed"
  fi
}

# Call the function
check_node_npm
