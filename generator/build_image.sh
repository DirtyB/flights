#!/bin/bash -e

SCRIPT_DIR=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)

docker build -t flights-generator "$SCRIPT_DIR"