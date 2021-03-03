# The Music Encoding Initiative

| Branch        | Continuous Integration Status  |
| ------------- |:------------------------------:|
| Develop       |![Deploy Schema and Guidelines](https://github.com/music-encoding/music-encoding/workflows/Deploy%20Schema%20and%20Guidelines/badge.svg?branch=develop) |
| Master | [![Build Status](https://travis-ci.org/music-encoding/music-encoding.svg?branch=master)](https://travis-ci.org/music-encoding/music-encoding) |

The Music Encoding Initiative (MEI) is an open-source effort to define a system for encoding musical documents in a machine-readable structure. MEI brings together specialists from various music research communities, including technologists, librarians, historians, and theorists in a common effort to define best practices for representing a broad range of musical documents and structures. The results of these discussions are formalized in the MEI schema, a core set of rules for recording physical and intellectual characteristics of music notation documents expressed as an eXtensible Markup Language (XML) schema. It is complemented by the MEI Guidelines, which provide detailed explanations of the components of the MEI model and best practices suggestions.

# Structure of this repository

This repository contains all the source code of the MEI Schema and Guidelines:

 * .github: Configuration files for Github Actions workflows.
 * customizations: TEI ODD files that allow you to build customized MEI schemata.
 * source: Contains the source code, as expressed in TEI ODD. This includes the source code for the MEI Guidelines, and the MEI schema modules.
 * submodules: A container for Git Submodules, that is third party developments that are needed for e.g. building this repository's contents, but not part of our codebase.
 * tests: Unit tests for the MEI Schemata.
 * utils: Helper scripts e.g. for compiling schemata and guidelines from this repository.

**!ATTENTION!**

The prebuild schema files no longer exist in this repository, since reintegrating the guidelines and configuring a continuous integration workflow the build artifacts of this repository (Schemata and Guidelines) are being generated on every commit to the develop branch and automatically pushed to separate repositories:

* Schema: https://github.com/music-encoding/schema
* Guidelines: https://github.com/music-encoding/guidelines

In addition, samples of MEI-encoded files are available in the [sample-encodings](https://github.com/music-encoding/sample-encodings) project, and tools for working with and converting to and from other formats and MEI are available in the [encoding-tools](https://github.com/music-encoding/encoding-tools) project.  

# Validating MEI files against an MEI Schema

One of the core strengths of the MEI Schema is that it allows an individual to validate an MEI file against an XML Schema to ensure the MEI file conforms to expected encodings and behaviours. To validate an MEI file you need XML validator software. XML Authoring tools, such as [oXygen](http://www.oxygenxml.com) has built-in validation tools. There are also several command-line utilities, including [xmllint](http://xmlsoft.org/xmllint.html) and [jing](http://www.thaiopensource.com/relaxng/jing.html).

For example, you might validate an MEI file from the the ['sample-encodings'](https://github.com/music-encoding/sample-encodings/) project using xmllint:

    $> xmllint --noout --relaxng schemata/mei-CMN.rng "sample-encodings/MEI 3.0/Music/Complete\ examples/Bach_Ein_festeBurg.mei"

    sample-encodings/MEI 3.0/Music/Complete examples/Bach_Ein_festeBurg.mei validates

Or, the same command using `jing`. 

    $> jing schemata/mei-CMN.rng "sample-encodings/MEI 3.0/Music/Complete\ examples/Bach_Ein_festeBurg.mei"

# Customizing MEI

To create your own customization, you should understand the building and customization process. The MEI Schema may be customized to express and validate different types of music documents. These customizations are controlled by customization  By default, MEI includes five customizations:

 * mei-all: The full MEI Schema. This is the most permissive version of MEI.
 * mei-CMN: Validates MEI files that express common Western music notation.
 * mei-Mensural: Validates MEI files that express white Mensural notation (will raise validation errors if elements like "measure" exist in the MEI encoding).
 * mei-Neumes: Validates MEI files that express Neume notation (like Mensural, will raise validation errors if elements that are not part of neume notation exist in an encoding.)

## Why Customizations?

For those who are used to having a single DTD or W3C Schema to validate music notation encodings, the customization process may seem to be a complex way of arriving at a schema to validate music notation. However, customizations are a vital part of the expressive power of MEI, and when used to their full extent, can assist organizations in ensuring the integrity and validity of their data.

When designing a music encoding system there are many contradictory and non-standardized practices associated with writing music notation. Different repertoires may have extremely different ways of expressing pitch or rhythm; for example, rhythm in Mensural notation is incompatible with the later systems developed in common Western notation.

Most attempts at addressing this complexity restricts a schema to only a certain subset of music notation, and does not attempt to accurately represent the semantics of music notation that falls outside of its defined scope. So, for example, a system designed for common Western notation that depends on the existence of measures, duration, note shapes, or even staves, cannot semantically represent notations that do not have these features.

The MEI takes a different approach. With the customization system, schemas may be generated from an existing "library" of well-defined musical behaviours, but each behaviour may be mixed and matched according to the needs of the notation. In this sense, the MEI source functions more as a "library" of music encoding tools from which many different types of notation can be expressed, and not just a single monolithic schema.

# Building MEI

The MEI Source is not a schema in itself; rather, it can be used to build customized schemas, such as mei-CMN, mei-Mensural, mei-all, etc. (also see [Customizing MEI](https://github.com/music-encoding/music-encoding#customizing-mei).

Nevertheless it is possible to build any customization locally in your working copy of this repository. In order to do so follow the steps below:

1. Create a recursive clone of this repository

   * If you do not have a clone on your local machine yet run the following from your command line:

     ```bash
     git clone https://github.com/music-encoding.git --recursive
     ```
     
   * If you already have a clone on your system you still might have to initialize the submodules by running the following commands form the command line:

     Switch to your clone's directory:
     ```bash
     cd [YOUR-CLONE-LOCATION]
     ```
     Initialize the submodules:
     ```bash
     git submodules init
     ```
     Update the submodules:
     ```bash
     git submodules update
     ```
2. Check if your system meets the build requisites

   * Is Java 8 or above available on your machine?
   
     ```bash
     java -version
     ```
   
   * Is Apache Ant installed?

     ```bash
     ant -version
     ```
   
2. Initialize the build process

   * Switch to your clone's directory:
   ```bash
   cd [YOUR-CLONE-LOCATION]
   ```
   
   * Call the Apache Ant init task:
   ```bash
   ant init
   ```

4. Run the build process

   * Build guidelines HTML:
   ```bash
   ant -lib lib/saxon/saxon9he.jar build-guidelines-html
   ```

   * Build a specific customization's RNG schema:
   ```bash
   ant -lib lib/saxon/saxon9he.jar -Dcustomization.path=[PATH/TO/YOUR/CUSTOMIZATION] build-rng
   ```

   * Build everything (all customizations shipped with tis repository, compiled ODDs for each customization, guidelines HTML):
   ```bash
   ant -lib lib/saxon/saxon9he.jar
   ```
