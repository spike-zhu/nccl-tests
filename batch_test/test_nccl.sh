#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# set the NCCL test build directory and log file path
NCCL_BUILD_DIR="$SCRIPT_DIR/../build"
LOG_FILE="$SCRIPT_DIR/test_nccl.log"

# set the root path of CUDA and NCCL (modified according to actual changes)
CUDA_HOME="/usr/local/cuda"
NCCL_HOME="/opt/nvidia/hpc_sdk/Linux_x86_64/23.5/comm_libs/12.1/nccl"

# set the dynamic library search path (make sure libcuda and libnccl are found at runtime)
export LD_LIBRARY_PATH="$CUDA_HOME/lib64:$NCCL_HOME/lib:$LD_LIBRARY_PATH"

# # Print status messages
echo "[INFO] Building NCCL tests..."
echo "[INFO] CUDA_HOME=$CUDA_HOME"
echo "[INFO] NCCL_HOME=$NCCL_HOME"
echo "[INFO] NCCL_BUILD_DIR=$NCCL_BUILD_DIR"
echo "[INFO] Log file: $LOG_FILE"

# execute make build
make -C "$SCRIPT_DIR/../src" build \
  BUILDDIR="$NCCL_BUILD_DIR" \
  CUDA_HOME="$CUDA_HOME" \
  NCCL_HOME="$NCCL_HOME"

# make sure NCCL test build file exeist 
if [ ! -d "$NCCL_BUILD_DIR" ]; then
    echo "Error: NCCL_BUILD_DIR does not exist."
    exit 1
fi

# execute NCCL test
find "$NCCL_BUILD_DIR" -name "*_perf" | sort | while read -r file; do
    echo "[Processing file: $file]"
    "$file" -b 8 -e 1M -f 2 -g 8
done

# record NCCL test result in log file
exec > >(tee "$LOG_FILE") 2>&1
echo "[INFO] All projects have been test" | tee -a "$LOG_FILE"