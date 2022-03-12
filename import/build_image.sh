#!/bin/bash -e

SCRIPT_DIR=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)

docker build -t flights-import "$SCRIPT_DIR"