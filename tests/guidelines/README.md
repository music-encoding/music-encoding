# Guidelines content-model regression tests

Run from the repository root after installing the usual build dependencies:

```sh
python3 tests/guidelines/test_content_models.py
```

The runner uses `JAVA_HOME/bin/java` when set, otherwise `java` on `PATH`.
Override the executable or Saxon classpath if needed:

```sh
python3 tests/guidelines/test_content_models.py --java /path/to/java
```

The fixture exercises the actual content-model helpers, facet generation, and
HTML display-mode rendering. It checks direct references, class inheritance,
nested macros, cycles, diamond-shaped membership, duplicate suppression,
customization boundaries, disabled branches, textual content, empty content,
and unrestricted/restricted wildcards. This is Pure ODD-only coverage.

Saxon results are written to a temporary directory. The fixture runner does not
build the complete guidelines or test the separate attribute-value, datatype-user,
or declaration-link fixes.

For integration validation, also compile fresh `mei-all` and a smaller
customization such as `mei-basic`, then transform their compiled ODDs with
`utils/guidelines_xslt/odd2html.xsl`. Inspect parent/child relationships in all
three display modes and verify that local links resolve. In particular:

- `title` permits `titlePart` and textual content.
- `titlePart` lists `title` as a parent.
- `macro.anyXML` describes its MEI and SVG namespace exclusions.
- Compact and module views do not repeat a child/parent reached by multiple paths.
- Class views retain the distinct model/macro paths explaining a relationship.
