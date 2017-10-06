#!/usr/bin/env bash
set -e # Exit with nonzero exit code if anything fails

if [ "${TRAVIS_PULL_REQUEST}" != "false" ]; then
    echo "Will not build docs for pull requests. Skipping deploy."
    exit 0
fi

DOCS_REPOSITORY="git@github.com:music-encoding/guidelines"
DOCS_BRANCH="master"
DOCS_DIRECTORY="docs"
DEV_DOCS="${DOCS_DIRECTORY}/dev"

echo "Running documentation build"
ENCRYPTED_KEY_VAR="encrypted_${ENCRYPTION_LABEL}_key"
ENCRYPTED_IV_VAR="encrypted_${ENCRYPTION_LABEL}_iv"
ENCRYPTED_KEY=${!ENCRYPTED_KEY_VAR}
ENCRYPTED_IV=${!ENCRYPTED_IV_VAR}

openssl aes-256-cbc -K $encrypted_20063e125f98_key -iv $encrypted_20063e125f98_iv -in deploy_key.enc -out deploy_key -d
chmod 600 deploy_key
eval `ssh-agent -s`
ssh-add deploy_key

SHA=`git rev-parse --verify HEAD`

git clone ${DOCS_REPOSITORY} ${DOCS_DIRECTORY}

mkdir "${DEV_DOCS}"
touch "${DEV_DOCS}/.keep"

cd ${DOCS_DIRECTORY}

git config user.name "Documentation Builder"
git config user.email "${COMMIT_AUTHOR_EMAIL}"

git add -A .
git commit -m "Auto-commit of documentation build for music-encoding@${SHA}"
# Get the deploy key by using Travis's stored variables to decrypt deploy_key.enc


# Now that we're all set up, we can push.
git push ${DOCS_REPOSITORY} ${DOCS_BRANCH}