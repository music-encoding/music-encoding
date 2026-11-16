#!/usr/bin/env bash

# run this script from anywhere

# Config (defaults, can be changed via options)
OVERWRITE=false
EXTERNAL=false
OUTPUT_DIR=""
SOURCE=""
INPUT=""

usage() {
    cat <<EOF
Usage: $(basename "$0") [options] ODD|DIR

Purifies an ODD file (source/mei-source.xml or a customization), or every
*.xml file in DIR, with purify.xsl.

Dependencies are resolved: xi:include, moduleRef/@key (via the source of the
schemaSpec), @source on elementSpec, classSpec, macroSpec, dataSpec and
specGrpRef, and specGrpRef/@target. The source of a schemaSpec (its @source,
or --source) is read as context only. Only local files inside the repository
are written, and only when purify changes them. References that cannot be
followed (remote URLs, tei: URIs, moduleRef/@url, missing files) are
reported as "external".

Options:
  --overwrite, --no-overwrite   overwrite the files in place, or write them to
                                the output dir (default: no-overwrite)
  --external, --no-external     transform the dependencies as well, not only
                                the ODD itself (default: no-external)
  -o, --output-dir DIR          output dir for --no-overwrite; files keep their
                                path relative to the repository
                                (default: build/purified)
  -s, --source FILE             source for a schemaSpec without @source
                                (default: source/mei-source.xml)
  -h, --help                    show this help
EOF
}

need_arg() {
    [[ -n "$2" ]] || { echo "Missing argument for $1" >&2; exit 1; }
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --overwrite)     OVERWRITE=true ;;
        --no-overwrite)  OVERWRITE=false ;;
        --external)      EXTERNAL=true ;;
        --no-external)   EXTERNAL=false ;;
        -o|--output-dir) need_arg "$1" "$2"; OUTPUT_DIR="$2"; shift ;;
        -s|--source)     need_arg "$1" "$2"; SOURCE="$2"; shift ;;
        -h|--help)       usage; exit 0 ;;
        -*)              echo "Unknown option: $1" >&2; usage >&2; exit 1 ;;
        *)               [[ -z "$INPUT" ]] || { echo "Only one ODD or directory allowed" >&2; exit 1; }
                         INPUT="$1" ;;
    esac
    shift
done

[[ -n "$INPUT" ]] || { usage >&2; exit 1; }

# Save location of purify scripts to source
PURIFY_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Save music-encoding repo path (git clone root, or the extracted source dir)
MEI_REPO_DIR="$(git -C "$PURIFY_DIR" rev-parse --show-toplevel 2>/dev/null)" \
  || MEI_REPO_DIR="$(cd "$PURIFY_DIR/../.." && pwd)"

SAXON_JAR="$MEI_REPO_DIR"/lib/saxon/saxon-he-12.9.jar

# Absolute path of an existing file
abs_file() {
    [[ -f "$1" ]] || { echo "No such file: $1" >&2; return 1; }
    echo "$(cd "$(dirname "$1")" && pwd)/$(basename "$1")"
}

SOURCE="$(abs_file "${SOURCE:-$MEI_REPO_DIR/source/mei-source.xml}")" || exit 1

if [[ "$OVERWRITE" == true ]]; then
    DEST_DIR="$MEI_REPO_DIR"
else
    mkdir -p "${OUTPUT_DIR:=$MEI_REPO_DIR/build/purified}" || exit 1
    DEST_DIR="$(cd "$OUTPUT_DIR" && pwd)"
fi

# The ODD files to process
if [[ -d "$INPUT" ]]; then
    ODDS=("$INPUT"/*.xml)
    [[ -f "${ODDS[0]}" ]] || { echo "No *.xml files in $INPUT" >&2; exit 1; }
else
    ODDS=("$INPUT")
fi

# Purify one ODD: transformed files are written to a staging dir first (Saxon
# cannot write to a file it has read), then copied to the destination
purify() {
    local odd staging status
    odd="$(abs_file "$1")" || return 1
    staging="$(mktemp -d)" || return 1

    echo "== $odd"
    java -jar "$SAXON_JAR" -s:"$odd" -it -xsl:"$PURIFY_DIR"/purify-odd.xsl \
        base-dir="$MEI_REPO_DIR" staging-dir="$staging" source="$SOURCE" \
        external="$EXTERNAL"
    status=$?

    if [[ $status -eq 0 ]]; then
        cp -R "$staging"/. "$DEST_DIR"/ || status=1
    fi
    rm -rf "$staging"
    echo
    return $status
}

STATUS=0
for f in "${ODDS[@]}"; do
    purify "$f" || STATUS=1
done

[[ "$OVERWRITE" == true ]] || echo "Output: $DEST_DIR"
exit $STATUS
