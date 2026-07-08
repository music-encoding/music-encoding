#!/usr/bin/env bash

# run this script from anywhere

# Config
OVERWRITE=false
PROCESS_DATASPECS=false
PROCESS_FILES=true

# Save location of purify scripts to source
PURIFY_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Save music-encoding repo path (git clone root, or the extracted source dir)
MEI_REPO_DIR="$(git -C "$PURIFY_DIR" rev-parse --show-toplevel 2>/dev/null)" \
  || MEI_REPO_DIR="$(cd "$PURIFY_DIR/../.." && pwd)"

# Save modules path to variable
MEI_MODULES_DIR="$MEI_REPO_DIR"/source/modules
MEI_MODULES_OUTPUT_DIR="$MEI_REPO_DIR"/ideas/modules_purified

# Ensure the output directory exists
mkdir -p "$MEI_MODULES_OUTPUT_DIR"

# extract and convert to pure dataSpecs
if [[ "$PROCESS_DATASPECS" == true ]]; then
    for f in "$MEI_MODULES_DIR"/*.xml; do echo "$f"; saxon -s:"$f" -xsl:"$PURIFY_DIR"/purifyDataSpecs.xsl -o:"$MEI_MODULES_OUTPUT_DIR/$(basename "$f")"; echo; done
fi
#cd ../..
# then do content  models and datatypes, looking at each 
# non dataspec file in turn
#mkdir Source/impureSpecs
#cp Source/Specs/* Source/impureSpecs
#rm Source/impureSpecs/data.* Source/impureSpecs/teidata.*
#cd Source/impureSpecs/
if [[ "$PROCESS_FILES" == true ]]; then
    for f in "$MEI_MODULES_DIR"/*.xml; do echo "$f"; saxon -s:"$f" -xsl:"$PURIFY_DIR"/purify.xsl -o:"$MEI_MODULES_OUTPUT_DIR/$(basename "$f")"; echo; done
fi