#!/bin/bash -e

SCRIPT_DIR=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)

"$SCRIPT_DIR"/db/build_image.sh
"$SCRIPT_DIR"/migration/build_image.sh
"$SCRIPT_DIR"/import/build_image.sh
