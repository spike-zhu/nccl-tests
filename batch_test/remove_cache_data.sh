#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
make -C "$SCRIPT_DIR/.." clean
rm -rf "$SCRIPT_DIR/test_nccl.log"