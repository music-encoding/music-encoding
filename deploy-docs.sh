#!/usr/bin/env bash

# This script builds the documentation and automatically commits
# it to the 'guidelines' directory.
# It uses an encrypted GH_TOKEN setting in Travis to check out the Guidelines, build them, commit
# the changes, and then push.
#
# Changes to the major version of MEI should be reflected by updating the MEI_VERSION variable.

set -e # Exit with nonzero exit code if anything fails
MEI_VERSION="v4"

if [ "${TRAVIS_PULL_REQUEST}" != "false" ]; then
    echo "Will not build docs for pull requests. Skipping deploy."
    exit 0
fi

# if [ "${TRAVIS_BRANCH}" == "develop" ]; then
#     OUTPUT_FOLDER="dev"
#     DOCS_BRANCH="master"
if [ "${TRAVIS_BRANCH}" == "master" ]; then
    OUTPUT_FOLDER=${MEI_VERSION}
    DOCS_BRANCH="master"
else
    echo "Will not build docs for branch ${TRAVIS_BRANCH}"
    exit 0
fi

# Get the music-encoding revision
SHA=`git rev-parse --verify HEAD`
SHORT_SHA=`git rev-parse --verify --short HEAD`

DOCS_REPOSITORY="https://${GH_USERNAME}:${GH_TOKEN}@github.com/music-encoding/guidelines"
DOCS_DIRECTORY="guidelines-repo"
DOCS_VERSION_BUILD_FILE="${DOCS_DIRECTORY}/_includes/${OUTPUT_FOLDER}/build.txt"
BUILD_DIR="build"
CANONICALIZED_SCHEMA="${BUILD_DIR}/mei-canonicalized.xml"

# Clone the docs repo.
echo "Cloning ${DOCS_REPOSITORY}"
git clone ${DOCS_REPOSITORY} ${DOCS_DIRECTORY}

echo "Running documentation build"
echo "<a href='https://github.com/music-encoding/music-encoding/commit/${SHA}'>Version ${SHORT_SHA}</a>" > ${DOCS_VERSION_BUILD_FILE}

cd ${DOCS_DIRECTORY}

echo "Checking out ${DOCS_BRANCH} branch"
git checkout ${DOCS_BRANCH}

# cd to tools since the xslt is configured to write relative to this directory
cd tools

echo "Building docs"

java  -jar ${PATH_TO_SAXON_JAR} -xsl:extractGuidelines.xsl guidelines.version=${OUTPUT_FOLDER} ../../${CANONICALIZED_SCHEMA}

# change back to root of guidelines to commit.
cd ..

ls -alh

echo "Configuring git push"
git config user.name "Documentation Builder"
git config user.email "${COMMIT_AUTHOR_EMAIL}"

git status

git add -A
git commit -m "Auto-commit of documentation build for music-encoding/music-encoding@${SHA}"

echo "Syncing from origin..."
git pull

echo "Pushing commits"
# Now that we're all set up, we can push.
git push ${DOCS_REPOSITORY} ${DOCS_BRANCH}
