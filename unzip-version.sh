#!/bin/bash

function versionGE() {
    local RE='([0-9]+)[.]([0-9]+)'
    #echo "Comparing $1 >= $2";

    if [[ ! "$1" =~ $RE ]]; then
        echo 0;
        return;
    fi

    majorA=${BASH_REMATCH[1]}
    minorA=${BASH_REMATCH[2]}

    if [[ ! "$2" =~ $RE ]]; then
        echo 1;
        return;
    fi
    
    majorB=${BASH_REMATCH[1]}
    minorB=${BASH_REMATCH[2]}

    if [ $majorA -lt $majorB ]; then
        echo 0;
        return;
    fi

    if [[ $majorA -le $majorB && $minorA -lt $minorB ]]; then
        echo 0;
        return;
    fi

    echo 1;
}

if [ $# -ne 2 ]; then
    echo "Error: Invalid number of arguments. Expected 2"
    exit 1
fi

VERSIONPATH="$1";
VERSION="$2";

echo "Selected version: $VERSION";
echo "Path to search: $VERSIONPATH";

if [ ! -d "$VERSIONPATH" ]; then
    echo "'$VERSIONPATH' is not a directory";
    exit 1;
fi

if [ $VERSION = 'latest' ]; then
    for filePath in "$VERSIONPATH"/FoundryVTT-*.zip; do
        name=$(basename "$filePath" ".zip")
        echo "Version available: $name";
        candidate=$(echo $name | cut -d'-' -f2);

        echo "Candidate version: $candidate";

        shouldUse=$(versionGE "$candidate" $VERSION)
        echo $shouldUse
        
        if [ $shouldUse = 1 ]; then
            VERSION=$candidate;
        fi
    done

    if [ $VERSION = 'latest' ]; then
        echo "No versions available"
        exit 1
    fi

fi

file="$VERSIONPATH/FoundryVTT-$VERSION.zip";

if [ ! -f $file ]; then
    echo "Unable to find file '$file'";
    exit 1;
fi

echo "Using file '$file'";

unzip "$file" -d "/app";