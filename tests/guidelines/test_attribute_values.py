#!/usr/bin/env python3
"""Check Pure ODD attribute descriptions using the project's Saxon HE jars."""

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
    with tempfile.TemporaryDirectory(prefix="guidelines-attribute-values-") as tmp:
        output = Path(tmp) / "results.xml"
        process = subprocess.run([
            args.java, "-cp", args.classpath, "net.sf.saxon.Transform",
            f"-s:{repo / 'tests/guidelines/attribute-values.xml'}",
            f"-xsl:{repo / 'tests/guidelines/attribute-values.xsl'}", f"-o:{output}",
        ], capture_output=True, text=True, timeout=60)
        assert process.returncode == 0, process.stderr
        results = ET.parse(output)

    def text(node):
        return " ".join("".join(node.itertext()).split())

    values = {}
    for case in results.findall("case"):
        values[case.get("ident")] = {
            item.get("ident"): item.find("desc/span[@class='attributeValues']")
            for item in case.findall("raw/section/div//item[@class='attribute']")
        }
    direct = values["att.test"]
    inherited = values["example"]
    assert set(direct) == set(inherited)
    assert "deleted" not in direct
    assert "att.test/deleted:" not in process.stderr
    for ident, value in direct.items():
        assert text(value), ident
        assert text(value) == text(inherited[ident]), ident
    assert direct["named"].find("a").get("href") == "#data.TEST"
    for ident, fragments in {
        "string": ["XML Schema string datatype"],
        "integer": ["XML Schema integer datatype"],
        "pattern": ["matching the regular expression", "[a-g]|unknown"],
        "bounds": ["greater than or equal to 2", "less than or equal to 6"],
        "exclusive": ["greater than 0", "less than 10"],
        "length": ["length at least 2", "length at most 6"],
        "multiple": ["1 or more space-separated values", "data.TEST"],
        "two": ["1 to 2 space-separated values", "greater than or equal to 2"],
        "exact": ["exactly 3 space-separated values"],
        "optional": ["0 to 1 space-separated value"],
        "zeroOrMore": ["0 or more space-separated values"],
        "empty": ["an empty value"],
        "bezier": ["1 or more space-separated sequences", "a sequence of (", "followed by"],
        "bulge": ["1 or more space-separated sequences", "decimal", "followed by data.TEST"],
        "choice": ["one of (", "integer datatype or", "token datatype"],
        "closed": ['Allowed values are: "a" (Alpha.), "b" (Beta.).'],
        "semi": ['Suggested values are: "custom" (Suggested token.).', "1 or more space-separated values", "NMTOKEN"],
    }.items():
        for fragment in fragments:
            assert fragment in text(direct[ident]), (ident, fragment, text(direct[ident]))
        assert direct[ident].find(".//span[@class='datatypeUnsupported']") is None, ident
    assert text(direct["bezier"]).count("XML Schema decimal datatype") == 2
    for ident in ("badConstruct", "legacy", "badFacet", "badBounds", "missing", "noDatatype"):
        assert direct[ident].find(".//span[@class='datatypeUnsupported']") is not None, ident
        assert f"att.test/{ident}:" in process.stderr, process.stderr
    assert "data.MISSING is not available in this customization" in text(direct["missing"])
    assert "Not sure how to resolve" not in process.stderr
    for case in results.findall("case"):
        website = case.find("website")
        hrefs = [a.get("href") for a in website.findall(".//span[@class='attributeValues']//a")]
        assert "../data-types/data.TEST.html" in hrefs
        assert "https://www.w3.org/TR/xmlschema11-2/#integer" in hrefs
        assert all(not href.startswith("#") for href in hrefs)
    print(f"PASS: {len(direct)} attribute descriptions, inheritance, datatype links, restrictions, occurrences, sequences, lists, and unsupported-form diagnostics.")


if __name__ == "__main__":
    main()
