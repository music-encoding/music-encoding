#!/usr/bin/env bash

# run this script from anywhere

# Config
OVERWRITE=true
PROCESS_DATASPECS=false
PROCESS_FILES=true

# Save location of purify scripts to source
PURIFY_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Save music-encoding repo path (git clone root, or the extracted source dir)
MEI_REPO_DIR="$(git -C "$PURIFY_DIR" rev-parse --show-toplevel 2>/dev/null)" \
  || MEI_REPO_DIR="$(cd "$PURIFY_DIR/../.." && pwd)"

# Save modules path to variable
MEI_MODULES_DIR="$MEI_REPO_DIR"/source/modules

# Overwrite the source modules in place, or write to a separate output dir
if [[ "$OVERWRITE" == true ]]; then
    MEI_MODULES_OUTPUT_DIR="$MEI_MODULES_DIR"
else
    MEI_MODULES_OUTPUT_DIR="$MEI_REPO_DIR"/ideas/modules_purified
fi

# Ensure the output directory exists
mkdir -p "$MEI_MODULES_OUTPUT_DIR"

# Transform $1 with stylesheet $2 into the output dir; goes through a temp file
# so input and output may be the same file
transform() {
    local out="$MEI_MODULES_OUTPUT_DIR/$(basename "$1")"
    local tmp
    tmp="$(mktemp "${out}.XXXXXX")" || return 1
    if saxon -s:"$1" -xsl:"$2" -o:"$tmp"; then
        mv "$tmp" "$out"
    else
        rm -f "$tmp"
        return 1
    fi
}

# extract and convert to pure dataSpecs
if [[ "$PROCESS_DATASPECS" == true ]]; then
    for f in "$MEI_MODULES_DIR"/*.xml; do echo "$f"; transform "$f" "$PURIFY_DIR"/purifyDataSpecs.xsl; echo; done
fi
#cd ../..
# then do content  models and datatypes, looking at each 
# non dataspec file in turn
#mkdir Source/impureSpecs
#cp Source/Specs/* Source/impureSpecs
#rm Source/impureSpecs/data.* Source/impureSpecs/teidata.*
#cd Source/impureSpecs/
if [[ "$PROCESS_FILES" == true ]]; then
    for f in "$MEI_MODULES_DIR"/*.xml; do echo "$f"; transform "$f" "$PURIFY_DIR"/purify.xsl; echo; done
fi
