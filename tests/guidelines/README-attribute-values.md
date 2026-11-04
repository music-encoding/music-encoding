# Pure ODD attribute-value regression tests

From the repository root, with the normal build dependencies installed:

```sh
python3 tests/guidelines/test_attribute_values.py
```

The runner uses `JAVA_HOME/bin/java` when available, otherwise `java` on `PATH`.
Use `--java /path/to/java` or `--classpath ...` to override its defaults.

The fixture exercises the actual attribute renderer, inherited attributes, and
website link rewriting. Coverage includes named datatype links, XML Schema
types, regular expressions, numeric/length restrictions, bounded/unbounded
occurrences, repeated sequences, alternatives, closed/semi-open value lists,
and deletion placeholders. Unsupported constructs, legacy RELAX NG forms,
missing definitions, and invalid bounds must produce visible descriptions and
diagnostics instead of empty value spans or transformation failures.

For manual inspection after a full guidelines transformation, start with:

- `attribute-classes/att.accidental.html` and `elements/note.html`: `@accid`
  should have the same explanation and link to `data.ACCIDENTAL.WRITTEN`.
- `attribute-classes/att.curvature.html`: `@bezier` describes repeated pairs of
  decimal values; `@bulge` describes repeated decimal/`data.PERCENT` pairs.
- `attribute-classes/att.lineRend.base.html`: `@lsegs` describes one or two
  positive integers, each greater than or equal to 2.
- `attribute-classes/att.fTrem.vis.html`: `@beams` retains both the minimum and
  maximum restrictions (1 and 6).

The change is Pure ODD-only and is based on the datatype-page fix in #1877.
The content-model fixes and the datatype Used By/declaration-link stages are
separate work. Some customization overrides still use RELAX NG; these will
produce explicit unsupported-form descriptions until their sources migrate.
