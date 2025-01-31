import os
import sys
import xml.etree.ElementTree as ET


def parse_xml(file_path):
    tree = ET.parse(file_path)
    root = tree.getroot()
    return root


def find_spec_by_ident(roots, ident):
    spec_types = [
        "moduleSpec",
        "macroSpec",
        "classSpec",
        "elementSpec"
    ]

    for root in roots:
        for spec_type in spec_types:
            for spec in root.findall(f".//{{http://www.tei-c.org/ns/1.0}}{spec_type}"):
                spec_id = spec.get("ident")
                if spec_id == ident:
                    return spec
    return None, None


def generate_mermaid_graph(roots, ident):
    def append_member_of_graph(graph, roots, ident):
        spec = find_spec_by_ident(roots, ident)
        if spec is not None:
            spec_id = spec.get("ident")
            print(f"Processing {spec_id}")

            module_id = spec.get("module")
            spec_node = f'{spec_id}["{spec_id} ({module_id})"]'
            graph.append(spec_node)

            for member_of in spec.findall(".//{http://www.tei-c.org/ns/1.0}memberOf"):
                member_of_id = member_of.get("key")
                member_of_edge = f"{member_of_id} --> {spec_id}"
                graph.append(member_of_edge)

                # Recursively append the graph for the member_of class
                append_member_of_graph(graph, roots, member_of_id)

    graph = ["graph LR"]
    append_member_of_graph(graph, roots, ident)

    # else:
    #    graph.append(f"NotFound[Element: {ident} not found]")

    return "\n".join(graph)


def generate_mermaid_graph_from_xml(ident):
    script_dir = os.path.dirname(os.path.abspath(__file__))
    modules_dir = os.path.join(script_dir, "../../source/modules")
    file_paths = [os.path.join(modules_dir, file)
                  for file in os.listdir(modules_dir) if file.endswith(".xml")]
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
