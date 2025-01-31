import os
import sys
import xml.etree.ElementTree as ET


def parse_xml(file_path):
    tree = ET.parse(file_path)
    root = tree.getroot()
    return root


def find_spec_by_ident(roots, ident):
    spec_types = [
        ("moduleSpec", "Module"),
        ("macroSpec", "Macro"),
        ("classSpec", "Class"),
        ("elementSpec", "Element")
    ]

    for root in roots:
        for spec_type, label in spec_types:
            for spec in root.findall(f".//{{http://www.tei-c.org/ns/1.0}}{spec_type}"):
                spec_id = spec.get("ident")
                if spec_id == ident:
                    return spec, label
    return None, None


def generate_mermaid_graph(roots, ident):
    graph = ["graph LR"]
    found = False

    spec, label = find_spec_by_ident(roots, ident)

    if spec is not None:
        spec_id = spec.get("ident")
        module_id = spec.get("module")
        graph.append(f"{spec_id}[{label}: {spec_id}] --> {module_id}")
        found = True

        for member_of in spec.findall(".//{http://www.tei-c.org/ns/1.0}memberOf"):
            member_of_id = member_of.get("key")
            graph.append(f"{member_of_id}[Class: {member_of_id}] --> {spec_id}")

            # Look up the member_of_id in all roots
            member_of_spec, member_of_label = find_spec_by_ident(roots, member_of_id)
            if member_of_spec is not None:
                member_of_module_id = member_of_spec.get("module")
                graph.append(
                    f"{member_of_module_id} --> {member_of_id}[{member_of_label}: {member_of_id}]")

    if not found:
        graph.append(f"NotFound[Element: {ident} not found]")

    return "\n".join(graph)


def generate_mermaid_graph_from_xml(ident):
    script_dir = os.path.dirname(os.path.abspath(__file__))
    file_paths = [
        os.path.join(script_dir, "../../source/modules/MEI.cmn.xml"),
        os.path.join(script_dir, "../../source/modules/MEI.shared.xml"),
        os.path.join(script_dir, "../../source/modules/MEI.analytical.xml"),
        os.path.join(script_dir, "../../source/modules/MEI.gestural.xml"),
        os.path.join(script_dir, "../../source/modules/MEI.visual.xml")
    ]
    roots = [parse_xml(file_path) for file_path in file_paths]
    mermaid_graph = generate_mermaid_graph(roots, ident)

    output_path = os.path.join(script_dir, "MEI_cmn_graph.md")
    with open(output_path, "w", encoding="utf-8") as f:
        f.write("```mermaid\n")
        f.write(mermaid_graph)
        f.write("\n```")


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python generate_mermaid.py <ident>")
        sys.exit(1)
    input_ident = sys.argv[1]
    generate_mermaid_graph_from_xml(input_ident)
