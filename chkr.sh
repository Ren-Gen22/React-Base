#!/bin/bash

# Default variables
REPO_DIR="$HOME/Desktop/Abhi/proj/webPi/base-site"  # Default directory
LAST_COMMIT_FILE="$REPO_DIR/last_commit_local.txt"
LOG_FILE="$REPO_DIR/build_log.txt"
CLEAN=false
BUILD_ONLY=false
SERVE_ONLY=false

# Function to log messages
log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Parse command line arguments before anything else
while [[ "$#" -gt 0 ]]; do
  case "$1" in
    --clean) CLEAN=true ;;
    --build) BUILD_ONLY=true ;;
    --serve) SERVE_ONLY=true ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
  shift
done

# Ensure the directory exists
if [ ! -d "$REPO_DIR" ]; then
  echo "Directory $REPO_DIR does not exist. Creating it..."
  mkdir -p "$REPO_DIR" || { echo "Failed to create directory. Exiting."; exit 1; }
fi

# Navigate to the React app directory
cd "$REPO_DIR" || { echo "Failed to change directory to $REPO_DIR. Exiting."; exit 1; }

# Check if the directory is a Git repository
if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
  echo "Directory is not a Git repository. Exiting."
  exit 1
fi

# Get the latest local commit hash
LATEST_COMMIT=$(git rev-parse HEAD)

# If the last_commit_local.txt file doesn't exist, create it and store the current commit
if [ ! -f "$LAST_COMMIT_FILE" ]; then
  echo "$LATEST_COMMIT" > "$LAST_COMMIT_FILE"
  echo "First time running the script. Latest commit stored." | tee -a "$LOG_FILE"
  exit 0
fi

# Get the previous commit hash
PREVIOUS_COMMIT=$(cat "$LAST_COMMIT_FILE")

# Check if there is a new commit
if [ "$LATEST_COMMIT" != "$PREVIOUS_COMMIT" ]; then
  echo "New commit detected. Previous commit: $PREVIOUS_COMMIT, Latest commit: $LATEST_COMMIT" | tee -a "$LOG_FILE"

  if $CLEAN; then
    echo "Cleaning up the build directory..." | tee -a "$LOG_FILE"
    rm -rf build/*
  fi

  # Install dependencies
  echo "Installing dependencies..." | tee -a "$LOG_FILE"
  npm install || { echo "npm install failed. Exiting." | tee -a "$LOG_FILE"; exit 1; }

  # Build the React app
  echo "Building the app..." | tee -a "$LOG_FILE"
  npm run build || { echo "npm run build failed. Exiting." | tee -a "$LOG_FILE"; exit 1; }

  # Store the latest commit hash in the file
  echo "$LATEST_COMMIT" > "$LAST_COMMIT_FILE"
else
  echo "No new commits. The app is up to date." | tee -a "$LOG_FILE"
fi

# Run or build the React app based on user options
if $BUILD_ONLY; then
  echo "Build complete. You can run 'serve build' to serve the app." | tee -a "$LOG_FILE"
  exit 0
fi

if $SERVE_ONLY || [ "$LATEST_COMMIT" != "$PREVIOUS_COMMIT" ]; then
  if ! command -v serve &> /dev/null; then
    echo "'serve' command not found. Please install it and run the script again." | tee -a "$LOG_FILE"
    exit 1
  fi

  echo "Running the app..." | tee -a "$LOG_FILE"
  serve build
else
  echo "App is already built and up to date. Use --build to rebuild." | tee -a "$LOG_FILE"
fi

