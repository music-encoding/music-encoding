#!/bin/bash

## Customize here
PATH_TO_TEI_STYLESHEETS="/usr/local/share/tei/Stylesheets"
PATH_TO_SAXON_JAR="/usr/share/java/Saxon-HE-9.4.0.7.jar"
PATH_TO_TRANG_JAR="/usr/share/java/trang.jar"
PATH_TO_JING="/usr/bin/jing"

## Do not customize here
TEI_TO_RELAXNG_BIN="${PATH_TO_TEI_STYLESHEETS}/bin/teitorelaxng"
BUILD_DIR="build"
CUSTOMIZATIONS_DIR="customizations"
SOURCE_DIR="source"
SAMPLES_DIR="samples"
DRIVER_FILE=${SOURCE_DIR}"/driver.xml"

all()
{
    if [ ! -f $TEI_TO_RELAXNG_BIN ]; then
        echo $TEI_TO_RELAXNG_BIN
        echo "The TEI Stylesheets were not found at:" $PATH_TO_TEI_STYLESHEETS
        echo "Please specify using -t flag."
        exit 1
    fi

    if [ -d "build" ]; then
        echo "Removing old build directory"
        rm -r ${BUILD_DIR}
    fi

    mkdir -p ${BUILD_DIR}

    SAVEIFS=$IFS
    IFS=$(echo -en "\n\b")

    for file in $(find ${CUSTOMIZATIONS_DIR} -name '*.xml');
    do
        echo "processing" "${file}"
        echo $DRIVER_FILE
        $TEI_TO_RELAXNG_BIN --localsource=$DRIVER_FILE $file $BUILD_DIR/$(basename ${file%%.*}).rng

        if [ $? = 1 ]; then
            IFS=$SAVEIFS
            echo "Build failed on" $file
            exit 1
        fi

    done

    IFS=$SAVEIFS
}

test()
{
    echo "Validating 2013 samples directory against mei-all"

    SAVEIFS=$IFS
    IFS=$(echo -en "\n\b")

    for file in $(find ${SAMPLES_DIR}/MEI2013 -name '*.mei');
    do
        echo "Testing: " $file
        $PATH_TO_JING $BUILD_DIR/mei-all.rng "${file}"

        if [ $? = 1 ]; then
            IFS=$SAVEIFS
            echo "Tests failed on" $file
            exit 1
        fi
    done

    IFS=$SAVEIFS
}

usage()
{
    echo "Flags:"
    echo "  -h Print usage"
    echo "  -t Path to TEI Stylesheets"
    echo ""
    echo "Build options:"
    echo "  all"
    echo "  test"
    exit 1
}

SKIP=0
while getopts "h:t:" OPT; do
    case $OPT in
        h) 
            usage;;
        t)
            PATH_TO_TEI_STYLESHEETS=$OPTARG
            TEI_TO_RELAXNG_BIN="${PATH_TO_TEI_STYLESHEETS}/bin/teitorelaxng"
            SKIP=$(($SKIP + 2));;
    esac
done

args=("$@")
TYPE=${args[$SKIP]}

case $TYPE in
    "all" ) all;;
    "test" ) test;;
    * ) usage;;
esac