# Way to pureODD

## Background

MEI 6.0 was built on a codebase that embedded RNG snippets directly. The goal is to migrate the source to **pureODD** — ODD (One Document Does it all, the TEI/MEI schema definition format) used exclusively, without inline RNG. The generated output (compiled schemas, RNG, XSD, etc.) should be identical to what 6.0 produced.

## Versioning Strategy

The transition is expressed in the version number using **SemVer build metadata**:

| Version | Codebase | Output |
|---|---|---|
| `6.0.0` | RNG snippets | baseline |
| `6.0.0+pureODD` | pureODD | identical to `6.0.0` |

### Why build metadata (`+pureODD`)?

- Build metadata signals *how* a version was produced, not *what* it produces — which exactly matches the intent: same output, refactored source.
- Both variants are formally equal in precedence; neither supersedes the other.
- The suffix is visible in filenames, release tags, and changelogs.
- When RNG is eventually retired, publishing simply stops for the un-suffixed variant.

### Coexistence period

`6.0.0` (RNG-based) and `6.0.0+pureODD` will be published in parallel for a transitional period, giving consumers time to verify equivalence and migrate tooling expectations.

### Retirement

Once pureODD is the sole codebase, the `+pureODD` suffix can be dropped. This should be announced explicitly in release notes — e.g. *"from X.0 onward, all releases are pureODD-based; the `+pureODD` suffix is retired."*

## Practical notes

- Git tag names support `+` — `v6.0.0+pureODD` is unambiguous as a tag.
- Package registries (npm, Maven, etc.) may strip or normalize build metadata; for schema files distributed as downloads or git tags this is not a concern.
- Carry the `+pureODD` suffix consistently through the entire coexistence period (e.g. `6.1.0+pureODD`, `6.2.0+pureODD`) until retirement is declared.
