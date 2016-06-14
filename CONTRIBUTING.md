# Music Encoding Initiative Contribution Guidelines

This document sets out the methods and practices for contributing to the Music Encoding Initiative.

# Contributors

The Music Encoding Initiative (MEI) schema is developed and maintained by the MEI Technical Team. There are two co-leaders of the Technical Team, who act as administrative representatives to the board and manage the technical infrastructure of the project (e.g., GitHub administrative access). The role of the technical team is to review and propose changes to the MEI Schema.

Membership in the Technical Team is informal. Being considered a "member" of this group means you have introduced yourself to the community, have expressed an interest in helping grow and develop MEI, and have demonstrated an ability to contribute to the development of MEI. These contributions may be to the core schema, documentation, tools, tests, or sample encodings. Technical Team members will also help triage issues and help review pull request proposals.

The Technical Team co-leaders will, from time to time, designate and appoint senior members of the technical team to act as Core Contributors. These core contributors will have the responsibility of commit access to the core MEI Schema, and will ensure these contributions are consistent with the spirit and design of the MEI schema.

## How to contribute

We use GitHub as our main development platform. GitHub features a "Pull Request" mechanism for proposing contributions to the schema from our community. A brief overview of this process:

 1. Fork the `music-encoding/music-encoding` repository into your own account (e.g., `username/music-encoding`.
 2. Create a dedicated branch for your fix on your repository. For example, you might create a `fix-duration-attribute` branch if you're proposing a fix for the duration attribute.
 3. Make your changes. You can commit to your branch as many times as you like.
 4. When you're ready to provide your changes "upstream," you can open a pull request to the `music-encoding/music-encoding` branch. **NB:** You will want to make sure you're proposing a merge to `develop` and not `master`.
 5. Members of the MEI Technical Team will then review your submission. If you are asked to make changes, you can push these changes to your original branch and the pull request will be automatically updated.
 6. Once the changes have gone through our review process, a Core Contributor will merge your changes into the MEI source repository. You may then delete your dedicated branch.

## Checklist for a contribution

Pull requests containing contributions of any significant changes should be accompanied by the following supporting changes:

 1. Changes or additions to the documentation in the guidelines and in the schema as necessary. If it's not documented, you will be asked to update your pull request before it is merged.
 2. Sample encodings in the 'tests' folder that demonstrate the changes, so that the changes may be validated. If our reviewers ask for tests your pull request will not be accepted until they are provided.

### Customizations and Tests

Customizations to the schema should be placed in the `customizations` folder, named as `mei-NAME-[suffix].xml`. Our automated build system, TravisCI, will build all customizations in this folder and ensure there are no problems. It will also run our automated tests to ensure no validation problems.

The naming of the customizations is important. If your customization should be tested against the "CMN" test corpus, you should name your customization `mei-CMN-something.xml`. This will automatically build and test your customization. If, however, your customization requires a unique test set, you should create a folder and place your sample encodings in this folder. 

For example, `mei-Shakuhachi.xml` would test validation against files contained in the `tests/Shakuhachi` folder.

## Commit Messages

Adapted from the [Cappuccino Coding Guidelines](https://raw.githubusercontent.com/cappuccino/cappuccino/master/CONTRIBUTING.md).

Commit messages are easy to dismiss as trivial and unimportant, but they are vital to our review process. Commit messages should be structured to help reviewers know the impact, scope, and extent of a proposed change so that they can understand if a commit is making an unintended change to the schema.

To this end, commit messages should be structured as short e-mail messages. The message summary is one of the most important parts of the commit message, because that is what we see when scanning through a list of commits, and it is also what we use to generate change logs.

Commit messages should be in the following format:

    <summary>

    <body>

    <footer>

### Message Summary

The summary should be a **concise** description of the commit, preferably 72 characters or less (so we can see the entire description in GitHub), beginning with a lowercase letter and with a terminating period. It should describe only the core issue addressed by the commit. If you find that the summary needs to be very long, your commit is probably too big! Smaller commits are better.

Do **not** simply reference another issue or pull request by number in the summary. First of all, we want to know what was actually changed and why, which may not be fully explained in the referenced issue. Second, github will not create a link to the referenced issue in the commit summary.

### Message Body

The details of the commit go in the body. Specifically, the body should include the motivation for the change.  For commits that fix bugs you should contrast behavior before the commit with behavior after the commit.

### Message Summary

If the commit closes an issue by fixing the bug, implementing a feature, or rendering it obsolete, or if it references an issue without closing it, that should be indicated in the message footer.

Issues closed by a commit should be listed on a separate line in the footer with an appropriate prefix:

- "Fixes" for commits that fix issues.
- "Refs" for commits that reference or are related to issues or other pull requests.

### (Silly) Examples

    Added a duration attribute to clefs

    This change adds an @dur attribute to the <clef> object. This is to allow the use of
    the clef object as a pitched and timed object.

    Closes #1234

***

    New tests for the MEI Aleatoric Music customization

    This commit adds some test files to test the MEI Aleatoric customization. Specifically, we have added encoded excerpts of Cage's 4'33".

    Refs #4567

If your commit messages do not contain enough information for a reviewer to understand what you are trying to do, you **will** be asked to withdraw your commit and re-submit your changes.

## Responsibilities of Core Contributors

Core contributors (i.e., those with commit access to the MEI schema) are responsible for maintaining and reviewing contributions to the schema. In general, there are four classes of contributions that core contributors need to deal with:

 1. Typos (i.e., Mistakes that affect the documentation, but not the schema).
 2. Bug fixes (i.e., Undesired behaviour of the schema)
 3. Contributions to the schema that do not break backwards compatibility
 3. Contributions to the schema that break backwards compatibility

Each of these comes with varying requirements for review and testing. While core contributors *can* commit directly to the develop branch, they should reserve this ability for all but the most trivial of changes (e.g., typos).

For *all other types of contributions*, core contributors should file a pull request containing their proposed changes. This pull request will be reviewed by at least one other core contributor for inclusion. Merging the contribution is the responsibility of the reviewing contributor.

Above all, however, core contributors are asked to exercise wisdom and common sense in merging contributions. If they are unsure of the impact of a proposed change, or the documentation of the contribution (pull request messages, commit messages, discussions) are not answered to their satisfaction, they should err on the side of caution and not merge until they are completely satisfied, or call in help from other members of the community.

### Working with Pull Requests Locally

Sometimes it's easiest if you can check out a pull request's changes locally and run it on your own machine. To do this, you can follow [these instructions](https://gist.github.com/piscisaureus/3342247). This will allow you to further test proposed modifications.

### TravisCI

When a new pull request comes in, the TravisCI service will automatically build the schema using the TEIC Stylesheets, and then validate the test files and the sample encodings against the built schemas. If, for some reason, a change breaks the schema build, or breaks validation, TravisCI will report an error on the pull request. It is then up to the original contributor to fix the issue and submit the fix to the pull request.

### Tests

Unit tests should be small, discrete test to verify that one specific component of the schema passes validation. It could be built to test that an attribute only accepts certain values, or it could be built to verify a larger MEI excerpt, such as a certain type of header.

Testing in MEI is done through the `build.sh` script. This script will look through folders in the `tests` directory that match a given schema customization's name, and then test the schema against all the files contained in that folder. You can invoke the testing by running `./build.sh test`. You may need to customize the values in this file to point to your local copies of the TEI Stylesheets, etc.

# Release Process

Releases are declared by the MEI Board, in consultation with, and on the advice of, the MEI Technical Team.

The most recent 'stable' version of MEI is always found on the 'master' branch. This is where all releases are tagged from, and where all development gets merged into once they have been declared stable. The most recent 'work in progress' is found on the the 'develop' branch. This represents the changes that will eventually find their way into the next release.

Releases are 'tagged' on the master branch when declared. This tag points to a specific commit that represents the state of development at a given point in time.

## Versioning

The MEI Versions follow the ['semantic' versioning scheme](http://semver.org), 'X.Y.Z'. 'X' is a major release, often defined by the presence of backwards-incompatible changes to the schema. 'Y' is a minor release, defined by backwards compatible changes (i.e., added, but not removed, features). 'Z' is the 'patch' number, indicating a release that  fixes or clarifies existing functionality.
