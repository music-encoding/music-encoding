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

RED='\033[0;31m'
GREEN='\033[0;32m'
PURPLE='\033[0;35m'
NORM='\033[0m'  # No Color

all()
{
    if [ ! -f $TEI_TO_RELAXNG_BIN ]; then
        echo $TEI_TO_RELAXNG_BIN
        echo "The TEI Stylesheets were not found at:" $PATH_TO_TEI_STYLESHEETS
        echo "Please specify using -t flag."
        exit 1
    fi

    if [ -d "build" ]; then
        echo -e "${PURPLE}Removing old build directory${NORM}"
        rm -r ${BUILD_DIR}
    fi

    mkdir -p ${BUILD_DIR}

    SAVEIFS=$IFS
    IFS=$(echo -en "\n\b")

    for file in $(find ${CUSTOMIZATIONS_DIR} -name '*.xml');
    do
        echo -e "${GREEN}Processing" "${file}"$NORM
        $TEI_TO_RELAXNG_BIN --localsource=$DRIVER_FILE $file $BUILD_DIR/$(basename ${file%%.*}).rng

        if [ $? = 1 ]; then
            IFS=$SAVEIFS
            echo -e "${RED}Build failed on" $file$NORM
            exit 1
        fi

    done

    IFS=$SAVEIFS
}

test()
{
    echo -e "\nValidating 2013 samples directory against built customizations\n"

    SAVEIFS=$IFS
    IFS=$(echo -en "\n\b")

    for file in $(find ${BUILD_DIR} -name '*.rng');
    do
        echo -e "${PURPLE} Testing: ${NORM}" $file
        # this gets the name of a possible testing directory from the name of the customization
        testdir=`echo $file | sed -n 's/build\/\(.*\)\.rng/\1/p'`
        if [ -d tests/${testdir} ]; then
            echo -e "${PURPLE} Found ${NORM} $testdir"
            for tfile in $(find tests/${testdir} -name '*.mei');
            do
                echo -e "${PURPLE} Testing: ${NORM}" $tfile

                $PATH_TO_JING $file "${tfile}"

                if [ $? = 1 ]; then
                    IFS=$SAVEIFS
                    echo -e "${RED}\tTests failed on" $tfile$NORM
                    exit 1
                else
                    echo -e $GREEN '\t' $tfile "is valid against $file ${NORM}"
                fi

                echo -e "\n${GREEN}***********************************************"
                echo -e "$file passed validation tests"
                echo -e "***********************************************${NORM}\n"
            done
        fi
    done

    # REMOVE SOON
    # Until we get the test set up and running we'll still validate the whole sample collection against
    # mei-all. This testing scheme should be removed after the tests are ready.
    # for file in $(find ${SAMPLES_DIR}/MEI2013 -name '*.mei');
    # do
    #     echo -e "${PURPLE} Testing: ${NORM}" $file

    #     if $USE_XMLLINT; then
    #         $PATH_TO_XMLLINT --noout --relaxng $BUILD_DIR/mei-all.rng "${file}"
    #     else
    #         $PATH_TO_JING $BUILD_DIR/mei-all.rng "${file}"
    #     fi

    #     if [ $? = 1 ]; then
    #         IFS=$SAVEIFS
    #         echo -e "${RED}\tTests failed on" $file$NORM
    #         exit 1
    #     else
    #         echo -e $GREEN '\t' $file "is valid against mei-all.rng${NORM}"
    #     fi
    # done

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