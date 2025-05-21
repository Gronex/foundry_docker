#!/bin/sh

VERSION_FILE="/app/VERSION"
DATA_PATH="/dev/foundry/data"

if [ -f "$VERSION_FILE" ]; then
    VERSION=$(head -n 1 "$VERSION_FILE")
    MAJOR_VERSION=${VERSION%%.*}
    if [ "$MAJOR_VERSION" -ge 13 ]; then
        exec node "/app/main.js" --dataPath="$DATA_PATH"
    else
        exec node "/app/resources/app/main.js" --dataPath="$DATA_PATH"
    fi
else
    echo "Version file not found: $VERSION_FILE"
    exit 1
fi