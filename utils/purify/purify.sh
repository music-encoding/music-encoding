#!/usr/bin/env bash

# run this script from anywhere

# Config (defaults, can be changed via options)
OVERWRITE=false
OUTPUT_DIR=""
FILES=()

usage() {
    cat <<EOF
Usage: $(basename "$0") [options] [FILE...]

Runs purify.xsl on every file in source/modules, or on the given FILEs
(e.g. customizations/mei-basic.xml). Files outside source/modules are
treated as customizations: source/modules is used as module context.

Options:
  --overwrite, --no-overwrite   overwrite the input files in place, or write
                                to the output dir (default: no-overwrite)
  -o, --output-dir DIR          output dir for --no-overwrite
                                (default: build/purified/modules for modules,
                                build/purified/customizations for other files)
  -h, --help                    show this help
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --overwrite)     OVERWRITE=true ;;
        --no-overwrite)  OVERWRITE=false ;;
        -o|--output-dir) [[ -n "$2" ]] || { echo "Missing argument for $1" >&2; exit 1; }
                         OUTPUT_DIR="$2"; shift ;;
        -h|--help)       usage; exit 0 ;;
        --)              shift; FILES+=("$@"); break ;;
        -*)              echo "Unknown option: $1" >&2; usage >&2; exit 1 ;;
        *)               FILES+=("$1") ;;
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

# Default: all modules
if [[ ${#FILES[@]} -eq 0 ]]; then
    FILES=("$MEI_MODULES_DIR"/*.xml)
fi

# Make an output dir absolute (creating it if needed)
abs_dir() {
    mkdir -p "$1" && (cd "$1" && pwd)
}

# Transform file $1 into dir $2, passing module context dir $3 (may be empty);
# goes through a temp file so input and output may be the same file
transform() {
    local out="$2/$(basename "$1")"
    local tmp
    tmp="$(mktemp "${out}.XXXXXX")" || return 1
    if java -jar "$SAXON_JAR" -s:"$1" -xsl:"$PURIFY_DIR"/purify.xsl -o:"$tmp" \
            ${3:+modules-dir="$3"}; then
        mv "$tmp" "$out"
    else
        rm -f "$tmp"
        return 1
    fi
}

# Convert content models and datatypes in each file.
# purifyDataSpecs.xsl (the TEI datatype-macro step) is intentionally not used:
# purify.xsl itself turns MEI datatype macros into dataSpecs.
STATUS=0
for f in "${FILES[@]}"; do
    if [[ ! -f "$f" ]]; then
        echo "No such file: $f" >&2; STATUS=1; continue
    fi
    in_dir="$(cd "$(dirname "$f")" && pwd)"
    f="$in_dir/$(basename "$f")"

    # Modules see their siblings; anything else (a customization) gets
    # source/modules as module context
    if [[ "$in_dir" == "$MEI_MODULES_DIR" ]]; then
        modules_dir=""
        default_out="$MEI_REPO_DIR"/build/purified/modules
    else
        modules_dir="$MEI_MODULES_DIR"
        default_out="$MEI_REPO_DIR"/build/purified/customizations
    fi

    if [[ "$OVERWRITE" == true ]]; then
        out_dir="$in_dir"
    else
        out_dir="$(abs_dir "${OUTPUT_DIR:-$default_out}")" || { STATUS=1; continue; }
    fi

    echo "$f -> $out_dir"
    transform "$f" "$out_dir" "$modules_dir" || STATUS=1
    echo
done

exit $STATUS
