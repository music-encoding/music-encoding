#!/usr/bin/env python3
"""Run Pure ODD content-model regression checks with the project's Saxon jars.

Usage: python3 tests/guidelines/test_content_models.py [--java /path/to/java]
"""

import argparse
import os
from pathlib import Path
import subprocess
import tempfile
import xml.etree.ElementTree as ET


def main():
    repo = Path(__file__).resolve().parents[2]
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--java", default=str(Path(os.environ["JAVA_HOME"]) / "bin/java")
                        if "JAVA_HOME" in os.environ else "java")
    parser.add_argument("--classpath", default=os.pathsep.join((
        str(repo / "lib/saxon/saxon-he-12.9.jar"), str(repo / "lib/saxon/lib/*"))))
    args = parser.parse_args()
    with tempfile.TemporaryDirectory(prefix="guidelines-content-models-") as tmp:
        output = Path(tmp) / "results.xml"
        subprocess.run([
            args.java, "-cp", args.classpath, "net.sf.saxon.Transform",
            f"-s:{repo / 'tests/guidelines/content-models.xml'}",
            f"-xsl:{repo / 'tests/guidelines/content-models.xsl'}", f"-o:{output}",
        ], check=True, timeout=60)
        results = ET.parse(output)

    cases = {case.get("ident"): case for case in results.findall("case")}

    def children(ident):
        values = [n.get("ident") for n in cases[ident].findall("children/child")]
        assert len(values) == len(set(values)), (ident, values)
        return set(values)

    def facet(ident, name):
        return cases[ident].find(f"website/section/div[@class='facet {name}']")

    def text(node):
        return " ".join("".join(node.itertext()).split())

    def check_tabs(ident, name, target):
        for mode in ("compact", "class", "module"):
            tab = facet(ident, name).find(f".//div[@id='{name}_{mode}']")
            assert tab is not None, (ident, name, mode)
            hrefs = [a.get("href") for a in tab.findall(".//a")]
            assert f"../elements/{target}.html" in hrefs, (ident, name, mode, hrefs)
            if mode != "class":
                assert len(hrefs) == len(set(hrefs)), (ident, name, mode, hrefs)

    assert children("parent") == {"leaf"}  # Not grandchild, disabled, or unavailable.
    assert children("macro.outer") == {"leaf"}  # Nested macro cycle and class diamond.
    assert children("model.base") == {"leaf"}
    assert children("cycleParent") == {"cycleLeaf"}  # Recursive class membership.
    assert children("model.cycleA") == {"cycleLeaf"}
    assert children("inactive") == set()
    check_tabs("parent", "mayContain", "leaf")
    check_tabs("leaf", "containedBy", "parent")
    check_tabs("macro.inner", "containedBy", "parent")
    check_tabs("model.base", "containedBy", "parent")
    check_tabs("cycleParent", "mayContain", "cycleLeaf")
    check_tabs("cycleLeaf", "containedBy", "cycleParent")
    for ident in ("parent", "textOnly", "mixedWildcard"):
        assert "textual content" in text(facet(ident, "mayContain")), ident
        assert "may not have child elements" not in text(facet(ident, "mayContain")), ident
    for ident in ("empty", "inactive"):
        assert "may not have child elements" in text(facet(ident, "mayContain")), ident
    for ident in ("restricted", "mixedWildcard"):
        description = text(facet(ident, "mayContain"))
        assert "Any XML element except" in description, (ident, description)
        assert "urn:excluded, urn:also-excluded" in description, (ident, description)
        assert "self-nested" not in description, (ident, description)
    assert "Any XML element." in text(facet("unrestricted", "mayContain"))
    assert "except" not in text(facet("unrestricted", "mayContain"))
    assert not cases["disabled"].findall("raw/section/div[@class='facet containedBy']//item")
    print("PASS: Pure ODD children, parents, all display modes, cycles, deduplication, text, empty, wildcards, and customization boundaries.")


if __name__ == "__main__":
    main()
