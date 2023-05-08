# The Music Encoding Initiative

| Branch        | Continuous Integration Status  |
| ------------- |:------------------------------:|
| Develop       |![Deploy Schema and Guidelines](https://github.com/music-encoding/music-encoding/workflows/Deploy%20Schema%20and%20Guidelines/badge.svg?branch=develop)

The Music Encoding Initiative (MEI) is an open-source effort to define a system for encoding musical documents in a machine-readable structure. MEI brings together specialists from various music research communities, including technologists, librarians, historians, and theorists in a common effort to define best practices for representing a broad range of musical documents and structures. The results of these discussions are formalized in the MEI Source and customizations, a core set of rules for recording physical and intellectual characteristics of music notation documents expressed in TEI’s ODD language (One Document Does-it-all, cf. amongst others: Viglianti, 2019). As such, the MEI Source contains both, the specifications that can be compiled to [schema](https://music-encoding.org/schema/) formats for (validating)[#validating-mei-files-against-an-mei-schema] XML files, and documentation in prose, the (MEI Guidelines)[https://music-encoding.org/guidelines], which provide detailed explanations of the components of the MEI model and best practices suggestions.

The MEI Source is not a schema in itself; rather, it can be used to build customized schemas, such as mei-CMN, mei-Mensural, mei-all, etc. (also see [Customizing MEI](#customizing-mei)). This repository already includes several customizations. While these can form an ideal starting point for creating your own customizations, you should also understand (customization)[#customizing-mei] and (building)[#building-mei] processes.

In this document, you will learn how to contribute to the development of MEI by building the schema and guidelines (you should also consider consulting the tutorial on ["Understanding ODD"](https://music-encoding.org/tutorials/understanding-odd.html)). For the pre-built schemas of the latest release of MEI, please consult the ["schemas" section](https://music-encoding.org/resources/schemas.html) of the music-encoding website.

## Structure of this repository

This repository contains all the source code of the MEI Schema and Guidelines:

 * [.github](.github): Configuration files for GitHub Actions workflows.
 * [customizations](customizations): TEI ODD files that allow you to build customized MEI schemata.
 * [source](source): Contains the source code, as expressed in TEI ODD. This includes the source code for the MEI Guidelines and the MEI schema modules.
 * [submodules](submodules): A container for Git Submodules: third-party developments that are needed, e.g., for building this repository's contents, but which are not part of our codebase.
 * [tests](tests): Unit tests for the MEI Schemata.
 * [utils](utils): Helper scripts e.g. for compiling schemata and guidelines from this repository.

**!ATTENTION!**

For the sake of the continuous integration (CI) workflow, the build artifacts of the schemata and guidelines are no longer included in this repository, but are generated on every commit to the develop branch and automatically pushed to their dedicated repositories. For more information please see the section [Additional Resources](#additional-resources) below.

Nevertheless, it is possible to (build)[#building-mei] any customization locally in your working copy of this repository.

## Validating MEI files against an MEI Schema

One of the core strengths of the MEI Schema is that it allows an individual to validate an MEI file against an XML Schema to ensure the MEI file conforms to expected encodings and behaviors. To validate an MEI file you need an XML validation engine. XML Authoring tools, such as [oXygen](http://www.oxygenxml.com), might have built-in validation tools. There are also several command-line utilities, including [xmllint](http://xmlsoft.org/xmllint.html) and [jing](http://www.thaiopensource.com/relaxng/jing.html).

For example, you might validate an MEI file from the the ['sample-encodings'](https://github.com/music-encoding/sample-encodings/) project using xmllint:

   ```shell
   xmllint --noout --relaxng schemata/mei-CMN.rng "sample-encodings/MEI 3.0/Music/Complete\ examples/Bach_Ein_festeBurg.mei"
   ```

Or, the same command using `jing`.

  ```shell
  jing schemata/mei-CMN.rng "sample-encodings/MEI 3.0/Music/Complete\ examples/Bach_Ein_festeBurg.mei"
  ```

## Customizing MEI

The MEI model may be customized to express and validate different types of music documents. Customizations are configured with individual ODD files. This repository already includes several customizations:

* [mei-CMN](customizations/mei-CMN.xml): Validates MEI files that express common Western music notation.
* [mei-Mensural](customizations/mei-Mensural.xml): Validates MEI files that express white Mensural notation (will raise validation errors if elements like "measure" exist in the MEI encoding).
* [mei-Neumes](customizations/mei-Neumes.xml): Validates MEI files that express Neume notation (like Mensural, will raise validation errors if elements that are not part of neume notation exist in an encoding.)
* [mei-all](customizations/mei-all.xml): The full MEI Schema. This is the most permissive customization of MEI.
* [mei-all_anyStart](customizations/mei-all_anyStart.xml): A customization of mei-all, allowing every MEI element as the root element.
* [mei-basic](customizations/mei-basic.xml): The purpose of mei-Basic is to serve as common ground for data interchange, both between projects using different profiles of MEI, and other encoding schemes

### Why Customizations?

For those who are used to having a single DTD or W3C Schema to validate music notation encodings, the customization process may seem to be a complex way of arriving at a schema to validate music notation. However, customizations are a vital part of the expressive power of MEI, and when used to their full extent, can assist organizations in ensuring the integrity and validity of their data.

When designing a music encoding system there are many contradictory and non-standardized practices associated with writing music notation. Different repertoires may have extremely different ways of expressing pitch or rhythm; for example, rhythm in Mensural notation is incompatible with the later systems developed in common Western notation.

Most attempts at addressing this complexity restrict a schema to only a certain subset of music notation and do not attempt to accurately represent the semantics of music notation that falls outside of its defined scope. So, for example, a system designed for common Western notation that depends on the existence of measures, duration, note shapes, or even staves, cannot semantically represent notations that do not have these features.

The MEI takes a different approach. With the customization system, schemas may be generated from an existing ‘library’ of well-defined musical behaviors, but each behavior may be mixed and matched according to the needs of the notation. In this sense, the MEI source functions more as a ‘library’ of music encoding tools by which many different types of notation can be expressed and not just a single monolithic schema.

## Building MEI

Generally, the build process for MEI artifacts is driven by [Apache Ant™](https://ant.apache.org), a Java library and command line tool. Depending on what artifacts you want to build the prerequisites against your operating will increase.

|Artifact                 |Necessary steps Processes                  |Prerequisites                                    |
|-------------------------|-------------------------------------------|-------------------------------------------------|
|Compiled ODD and Schemata|XInclude, XSLT 3.0                         |Saxon HE with Xerces                             |
|Schema                   |XInclude, XSLT 3.0                         |Saxon HE with Xerces                             |
|Guidelines HTML          |XInclude, XSLT 3.0, MEI to SVG             |Saxon HE with Xerces, Verovio Toolkit            |
|Guidelines PDF           |XInclude, XSLT 3.0, MEI to SVG, HTML to PDF|Saxon HE with Xerces, Verovio Toolkit, Prince XML|

Generally, we try to support the building process on the most common operating systems: Microsoft Windows, Apple macOS and Linux. While it is possible to achieve the above steps with other implementations as those listed as ‘Recommended implementations’, we strongly advise

To build all possible artifacts your build system has to meet the following prerequisites:

1. Java (at least Java8 at runtime to support Apache Ant™)
2. Apache Ant (recommended version: 1.10.13)
3. Saxon HE 11.4 (can be fetched by ant project)
4. Synchrosoft patched Xerces 25.1.0.1 (can be fetched by ant project)
5. Verovio Toolkit 3.9
6. Prince XML 15.1

MEI maintains a Docker image that meets all the prerequisites and can be used for building the artifacts via the command line. How to use the Docker image is described in the [README](https://github.com/music-encoding/docker-mei#readme) of the [docker-mei repository](https://github.com/music-encoding/docker-mei).
If your build system meets the above prerequisites you can build the artifacts as documented in [Building MEI on the command line](BUILD_COMMANDLINE.md).
When the command line is not your preferred tool and you do not want to build the Guidelines PDF, you might consider using alternative environments, such as Synchrosoft’s oXygen XML software family. A description of how to set up corresponding transformation scenarios can be found in [Using Oxygen to Build MEI](BUILD_OXYYGEN.md).

## Additional Resources

A live version of the MEI Guidelines is available on the [MEI](https://music-encoding.org) Website](https://music-encoding.org) in the ’Documentation‘ menu:

* [MEI development version](https://music-encoding.org/guidelines/dev)
* [MEI version 4](https://music-encoding.org/guidelines/v4)
* [MEI version 3](https://music-encoding.org/guidelines/v3)

In addition to the source files for MEI in this repository, there are other useful resources in other MEI repositories. The prebuilt release and development versions of:

* MEI Schema files: [https://github.com/music-encoding/schema](https://github.com/music-encoding/schema)
* MEI Guidelines: [https://github.com/music-encoding/guidelines](https://github.com/music-encoding/guidelines)

And moreover

* MEI Sample Encodings: [https://github.com/music-encoding/sample-encodings](https://github.com/music-encoding/sample-encodings)
* MEI Encoding Tools: tools for modifying MEI files and conversion of MEI to/from other encoding formats [https://github.com/music-encoding/encoding-tools](https://github.com/music-encoding/encoding-tools)

## Referenced Material

* Viglianti, R. (2019). One Document Does-it-all (ODD): A language for documentation, schema generation, and customization from the Text Encoding Initiative. Symposium on Markup Vocabulary Customization, Washington, DC. https://doi.org/10.4242/BalisageVol24.Viglianti01
