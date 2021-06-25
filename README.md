# The Music Encoding Initiative

| Branch        | Continuous Integration Status  |
| ------------- |:------------------------------:|
| Develop       |![Deploy Schema and Guidelines](https://github.com/music-encoding/music-encoding/workflows/Deploy%20Schema%20and%20Guidelines/badge.svg?branch=develop)

The Music Encoding Initiative (MEI) is an open-source effort to define a system for encoding musical documents in a machine-readable structure. MEI brings together specialists from various music research communities, including technologists, librarians, historians, and theorists in a common effort to define best practices for representing a broad range of musical documents and structures. The results of these discussions are formalized in the MEI schema, a core set of rules for recording physical and intellectual characteristics of music notation documents expressed as an eXtensible Markup Language (XML) schema. It is complemented by the MEI Guidelines, which provide detailed explanations of the components of the MEI model and best practices suggestions.

In this document, you will learn how to contribute to the development of MEI by building the schema and guidelines (you should also consider consulting the tutorial on ["Understanding ODD"](https://music-encoding.org/tutorials/understanding-odd.html)). For the pre-built schemas of the latest release of MEI, please consult the ["schemas" section](https://music-encoding.org/resources/schemas.html) of the music-encoding website.

# Structure of this repository

This repository contains all the source code of the MEI Schema and Guidelines:

 * [.github](.github): Configuration files for Github Actions workflows.
 * [customizations](customizations): TEI ODD files that allow you to build customized MEI schemata.
 * [source](source): Contains the source code, as expressed in TEI ODD. This includes the source code for the MEI Guidelines, and the MEI schema modules.
 * [submodules](submodules): A container for Git Submodules, that is third party developments that are needed for e.g. building this repository's contents, but not part of our codebase.
 * [tests](tests): Unit tests for the MEI Schemata.
 * [utils](utils): Helper scripts e.g. for compiling schemata and guidelines from this repository.

**!ATTENTION!**

For the sake of the continuous integration (CI) workflow, the build artifacts of the schemata and guidelines are no longer included in this repository, but are generated on every commit to the develop branch and automatically pushed to their dedicated repositories. For more information please see the section [Additional Resources](#additional-resources) below.

# Validating MEI files against an MEI Schema

One of the core strengths of the MEI Schema is that it allows an individual to validate an MEI file against an XML Schema to ensure the MEI file conforms to expected encodings and behaviours. To validate an MEI file you need a XML validation engine. XML Authoring tools, such as [oXygen](http://www.oxygenxml.com), might have built-in validation tools. There are also several command-line utilities, including [xmllint](http://xmlsoft.org/xmllint.html) and [jing](http://www.thaiopensource.com/relaxng/jing.html).

For example, you might validate an MEI file from the the ['sample-encodings'](https://github.com/music-encoding/sample-encodings/) project using xmllint:

    $> xmllint --noout --relaxng schemata/mei-CMN.rng "sample-encodings/MEI 3.0/Music/Complete\ examples/Bach_Ein_festeBurg.mei"

    sample-encodings/MEI 3.0/Music/Complete examples/Bach_Ein_festeBurg.mei validates

Or, the same command using `jing`.

    $> jing schemata/mei-CMN.rng "sample-encodings/MEI 3.0/Music/Complete\ examples/Bach_Ein_festeBurg.mei"

# Customizing MEI

The MEI Schema may be customized to express and validate different types of music documents. To create your own customization, you should understand the building and customization process. Customizations are configured with individual ODD files. This repository already includes several customizations:

 * [mei-CMN](customizations/mei-CMN.xml): Validates MEI files that express common Western music notation.
 * [mei-Mensural](customizations/mei-Mensural.xml): Validates MEI files that express white Mensural notation (will raise validation errors if elements like "measure" exist in the MEI encoding).
 * [mei-Neumes](customizations/mei-Neumes.xml): Validates MEI files that express Neume notation (like Mensural, will raise validation errors if elements that are not part of neume notation exist in an encoding.)
 * [mei-all](customizations/mei-all.xml): The full MEI Schema. This is the most permissive customization of MEI.
 * [mei-all_anyStart](customizations/mei-all_anyStart.xml): A customization of mei-all, allowing every MEI-element as root element.
 * [mei-basic](customizations/mei-basic.xml): The purpose of mei-Basic is to serve as common ground for data interchange, both between projects using different profiles of MEI, and other encoding schemes

## Why Customizations?

For those who are used to having a single DTD or W3C Schema to validate music notation encodings, the customization process may seem to be a complex way of arriving at a schema to validate music notation. However, customizations are a vital part of the expressive power of MEI, and when used to their full extent, can assist organizations in ensuring the integrity and validity of their data.

When designing a music encoding system there are many contradictory and non-standardized practices associated with writing music notation. Different repertoires may have extremely different ways of expressing pitch or rhythm; for example, rhythm in Mensural notation is incompatible with the later systems developed in common Western notation.

Most attempts at addressing this complexity restricts a schema to only a certain subset of music notation, and does not attempt to accurately represent the semantics of music notation that falls outside of its defined scope. So, for example, a system designed for common Western notation that depends on the existence of measures, duration, note shapes, or even staves, cannot semantically represent notations that do not have these features.

The MEI takes a different approach. With the customization system, schemas may be generated from an existing "library" of well-defined musical behaviours, but each behaviour may be mixed and matched according to the needs of the notation. In this sense, the MEI source functions more as a "library" of music encoding tools from which many different types of notation can be expressed, and not just a single monolithic schema.

# Building MEI

The MEI Source is not a schema in itself; rather, it can be used to build customized schemas, such as mei-CMN, mei-Mensural, mei-all, etc. (also see [Customizing MEI](#customizing-mei)).

Nevertheless it is possible to build any customization locally in your working copy of this repository. In order to do so follow the steps below:

1. Create a recursive clone of this repository

  Git offers a mechanism called `submodule` that allows you to reference third party code used in your own project without including the code in your repository. This mechanism is used in the music-encoding repository in order to include the [TEI Stylesheets](https://github.com/TEIC/Stylesheets); these are needed for transforming the ODD files, e.g. to RNG schema files. Cloning a repository including the referenced submodules is referred to as _creating a recursive clone_.

   * If you do not have a clone on your local machine yet run the following from your command line:

     ```bash
     git clone https://github.com/music-encoding/music-encoding.git --recursive
     ```

   * If you already have a clone on your system you still might have to initialize the submodules by running the following commands from the command line:

     Switch to your clone's directory:
     ```bash
     cd [YOUR-CLONE-LOCATION]
     ```
     Initialize the submodules:
     ```bash
     git submodule init
     ```
     Update the submodules:
     ```bash
     git submodule update
     ```
2. Check if your system meets the build requirements

   * Is Java 8 or above available on your machine?

     Java 8 or above is needed for the build process driven by apache Ant (see below).
     To check for Java on your machine, run the following command:

     ```bash
     java -version
     ```

     This should return something similar to

     ```bash
     openjdk version "11.0.9" 2020-10-20
     OpenJDK Runtime Environment (build 11.0.9+11)
     OpenJDK 64-Bit Server VM (build 11.0.9+11, mixed mode)
     ```

     If the version number indicated is lower than `8.0.0` or if the command returns an empty string, please update or install Java according to an installation instruction matching your operating system that (to be found on the internet).

   * Is Apache Ant installed?

     [Apache Ant](https://ant.apache.org/manual/install.html) is a library for building software projects and drives the creation of MEI schemata and guidelines from the ODD sources.
     Run the following command to see if it is available on your system:

     ```bash
     ant -version
     ```

     This should return something similar to:

     ```
     Apache Ant(TM) version 1.10.9 compiled on September 27 2020
     ```

     We recommend using version 1.10.9, being the latest stable release of Apache Ant. If your system has an older version of Apache Ant installed you might still give it a try though. If the prompt returns an empty string, please refer to the [Apache Ant Installation Instructions](https://ant.apache.org/manual/install.html).

3. Initialize the build process

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
     The results of this build can be found in the web folder (`music-encoding/dist/guidelines/dev/web`). The guidelines are stored in the `index.html` file.

   * Build a specific customization's RNG schema:
     ```bash
     ant -lib lib/saxon/saxon9he.jar -Dcustomization.path=[PATH/TO/YOUR/CUSTOMIZATION] build-rng
     ```

   * Build everything (all customizations shipped with this repository, compiled ODDs for each customization, guidelines HTML):
     ```bash
     ant -lib lib/saxon/saxon9he.jar
     ```

## Using Oxygen to Build MEI

### Build a Specific Customization's RNG Schema

If you are not that comfortable with the command line, here we provide an alternative to build MEI by using Oxygen following these steps:

1. Open the customization file in Oxygen (make sure that it has the extension `.odd` and not `.xml`).

2. Click on the _Configure Transformation Scenario(s)_ button (the button with the wrench). This will open a window of the same name.

3. Check the _TEI ODD to RELAX NG XML_ check box.

4. Click on the _Duplicate_ button. This will open the _Edit Ant Scenario_ window.

5. Once in the _Edit Ant Scenario_, assign an appropriate name for the project (e.g., "MEI Mensural Schema - plica feature"). The storage option can be either _Project Options_ or _Global Options_.

6. Change its `defaultSource` parameter by:

   a. Clicking on the _Parameters_ tab.

   b. Locating the `defaultSource` parameter and double-clicking on its value to change it. This will open the _Edit Parameter_ window.

   c. Change the value of the `defaultSource` for the path of the MEI source file (`mei-source.xml`) found on your computer. You can do this by clicking on the folder icon to browse this file (it is located in your local copy of the music-encoding repo, in `music-encoding/source/mei-source.xml`) and opening it. If you are on Windows, make sure that the path starts with the *file* protocol, e.g. `file:/D:/music-encoding/source/mei-source.xml`.

   d. Click on the _OK_ button. The _Edit Parameter_ window will close.

7. Now, you will be back in the _Edit Ant Scenario_ window again. If you are satisfied with your changes, click on the _OK_ button. Otherwise, you could also edit the directory where your schema gets stored by clicking on the _Output_ tab.

8. Now, you will be back in your _Configure Transformation Scenario(s)_ window. In the _Projects_ or _Global_ section of the window based on your choice in step 5, you will find your _new project_ with the name you gave it in step 5. Click on it and then click on the _Applied associated_ button at the left-bottom corner of your window. This will build the schema.

Once the building is done, Oxygen will automatically open the schema. The schema file is also stored in the `music-encoding/customizations/out/` folder if you want to consult it later. You can change the location where the schema generated is saved by clicking on _Output_ in the _Edit Ant Scenario_ window and changing the file path.

### Build Guidelines HTML

In this section, we will use Oxygen to generate the HTML document for the guidelines using the XSLT Stylesheet located at `music-encoding/utils/guidelines_xslt/odd2html.xsl`. The steps are the following:

1. Open the `mei-source.xml` file in Oxygen. This file is located in `music-encoding/source/mei-source.xml`.

2. Click on the _Configure Transformation Scenario(s)_ button (the button with the wrench). This will open a window of the same name.

3. Click on the _New_ button and select the _XML transformation with XSLT_ option. This will open the _New scenario_ window.

4. Assign a name to your new XML transformation.

5. In the _XSLT_ tab, look for the _XSL URL_ field and add the path to your `odd2html.xsl` file. You can do this by clicking on the folder icon to browse this file (it is located in your local copy of the music-encoding repo, in `music-encoding/utils/guidelines_xslt/odd2html.xsl`) and opening it.

6. Now, you will be back in the _New Scenario_ window again. If you are satisfied with your changes, click on the _OK_ button. Otherwise, you could also edit the _XML URL_ field for a particular folder, as well as the _Parameters_ to change the output folder.

7. Now, you will be back in your _Configure Transformation Scenario(s)_ window. In the _Global_ section of the window, you will find your new _XML transformation with XSLT_ with the name you gave it in step 4. Click on it and then click on the _Applied associated_ button at the left-bottom corner of your window. This will generate the HTML document for the guidelines.

After a few minutes, the results of this build can be found in the web folder (`music-encoding/source/web`). The guidelines are stored in the `index.html` file.

# Additional Resources

In addition to the source files for MEI in this repository, there are other useful resources in other repositories. The prebuilt release and development versions of:

* Schemata: https://github.com/music-encoding/schema
* Guidelines: https://github.com/music-encoding/guidelines

And moreover

* MEI sample-encodings: https://github.com/music-encoding/sample-encodings
* Tools for modifying MEI files and conversion of MEI to/from other encoding formats https://github.com/music-encoding/encoding-tools)
