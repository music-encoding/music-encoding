# Pure ODD datatype Used By regression tests

Run from the repository root with the normal build dependencies installed:

```sh
python3 tests/guidelines/test_datatype_users.py
```

The runner uses `JAVA_HOME/bin/java` when set, otherwise `java` on `PATH`.
Use `--java /path/to/java` or `--classpath ...` to override the defaults.

The fixture exercises the actual Used By facet and website renderer. It checks
datatype references through both `dataRef/@key` and `macroRef/@key`, class-based
attributes, element-local attributes, duplicate references, nested attribute
lists/sequences, stable ordering, labels, link rewriting, and visible empty
states. Examples, deleted/disabled definitions, and built-in `dataRef/@name`
values must not create spurious users.

Lists describe **direct** references. An inherited attribute is listed under its
defining class, not under every element inheriting it. Likewise, a datatype
indirectly referencing the target through another datatype is not a direct user.
Self-references are listed once; no transitive traversal is needed.

To compare every datatype in a compiled customization against an independent
Python reference walk (raw users and their rendered HTML labels/links):

```sh
python3 tests/guidelines/test_datatype_users.py --compiled-odd dist/schemata/mei-all_compiled.odd
```

Add `--html-dir dist/guidelines/web/mei-all` to verify that user link targets
exist in a previously generated HTML build as well.

For integration validation, compile fresh customization ODDs and build their
HTML guidelines. Suggested pages:

- `data-types/data.ACCIDENTAL.WRITTEN.html`: should list
  `att.accidental/@accid`, `att.ornamentAccid/@accidupper`, and
  `att.ornamentAccid/@accidlower`.
- `data-types/data.MARCRELATORS.basic.html`: should retain `data.RELATORS`.
- `data-types/data.URI.html`: should include local attributes such as
  `handShift/@new` and `handShift/@old` where available in the customization.

`datatype-users.xsl` can also be run directly against a compiled ODD to inspect
the raw and website-rendered Used By sections without invoking the separate
content-model or attribute-value stages. This change depends on datatype-page
PR #1877 but is independent of Stage 2. Legacy embedded RELAX NG datatype
references in customization overrides still need their separate source migration.
