#!/bin/bash
set -e

# If these environment variables are not set, set some defaults
: ${PATH_TO_TEI_STYLESHEETS?"Need to set TEI Stylesheets."}
: ${PATH_TO_SAXON_JAR?"The path to the Saxon jar needs to be set."}
: ${PATH_TO_JING?"The path to the jing binary needs to be set."}

## Do not customize here
TEI_TO_RELAXNG_BIN="${PATH_TO_TEI_STYLESHEETS}/bin/teitorelaxng"

BUILD_DIR="build"
CUSTOMIZATIONS_DIR="customizations"
SOURCE_DIR="source"
SAMPLES_DIR="samples"
UTILS_DIR="utils"

SCHEMATRON_FILES=${UTILS_DIR}"/schematron"
DRIVER_FILE=${SOURCE_DIR}"/mei-source.xml"

SCHEMATRON_EXTRACT=${SCHEMATRON_FILES}"/ExtractSchFromRNG-2.xsl"
SCHEMATRON_PREPROCESS=${SCHEMATRON_FILES}"/iso_dsdl_include.xsl"
SCHEMATRON_EXPAND=${SCHEMATRON_FILES}"/iso_abstract_expand.xsl"
SCHEMATRON_COMPILE=${SCHEMATRON_FILES}"/iso_svrl_for_xslt2.xsl"
SCHEMATRON_LOCATION=${BUILD_DIR}"/schematron"
SCHEMATRON_VALIDATOR=${SCHEMATRON_FILES}"/validation-checker.xquery"

TEI_TO_RELAXNG_BIN="${PATH_TO_TEI_STYLESHEETS}/bin/teitorelaxng"

RED='\033[0;31m'
GREEN='\033[0;32m'
PURPLE='\033[0;35m'
NORM='\033[0m'  # No Color

SCHEMATRON_PASS=true

build_schematron()
{
    rngfile=$1

    schematron_rules=$(basename ${rngfile%%.*}).xsl

    if [ ! -d $SCHEMATRON_LOCATION ]; then
        echo -e "${PURPLE}Creating schematron directory${NORM}"
        mkdir -p $SCHEMATRON_LOCATION
    fi

    tempdir=$(mktemp -d)
    # 1. Extract rules from the RNG schema
    java -jar $PATH_TO_SAXON_JAR -versionmsg:off -s:$rngfile -xsl:$SCHEMATRON_EXTRACT -o:${tempdir}/schematron-rules.sch

    # 2. Preprocess
    java -jar $PATH_TO_SAXON_JAR -versionmsg:off -s:${tempdir}/schematron-rules.sch -xsl:$SCHEMATRON_PREPROCESS -o:${tempdir}/schematron-preprocess.sch

    # 3. Expand
    java -jar $PATH_TO_SAXON_JAR -versionmsg:off -s:${tempdir}/schematron-preprocess.sch -xsl:$SCHEMATRON_EXPAND -o:${tempdir}/schematron-expand.sch

    # 4. Compile
    java -jar $PATH_TO_SAXON_JAR -versionmsg:off -s:${tempdir}/schematron-expand.sch -xsl:$SCHEMATRON_COMPILE -o:${SCHEMATRON_LOCATION}/${schematron_rules}

    rm -r $tempdir

    echo -e "${GREEN} Finished generating Schematron for ${rngfile}${NORM}"
}

validate_with_schematron()
{
    rngfile=$1
    meifile=$2
    SCHEMATRON_PASS=false

    echo -e "${PURPLE}Validating $meifile with schematron${NORM}"

    tempdir=$(mktemp -d)
    schematron_file=$SCHEMATRON_LOCATION/$(basename ${rngfile%%.*}).xsl

    # Generate validation file from the XSL
    echo -e "${PURPLE} Applying validation stylesheet${NORM}"
    java -jar $PATH_TO_SAXON_JAR -versionmsg:off -s:$meifile -xsl:$schematron_file -o:${tempdir}"/schematron-output.xml"

    # Validate
    echo -e "${PURPLE} Validating Schematron...${NORM}\n"
    msg=$(java -cp $PATH_TO_SAXON_JAR net.sf.saxon.Query -s:${tempdir}/schematron-output.xml -q:${SCHEMATRON_VALIDATOR})

    passed=1
    if [ ! -n $msg ]; then
        SCHEMATRON_PASS=false
        echo -e "${RED} Schematron validation failed for ${meifile}.${NORM}"
        echo -e $msg
        passed=0
    else
        SCHEMATRON_PASS=true
        echo -e "${GREEN} Schematron validation passed for ${meifile}.${NORM}"
    fi

    rm -r $tempdir
}

buildMei()
{
    if [ ! -f $TEI_TO_RELAXNG_BIN ]; then
        echo $TEI_TO_RELAXNG_BIN
        echo "The TEI Stylesheets were not found at:" $PATH_TO_TEI_STYLESHEETS
        echo "Please specify using -t flag."
        exit 1
    fi

    if [ -d "build" ]; then
        echo -e "${PURPLE} Removing old build directory${NORM}"
        rm -r ${BUILD_DIR}
    fi

    mkdir -p ${BUILD_DIR}

    echo -e "${PURPLE}Canonicalizing the ODD file"$NORM
    $PATH_TO_XMLLINT -xinclude ${DRIVER_FILE} -o ${BUILD_DIR}/mei-canonicalized.xml

    SAVEIFS=$IFS
    IFS=$(echo -en "\n\b")

    for file in $(find ${CUSTOMIZATIONS_DIR} -name '*.xml');
    do
        echo -e "${PURPLE} Processing" "${file}"$NORM
        echo -e $TEI_TO_RELAXNG_BIN --localsource=$DRIVER_FILE $file $BUILD_DIR/$(basename ${file%%.*}).rng

        $TEI_TO_RELAXNG_BIN --localsource=$DRIVER_FILE $file $BUILD_DIR/$(basename ${file%%.*}).rng

        if [ $? = 1 ]; then
            IFS=$SAVEIFS
            echo -e "${RED} Build failed on" $file$NORM
            exit 1
        fi

        # build the schematron rules for this schema
        echo -e "${PURPLE} Building Schematron Rules for ${file}${NORM}"
        build_schematron $BUILD_DIR/$(basename ${file%%.*}).rng
    done

    IFS=$SAVEIFS
}

testMei()
{
    exit 0
}

#test()
#{
#    echo -e "\nValidating samples directory against built customizations\n"
#
#    SAVEIFS=$IFS
#    IFS=$(echo -en "\n\b")
#
#    TOTAL_TESTS=0
#    PASSED_TESTS=0
#
#    for file in $(find ${BUILD_DIR} -name '*.rng');
#    do
#        echo -e "${PURPLE} Testing: ${NORM}" $file
#        # this gets the name of a possible testing directory from the name of the customization
#        testdir=`echo $file | sed -n 's/build\/\(.*\)\.rng/\1/p'`
#        if [ -d tests/${testdir} ]; then
#            echo -e "${PURPLE} Found ${NORM} $testdir"
#            for tfile in $(find tests/${testdir} -name '*.mei');
#            do
#                SUCCESS=true
#                TOTAL_TESTS=$((TOTAL_TESTS + 1))
#
#                echo -e "${PURPLE} Testing Against: ${NORM}" $tfile
#
#                $PATH_TO_JING $file "${tfile}"
#
#                if [ $? = 1 ]; then
#                    IFS=$SAVEIFS
#                    echo -e "${RED}\tTests failed on" $tfile$NORM
#                    SUCCESS=false
#                else
#                    echo -e $GREEN '\t' $tfile "is valid against $file ${NORM}"
#                fi
#
#                validate_with_schematron $file $tfile
#
#                if [[ "$SUCCESS" = true && "$SCHEMATRON_PASS" = true ]]; then
#                    PASSED_TESTS=$((PASSED_TESTS + 1))
#
#                    echo -e "\n${GREEN} ***********************************************${NORM}"
#                    echo -e "${GREEN} $file passed validation tests${NORM}"
#                    echo -e "${GREEN} ***********************************************${NORM}\n"
#                else
#                    echo -e "\n${RED} FAILURE ${NORM}"
#                fi
#            done
#        fi
#    done
#
#    # REMOVE SOON
#    # Until we get the test set up and running we'll still validate the whole sample collection against
#    # mei-all. This testing scheme should be removed after the tests are ready.
#    # for file in $(find ${SAMPLES_DIR}/MEI2013 -name '*.mei');
#    # do
#    #     echo -e "${PURPLE} Testing: ${NORM}" $file
#
#    #     if $USE_XMLLINT; then
#    #         $PATH_TO_XMLLINT --noout --relaxng $BUILD_DIR/mei-all.rng "${file}"
#    #     else
#    #         $PATH_TO_JING $BUILD_DIR/mei-all.rng "${file}"
#    #     fi
#
#    #     if [ $? = 1 ]; then
#    #         IFS=$SAVEIFS
#    #         echo -e "${RED}\tTests failed on" $file$NORM
#    #         exit 1
#    #     else
#    #         echo -e $GREEN '\t' $file "is valid against mei-all.rng${NORM}"
#    #     fi
#    # done
#
#    IFS=$SAVEIFS
#    echo -e "\n${GREEN} PASSED TESTS: $PASSED_TESTS${NORM}"
#    echo -e "${PURPLE} TOTAL TESTS: $TOTAL_TESTS${NORM}"
#
#    if [ $PASSED_TESTS != $TOTAL_TESTS ]; then
#        echo -e "\n${RED} $((TOTAL_TESTS - PASSED_TESTS)) TESTS FAILED ${NORM}"
#        exit 1
#    fi
#}

usage()
{
    echo "Flags:"
    echo "  -h Print usage"
    echo ""
    echo "Build options:"
    echo "  build"
    echo "  test"
    exit 1
}

SKIP=0
while getopts "h:t:" OPT; do
    case $OPT in
        h)
            usage;;
        t)
            SKIP=$(($SKIP + 2));;
    esac
done

args=("$@")
TYPE=${args[$SKIP]}

case $TYPE in
    "build" ) buildMei;;
    "test" ) testMei;;
    * ) usage;;
esac
