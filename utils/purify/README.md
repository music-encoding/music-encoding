# purify

Scripts to convert MEI ODD sources from RELAX NG content models
(`rng:*`) to "pure ODD" (`classRef`, `elementRef`, `dataRef`,
`alternate`, `sequence`, `dataSpec`, …).

The stylesheets go back to the scripts Lou Burnard used to convert the
TEI P5 sources to pure ODD prior to TEI Release 3.0 (later tidied up by
Syd Bauman). They have since been adapted and extended for MEI.

## Contents

| File             | Purpose                                                                 |
| ---------------- | ----------------------------------------------------------------------- |
| `purify.sh`      | Command line wrapper: purifies one ODD, or every `*.xml` file in a directory |
| `purify-odd.xsl` | Driver: resolves the dependencies of an ODD, applies `purify.xsl` to them and writes a report |
| `purify.xsl`     | The actual conversion from RELAX NG to pure ODD                         |

## Requirements

- Java
- Saxon HE 12.9, expected at `lib/saxon/saxon-he-12.9.jar` in the
  repository
- `git` is optional; it is used to find the repository root. Without
  it, the root is assumed two directories above this one.

## Usage

```
utils/purify/purify.sh [options] ODD|DIR
```

The script can be run from anywhere. The input is either a single ODD
file (e.g. `source/mei-source.xml` or a customization like
`customizations/mei-basic.xml`) or a directory, in which case every
`*.xml` file directly in it is purified on its own.

### Options

| Option                          | Description                                                        | Default                  |
| ------------------------------- | ------------------------------------------------------------------ | ------------------------ |
| `--overwrite`, `--no-overwrite` | Overwrite the files in place, or write them to the output dir      | `--no-overwrite`         |
| `--external`, `--no-external`   | Transform the dependencies as well, not only the ODD itself        | `--no-external`          |
| `-o`, `--output-dir DIR`        | Output dir for `--no-overwrite`; files keep their path relative to the repository | `build/purified` |
| `-s`, `--source FILE`           | Source for a `schemaSpec` without `@source`                        | `source/mei-source.xml`  |
| `-h`, `--help`                  | Show the help                                                      |                          |

### Examples

```sh
# purify a customization, write the result to build/purified/
utils/purify/purify.sh customizations/mei-basic.xml

# purify a customization and all local files it depends on, in place
utils/purify/purify.sh --external --overwrite customizations/mei-basic.xml

# purify the MEI source and its modules into a custom directory
utils/purify/purify.sh --external -o /tmp/pure source/mei-source.xml

# purify every customization
utils/purify/purify.sh customizations
```

The script exits with a non-zero status if purifying any of the ODDs
failed.

## How it works

For each ODD, `purify.sh` runs `purify-odd.xsl` with Saxon. Transformed
files are first written to a temporary staging directory (Saxon cannot
write to a file it has read) and then copied to the destination: the
repository itself with `--overwrite`, the output dir otherwise.

### Resolving dependencies (`purify-odd.xsl`)

Starting from the ODD, the driver follows these references:

- `xi:include/@href` (except `@parse="text"`)
- `moduleRef/@key`, looked up as `moduleSpec` in the source of the
  `schemaSpec` (or in the `moduleRef`'s own `@source`) and the files it
  includes
- `@source` on `elementSpec`, `classSpec`, `macroSpec`, `dataSpec` and
  `specGrpRef`
- `specGrpRef/@target` pointing to another file

The source of a `schemaSpec` (its `@source`, or `--source` if it has
none) is read as **context only**: it provides the `moduleSpec`s and the
other definitions `purify.xsl` needs to look at (e.g. which macros are
datatype macros), but it is not transformed itself. When the ODD is the
`--source` file itself (e.g. `source/mei-source.xml`), `--source` is not
used for its `schemaSpec`.

Only local files inside the repository are written, and only when
purifying actually changes them. Dependencies are only transformed with
`--external`.

### Report

The driver prints one line per file or reference:

| Status        | Meaning                                                              |
| ------------- | -------------------------------------------------------------------- |
| `purified`    | The file was changed and written                                     |
| `unchanged`   | Purifying did not change the file; nothing written                   |
| `skipped`     | A dependency that was not transformed (use `--external`)             |
| `not written` | A local file outside the repository                                  |
| `context`     | Read as context only                                                 |
| `external`    | A reference that could not be followed: remote URLs, `tei:` URIs, `moduleRef/@url`, a `schemaSpec` without source (TEI default), a `moduleRef` without matching `moduleSpec`, missing or not well-formed files |

### The conversion (`purify.xsl`)

`purify.xsl` is an identity transform that changes the following:

- `rng:ref` becomes `classRef` (`model.*`, `att.*`; `model.foo_bar`
  becomes `classRef` with `@expand`), `macroRef` (`macro.*`), `dataRef`
  (`data.*`) or `elementRef` (anything else)
- `rng:choice` becomes `alternate`; literal `rng:value`s of a choice
  become a closed `valList` (without `alternate` if there is nothing
  else)
- `rng:group` with more than one child becomes `sequence`;
  `rng:zeroOrMore`, `rng:oneOrMore`, `rng:optional` become
  `@minOccurs`/`@maxOccurs` (or a `sequence` with several children)
- `rng:interleave` becomes `interleave` for TEI ≥ 4.12.0, otherwise
  `sequence preserveOrder="false"`
- `rng:text` becomes `textNode`, `rng:empty` is dropped, an empty
  `content` gets `empty`, a `content` with several children is wrapped
  in a `sequence`
- the `macro.anyXML` pattern (any element except some namespaces)
  becomes `anyElement` with `@exclude`; `anyElement/@except` is renamed
  to `@exclude`
- datatype macros (`macroSpec[@type="dt"]`) become `dataSpec`, and
  references to them (`macroRef`) become `dataRef`; `@type` on other
  `macroSpec`s is dropped
- inside `datatype`: `rng:ref` and `rng:data` become `dataRef`,
  `rng:param` becomes `dataFacet`, `rng:text` becomes
  `dataRef name="string"`
- lists in datatypes:
  - an `rng:list` with a single (possibly repeated) pattern is
    expressed by `@minOccurs`/`@maxOccurs` on `datatype`
  - any other list, or a choice of datatypes, gets a generated
    `dataSpec` named `data.<ATTRIBUTE>`, placed right after the
    `classSpec`/`elementSpec` the attribute belongs to
  - a list inside a datatype macro (e.g.
    `data.PART = "all" | "none" | list { data.URI+ }`) keeps only its
    item; the repetition moves to every `datatype` using the macro
- `constraintSpec/@scheme` becomes `schematron`
- `exemplum` is copied unchanged
- `moduleRef[@url]` (inclusion of an external RELAX NG schema) is
  copied unchanged, including its `content` (e.g. an `rng:define`
  combining into an ODD class), which is RELAX NG by design

`content` with RELAX NG constructs that cannot be expressed in pure
ODD (`rng:anyName`, `rng:attribute`, `rng:element`, `rng:except`,
`rng:name`, `rng:nsName`, `rng:value` outside a choice, lists that
cannot be lifted) is copied unchanged for manual treatment.

### Manual follow-up

Wherever something needs to be checked or fixed by hand, `purify.xsl`
reports a message starting with `PUREODD:` on the console and inserts
both a `<!-- PUREODD: … -->` comment and a `<?PUREODD …?>` processing
instruction into the output. Search the output for `PUREODD` to find
them, e.g. generated `dataSpec`s whose ident and description should be
reviewed, or clashing idents.

### Stylesheet parameters

`purify.xsl` has parameters that `purify.sh` does not expose; to change
them, run Saxon directly (see the header of `purify-odd.xsl`) or edit
their defaults:

| Parameter            | Description                                                   | Default  |
| -------------------- | ------------------------------------------------------------- | -------- |
| `target-tei-version` | TEI version to target (decides on `interleave`)               | `4.12.0` |
| `schema-prefix`      | Prefix for the keys of `dataRef`s generated inside `datatype` | empty    |
| `debug`              | Also flag every inferred `sequence` for inspection            | `false`  |

`purify.xsl` can also be applied on its own to a single file. It then
looks at all `*.xml` files next to that file to find the datatype
macros; `purify-odd.xsl` replaces this with the resolved dependencies.
