#!/bin/sh

VERSION_FILE="/app/VERSION"
DATA_PATH="/dev/foundry/data"

if [ -f "$VERSION_FILE" ]; then
    VERSION=$(head -n 1 "$VERSION_FILE")
    MAJOR_VERSION=${VERSION%%.*}
elif [ -n "$FOUNDRY_VERSION" ]; then
    VERSION="$FOUNDRY_VERSION"
    MAJOR_VERSION=${VERSION%%.*}
else
    echo "Version file not found: $VERSION_FILE"
    exit 1
fi

if [ "$MAJOR_VERSION" -ge 13 ]; then
    exec node "/app/main.js" --dataPath="$DATA_PATH"
else
    exec node "/app/resources/app/main.js" --dataPath="$DATA_PATH"
fi