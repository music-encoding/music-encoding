# Music Encoding Initiative Contribution Guidelines

This document sets out the methods and practices for contributing to the Music Encoding Initiative.

# Contributors

The Music Encoding Initiative (MEI) schema is developed and maintained by the MEI Technical Team. Membership in this team is open to anyone and everyone who expresses an interest, and has a demonstrated ability to contribute. There are two co-leaders of the Technical Team, who act as administrative representatives to the board and manage the technical infrastructure of the project (e.g., GitHub administrative access).

The co-leaders will designate and appoint senior members of the technical team to act as core contributors. These core contributors will have the ability to commit to the MEI Schema, and whose primary responsibility is to review and triage "pull request" contributions from others.

## How to contribute

We use GitHub as our main development platform. GitHub uses the "Pull Request" mechanism for accepting proposed contributions from the community. A brief overview of this process:

 1. Fork the `music-encoding/music-enc



## Responsibilities of Core Contributors

Core contributors (i.e., those with commit access to the MEI schema) are responsible for maintaining and reviewing contributions to the schema. In general, there are four classes of contributions:

 1. Typos (i.e., Mistakes that affect the documentation, but not the schema).
 2. Bug fixes (i.e., Undesired behaviour of the schema)
 3. Contributions to the schema that do not break backwards compatibility
 3. Contributions to the schema that break backwards compatibility

Each of these comes with varying requirements for review and testing. While core contributors *can* commit directly to the master branch, they should reserve this ability for all but the most trivial of changes (e.g., typos).

For *all other types of contributions*, core contributors should file a pull request containing their proposed changes. This pull request will be reviewed by at least one other core contributor for inclusion. Merging the contribution is the responsibility of the reviewing contributor.

Above all, however, core contributors are asked to exercise discretion in merging contributions. Don't break stuff!

## Checklist for a contribution

Pull requests containing contributions of any significant changes should be accompanied by the following supporting changes:

 1. Changes or additions to the documentation in the guidelines and in the schema
 2. Sample encodings in the 'tests' folder that demonstrate the changes, so that the changes may be validated

### Customizations and Tests

Customizations to the schema should be placed in the `customizations` folder, named as `mei-NAME-[suffix].xml`. Our automated build system, TravisCI, will build all customizations in this folder and ensure there are no problems. It will also run our automated tests to ensure no validation problems.

The naming of the customizations is important. If your customization should be tested against the "CMN" test corpus, you should name your customization `mei-CMN-something.xml`. This will automatically build and test your customization. If, however, your customization requires a unique test set, you should create a folder and place your sample encodings in this folder. 

For example, `mei-Shakuhachi.xml` would test validation against files contained in the `tests/Shakuhachi` folder.