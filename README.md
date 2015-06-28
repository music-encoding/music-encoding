# The Music Encoding Initiative

The Music Encoding Initiative (MEI) is an open-source effort to define a system for encoding musical documents in a machine-readable structure. MEI brings together specialists from various music research communities, including technologists, librarians, historians, and theorists in a common effort to define best practices for representing a broad range of musical documents and structures. The results of these discussions are formalized in the MEI schema, a core set of rules for recording physical and intellectual characteristics of music notation documents expressed as an eXtensible Markup Language (XML) schema. It is complemented by the MEI Guidelines, which provide detailed explanations of the components of the MEI model and best practices suggestions.

# Validating MEI files against an MEI Schema

One of the core strengths of the MEI Schema is that it allows an individual to validate an MEI file against an XML Schema to ensure the MEI file conforms to expected encodings and behaviours. To validate an MEI file you need XML validator software. XML Authoring tools, such as [oXygen](http://www.oxygenxml.com) has built-in validation tools. There are also several command-line utilities, including [xmllint](http://xmlsoft.org/xmllint.html) and [jing](http://www.thaiopensource.com/relaxng/jing.html).

For example, you might validate an MEI file in the 'samples' directory using xmllint:

    $> xmllint --noout --relaxng schemata/mei-CMN.rng samples/MEI2013/Music/Complete\ examples/Bach_Ein_festeBurg.mei

    samples/MEI2013/Music/Complete examples/Bach_Ein_festeBurg.mei validates

Or, the same command using `jing`. 

    $> jing schemata/mei-CMN.rng samples/MEI2013/Music/Complete\ examples/Bach_Ein_festeBurg.mei

# Structure of the MEI Source Repository

This repository contains all the source code of the core MEI Schema. This includes:

 * customizations: TEI ODD files that allow you to build customized MEI schemas.
 * guidelines: PDF documentation of the MEI Schema
 * schemata: pre-built MEI schemas
 * source: Contains the source code to the MEI schema, expressed in TEI ODD. This includes the source code for the MEI Guidelines, and MEI Core.
 * tests: Unit tests for the MEI Schemas
 * tools: Tools for transforming other formats to and from MEI.

# Building MEI

The MEI Source is not a schema in itself; rather, it can be used to build customized schemas. To create your own customization, you should understand the building and customization process.

## Customizing MEI

The MEI Schema may be customized to express and validate different types of music documents. These customizations are controlled by customization  By default, MEI includes five customizations:

 * mei-all: The full MEI Schema. This is the most permissive version of MEI.
 * mei-CMN: Validates MEI files that express common Western music notation.
 * mei-Mensural: Validates MEI files that express white Mensural notation (will raise validation errors if elements like "measure" exist in the MEI encoding).
 * mei-Neumes: Validates MEI files that express Neume notation (like Mensural, will raise validation errors if elements that are not part of neume notation exist in an encoding.)

## Why Customizations?

The customization process at first seems like a complex way of validating music notation. However, customizations are a vital part of the expressive power of MEI, and when used to their full extent, can assist organizations in ensuring the integrity of their data.

When designing a music encoding system, the designer must attempt to address the sometimes contradictory and non-standardized practices associated with writing music notation. Different repertoires may have extremely different ways of expressing pitch or rhythm; for example, rhythm in Mensural notation is incompatible with the later systems developed in common Western notation.

Customizations will customize the schema, but they will also build custom versions of the documentation and guidelines.

## Building MEI Schemas

Building MEI requires the [TEI Stylesheets](https://github.com/TEIC/Stylesheets/). You should clone their git repository, or download them in a packaged zip file.

To build the CMN customization, for example, you can use the `teitorelaxng` command in the TEI Stylesheets. Let's assume that your stylesheets are in /opt/TEI, and your MEI source is in /opt/MEI:

    $> /opt/TEI/bin/teitorelaxng --localsource=/opt/MEI/source/driver.xml /opt/MEI/customizations/mei-CMN.xml

This will generate a RelaxNG schema for the CMN Customization, which can then be used to validate CMN-encoded MEI files.

