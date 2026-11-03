#!/usr/bin/env bash

# run this script from anywhere

# Config (defaults, can be changed via options)
OVERWRITE=false
PROCESS_DATASPECS=false
PROCESS_FILES=true

usage() {
    cat <<EOF
Usage: $(basename "$0") [options]

Options:
  --overwrite, --no-overwrite   overwrite source/modules in place, or write to
                                ideas/modules_purified (default: no-overwrite)
  --dataspecs, --no-dataspecs   run purifyDataSpecs.xsl (default: off)
  --files, --no-files           run purify.xsl (default: on)
  -h, --help                    show this help
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --overwrite)    OVERWRITE=true ;;
        --no-overwrite) OVERWRITE=false ;;
        --dataspecs)    PROCESS_DATASPECS=true ;;
        --no-dataspecs) PROCESS_DATASPECS=false ;;
        --files)        PROCESS_FILES=true ;;
        --no-files)     PROCESS_FILES=false ;;
        -h|--help)      usage; exit 0 ;;
        *)              echo "Unknown option: $1" >&2; usage >&2; exit 1 ;;
    esac
    shift
done

# Save location of purify scripts to source
PURIFY_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Save music-encoding repo path (git clone root, or the extracted source dir)
MEI_REPO_DIR="$(git -C "$PURIFY_DIR" rev-parse --show-toplevel 2>/dev/null)" \
  || MEI_REPO_DIR="$(cd "$PURIFY_DIR/../.." && pwd)"

# Save modules path to variable
MEI_MODULES_DIR="$MEI_REPO_DIR"/source/modules
SAXON_JAR="$MEI_REPO_DIR"/lib/saxon/saxon-he-12.9.jar

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
    if java -jar "$SAXON_JAR" -s:"$1" -xsl:"$2" -o:"$tmp"; then
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
