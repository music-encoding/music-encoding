# The Music Encoding Initiative

[![Build Status](https://travis-ci.org/music-encoding/music-encoding.svg?branch=develop)](https://travis-ci.org/music-encoding/music-encoding)

The Music Encoding Initiative (MEI) is an open-source effort to define a system for encoding musical documents in a machine-readable structure. MEI brings together specialists from various music research communities, including technologists, librarians, historians, and theorists in a common effort to define best practices for representing a broad range of musical documents and structures. The results of these discussions are formalized in the MEI schema, a core set of rules for recording physical and intellectual characteristics of music notation documents expressed as an eXtensible Markup Language (XML) schema. It is complemented by the MEI Guidelines, which provide detailed explanations of the components of the MEI model and best practices suggestions.

# Validating MEI files against an MEI Schema

One of the core strengths of the MEI Schema is that it allows an individual to validate an MEI file against an XML Schema to ensure the MEI file conforms to expected encodings and behaviours. To validate an MEI file you need XML validator software. XML Authoring tools, such as [oXygen](http://www.oxygenxml.com) has built-in validation tools. There are also several command-line utilities, including [xmllint](http://xmlsoft.org/xmllint.html) and [jing](http://www.thaiopensource.com/relaxng/jing.html).

For example, you might validate an MEI file from the the ['sample-encodings'](https://github.com/music-encoding/sample-encodings/) project using xmllint:

    $> xmllint --noout --relaxng schemata/mei-CMN.rng "sample-encodings/MEI 3.0/Music/Complete\ examples/Bach_Ein_festeBurg.mei"

    sample-encodings/MEI 3.0/Music/Complete examples/Bach_Ein_festeBurg.mei validates

Or, the same command using `jing`. 

    $> jing schemata/mei-CMN.rng "sample-encodings/MEI 3.0/Music/Complete\ examples/Bach_Ein_festeBurg.mei"

# Structure of the MEI Source Repository

This repository contains all the source code of the core MEI Schema. This includes:

 * customizations: TEI ODD files that allow you to build customized MEI schemas.
 * schemata: pre-built MEI schemas
 * source: Contains the source code to the MEI schema, expressed in TEI ODD. This includes the source code for the MEI Guidelines, and MEI Core.
 * tests: Unit tests for the MEI Schemas

In addition, samples of MEI-encoded files are available in the [sample-encodings](https://github.com/music-encoding/sample-encodings) project, and tools for working with and converting to and from other formats and MEI are available in the [encoding-tools](https://github.com/music-encoding/encoding-tools) project.  

# Building MEI

The MEI Source is not a schema in itself; rather, it can be used to build customized schemas. To create your own customization, you should understand the building and customization process.

## Customizing MEI

The MEI Schema may be customized to express and validate different types of music documents. These customizations are controlled by customization  By default, MEI includes five customizations:

 * mei-all: The full MEI Schema. This is the most permissive version of MEI.
 * mei-CMN: Validates MEI files that express common Western music notation.
 * mei-Mensural: Validates MEI files that express white Mensural notation (will raise validation errors if elements like "measure" exist in the MEI encoding).
 * mei-Neumes: Validates MEI files that express Neume notation (like Mensural, will raise validation errors if elements that are not part of neume notation exist in an encoding.)

## Why Customizations?

For those who are used to having a single DTD or W3C Schema to validate music notation encodings, the customization process may seem to be a complex way of arriving at a schema to validate music notation. However, customizations are a vital part of the expressive power of MEI, and when used to their full extent, can assist organizations in ensuring the integrity and validity of their data.

When designing a music encoding system there are many contradictory and non-standardized practices associated with writing music notation. Different repertoires may have extremely different ways of expressing pitch or rhythm; for example, rhythm in Mensural notation is incompatible with the later systems developed in common Western notation.

Most attempts at addressing this complexity restricts a schema to only a certain subset of music notation, and does not attempt to accurately represent the semantics of music notation that falls outside of its defined scope. So, for example, a system designed for common Western notation that depends on the existence of measures, duration, note shapes, or even staves, cannot semantically represent notations that do not have these features.

The MEI takes a different approach. With the customization system, schemas may be generated from an existing "library" of well-defined musical behaviours, but each behaviour may be mixed and matched according to the needs of the notation. In this sense, the MEI source functions more as a "library" of music encoding tools from which many different types of notation can be expressed, and not just a single monolithic schema.

## Building MEI Schemas

Building MEI requires the [TEI Stylesheets](https://github.com/TEIC/Stylesheets/). You should clone their git repository, or download them in a packaged zip file.

To build the CMN customization, for example, you can use the `teitorelaxng` command in the TEI Stylesheets. Let's assume that your stylesheets are in /opt/TEI, and your MEI source is in /opt/MEI:

    $> /opt/TEI/bin/teitorelaxng --localsource=/opt/MEI/source/mei-source.xml /opt/MEI/customizations/mei-CMN.xml mei-cmn.rng

This will generate a RelaxNG schema called `mei-cmn.rng` for the CMN Customization, which can then be used to validate CMN-encoded MEI files.
