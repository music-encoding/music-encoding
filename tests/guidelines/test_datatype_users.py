#!/usr/bin/env python3
"""Check direct Pure ODD datatype users and their HTML links with Saxon HE."""

import argparse
import os
from pathlib import Path
import subprocess
import tempfile
import xml.etree.ElementTree as ET


def check_compiled_odd(source, results, html_dir):
    """Compare every datatype's users with an independent reference walk."""
    tei = "{http://www.tei-c.org/ns/1.0}"
    examples = "{http://www.tei-c.org/ns/Examples}"
    root = ET.parse(source)
    datatypes = {node.get("ident"): node for node in root.iter(tei + "dataSpec")}
    expected = {ident: set() for ident in datatypes}

    def active_nodes(node):
        if node.get("mode") == "delete" or node.get("maxOccurs") == "0":
            return
        if node.tag in (tei + "desc", tei + "remarks", examples + "egXML"):
            return
        yield node
        for child in node:
            yield from active_nodes(child)

    def refs(containers, tags):
        return {node.get("key") for container in containers for node in active_nodes(container)
                if node.tag in tags and node.get("key") in expected}

    for owner in root.iter():
        ident = owner.get("ident")
        if owner.get("mode") == "delete":
            continue
        if owner.tag == tei + "dataSpec":
            for target in refs(owner.findall(tei + "content"), {tei + "dataRef", tei + "macroRef"}):
                expected[target].add(("datatype", ident, ""))
        elif owner.tag == tei + "elementSpec" or owner.tag == tei + "classSpec" and owner.get("type") == "atts":
            kind = "element" if owner.tag == tei + "elementSpec" else "attclass"
            for att_list in owner.findall(tei + "attList"):
                for attribute in active_nodes(att_list):
                    if attribute.tag == tei + "attDef":
                        for target in refs(attribute.findall(tei + "datatype"), {tei + "dataRef"}):
                            expected[target].add((kind, ident, attribute.get("ident")))

    cases = {case.get("ident"): case for case in results.findall("case")}
    assert set(cases) == set(expected)
    for ident, wanted in expected.items():
        raw = cases[ident].find("raw/section/div")
        actual = [("datatype", item.get("ident"), "") for item in raw.findall(".//item[@class='datatype']")]
        actual += [("attclass", item.get("ident"), item.findtext("link/span").removeprefix("@"))
                   for item in raw.findall(".//item[@class='attclass']")]
        actual += [("element", item.get("ident"), att.get("ident"))
                   for item in raw.findall(".//item[@class='element']") for att in item.findall("item")]
        assert len(actual) == len(set(actual)), (ident, "duplicate raw users")
        assert set(actual) == wanted, (ident, "raw users", set(actual) ^ wanted)

        rendered = []
        for box in cases[ident].findall("website/section/div//div[@class='classBox']"):
            for item in box.findall("div[@class='classContent']/div[@class='def']"):
                label = item.find("span[@class='ident']")
                href = label.find("a").get("href")
                owner = Path(href).stem
                if html_dir:
                    assert (html_dir / "data-types" / href).is_file(), (ident, href)
                if box.get("title") == "Elements":
                    assert href == f"../elements/{owner}.html"
                    rendered += [("element", owner, att.findtext("span[@class='ident attribute']").removeprefix("@"))
                                 for att in item.findall("div[@class='attributeRef']")]
                elif box.get("title") == "Attribute Classes":
                    assert href == f"../attribute-classes/{owner}.html"
                    rendered.append(("attclass", owner, label.findtext("span").removeprefix("@")))
                else:
                    assert box.get("title") == "Data Types"
                    assert href == f"../data-types/{owner}.html"
                    rendered.append(("datatype", owner, ""))
        assert len(rendered) == len(set(rendered)), (ident, "duplicate HTML users")
        assert set(rendered) == wanted, (ident, "HTML users", set(rendered) ^ wanted)
        empty = cases[ident].find("website/section/div//span[@class='emptyStatement']")
        assert (empty is not None) == (not wanted), (ident, "empty state")
    print(f"PASS: {source.name}: all {len(expected)} datatype user lists match an independent reference walk in raw and rendered HTML ({sum(map(len, expected.values()))} direct users).")


def transform(repo, args, source):
    with tempfile.TemporaryDirectory(prefix="guidelines-datatype-users-") as tmp:
        output = Path(tmp) / "results.xml"
        process = subprocess.run([
            args.java, "-cp", args.classpath, "net.sf.saxon.Transform", f"-s:{source}",
            f"-xsl:{repo / 'tests/guidelines/datatype-users.xsl'}", f"-o:{output}",
        ], capture_output=True, text=True, timeout=120)
        assert process.returncode == 0, process.stderr
        return ET.parse(output), process.stderr


def main():
    repo = Path(__file__).resolve().parents[2]
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--java", default=str(Path(os.environ["JAVA_HOME"]) / "bin/java")
                        if "JAVA_HOME" in os.environ else "java")
    parser.add_argument("--classpath", default=os.pathsep.join((
        str(repo / "lib/saxon/saxon-he-12.9.jar"), str(repo / "lib/saxon/lib/*"))))
    parser.add_argument("--compiled-odd", type=Path, help="Also validate every datatype in a compiled ODD")
    parser.add_argument("--html-dir", type=Path, help="Customization HTML root; also check user link targets exist")
    args = parser.parse_args()
    if args.html_dir and not args.compiled_odd:
        parser.error("--html-dir requires --compiled-odd")
    results, diagnostics = transform(repo, args, repo / "tests/guidelines/datatype-users.xml")
    assert "WARNING" not in diagnostics and "ERROR" not in diagnostics, diagnostics

    cases = {case.get("ident"): case for case in results.findall("case")}
    target = cases["data.TARGET"]
    raw = target.find("raw/section/div")
    attributes = raw.findall(".//item[@class='attclass']")
    assert [(item.get("ident"), item.findtext("link/span")) for item in attributes] == [
        ("att.users", "@alpha"), ("att.users", "@zeta")]
    elements = raw.findall(".//item[@class='element']")
    assert [item.get("ident") for item in elements] == ["local"]
    assert [item.get("ident") for item in elements[0].findall("item")] == ["alpha", "beta"]
    assert [item.get("ident") for item in raw.findall(".//item[@class='datatype']")] == [
        "data.BYMACRO", "data.BYREF"]

    website = target.find("website/section/div")
    boxes = website.findall(".//div[@class='classBox']")
    assert [box.get("title") for box in boxes] == ["Elements", "Attribute Classes", "Data Types"]
    assert [a.get("href") for a in website.findall(".//a")] == [
        "../elements/local.html", "../attribute-classes/att.users.html",
        "../attribute-classes/att.users.html", "../data-types/data.BYMACRO.html",
        "../data-types/data.BYREF.html"]
    assert len(website.findall(".//div[@class='attributeRef']")) == 2
    html_text = " ".join("".join(website.itertext()).split())
    for attribute in ("@alpha", "@beta", "@zeta"):
        assert attribute in html_text, html_text
    for invalid in ("@deleted", "@disabled", "@documented", "@builtin", "inheritedOnly", "data.TRANSITIVE"):
        assert invalid not in html_text, (invalid, html_text)

    # A datatype-only user is still a user, and a recursive reference is shown
    # exactly once without attempting transitive traversal.
    assert [item.get("ident") for item in cases["data.BYREF"].findall("raw/section/div//item")] == ["data.TRANSITIVE"]
    assert cases["data.BYREF"].find(".//span[@class='emptyStatement']") is None
    assert [item.get("ident") for item in cases["data.SELF"].findall("raw/section/div//item")] == ["data.SELF"]
    empty = cases["data.EMPTY"].find("website/section/div/div[@class='statement text']/span[@class='emptyStatement']")
    assert empty is not None
    assert "not referenced by any datatype or attribute" in "".join(empty.itertext())
    print("PASS: direct datatype/class/local-attribute users, grouping, labels, links, deduplication, self-references, empty states, and exclusion of examples/deleted/disabled/inherited-only users.")
    if args.compiled_odd:
        results, diagnostics = transform(repo, args, args.compiled_odd.resolve())
        if diagnostics:
            print(diagnostics)
        check_compiled_odd(args.compiled_odd, results, args.html_dir)


if __name__ == "__main__":
    main()
