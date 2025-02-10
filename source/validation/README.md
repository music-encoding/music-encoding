# Source Validation

This directory holds schema definitions and schemata for validating `source/mei-source.xml`, the files it refers to wit XIncludes (usually in `docs` and `modules`) and the `customizations`.

## mei_odds

The mei_odds schema is a customized version of the teiodds schema. While the file `mei_odds.odd` holds the definition in TEI ODD there is also `mei_odds.rng` which is a Relax NG schema that can be used for validating. It is already associated with `mei-source.xml` and the files in `docs` and `modules`, both as Relax NG for testing the structural integrity and as Schematron for testing things that can’t be expressed in mere structural tests.

## mei-customizations.sch

The `mei-customizations.sch` Schematron is used to evaluate a customizations integrity. That is: it checks wheter the definitions that are being referred to from the customization file (due to change, deletion or addition) are available from the respective source context.

## mei-source.sch

The `mei-source.sch` Schematron is associated with `mei-source.xml` and adds another layer of proofing encoding consistency in the MEI source files.