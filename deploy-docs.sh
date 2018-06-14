#!/usr/bin/env bash

# This script builds the documentation and automatically commits
# it to the 'guidelines' directory.
# The directions for this are found here: https://gist.github.com/domenic/ec8b0fc8ab45f39403dd
# Note that for this to work it is essential for the same private/public key pair to
# be available on both the music-encoding and guidelines directories. This means:
# 1. Generate the public/private key: ssh-keygen -t rsa -b 4096 -C "andrew.hankinson@gmail.com"
# 2. Rename the keys deploy_key and deploy_key.pub
# 3. Using the travis CLI tool add these to both the guidelines and music-encoding travis
#    builds as an encrypted key:
#   - guidelines: travis encrypt-file -r music-encoding/guidelines deploy_key
#   - music-encoding: travis encrypt-file -r music-encoding/music-encoding deploy_key
#   Make note of the openssl line after adding the key to the music-encoding repo.
# 4. Add the public key (deploy_key.pub) to both of these repositories as a deploy key.
#    Be sure to grant it write access!
# 5. For the music-encoding repo, take the openssl command mentioned when adding the key and
#    replace the line in the script below with the new line.
# 6. Ensure you update the .travis.yml file variable ENCRYPTION_LABEL with the identifier from that string, e.g.,
#    with 'encrypted_20063e125f98_key' the identifier is 20063e125f98.


set -e # Exit with nonzero exit code if anything fails
MEI_VERSION="v3"

if [ "${TRAVIS_PULL_REQUEST}" != "false" ]; then
    echo "Will not build docs for pull requests. Skipping deploy."
    exit 0
fi

if [ "${TRAVIS_BRANCH}" == "develop" ]; then
    OUTPUT_FOLDER="dev"
    DOCS_BRANCH="master"
elif [ "${TRAVIS_BRANCH}" == "master" ]; then
    OUTPUT_FOLDER=${MEI_VERSION}
    DOCS_BRANCH="master"
elif [ "${TRAVIS_BRANCH}" == "feature-build-with-travis" ]; then  # to be removed when merged to develop.
    OUTPUT_FOLDER="test"
    DOCS_BRANCH="develop"
else
    echo "Will not build docs for branch ${TRAVIS_BRANCH}"
    exit 0
fi

DOCS_REPOSITORY="https://${GH_USERNAME}:${GH_TOKEN}@github.com/music-encoding/guidelines"
DOCS_DIRECTORY="guidelines-repo"
DEV_DOCS="${DOCS_DIRECTORY}/dev"
BUILD_DIR="build"
CANONICALIZED_SCHEMA="${BUILD_DIR}/mei-canonicalized.xml"

echo "Running documentation build"

# Get the music-encoding revision
SHA=`git rev-parse --verify HEAD`

# Clone the docs repo.
git clone ${DOCS_REPOSITORY} ${DOCS_DIRECTORY}

#mkdir "${DEV_DOCS}"
#touch "${DEV_DOCS}/.keep"

cd ${DOCS_DIRECTORY}

git checkout ${DOCS_BRANCH}

cd tools

exec java  -jar ${PATH_TO_SAXON_JAR} -xsl:extractGuidelines.xsl guidelines.version=${OUTPUT_FOLDER} ../../${CANONICALIZED_SCHEMA}

git config user.name "Documentation Builder"
git config user.email "${COMMIT_AUTHOR_EMAIL}"

git add -A .
git commit -m "Auto-commit of documentation build for music-encoding@${SHA}"

# Now that we're all set up, we can push.
git push ${DOCS_REPOSITORY} ${DOCS_BRANCH}