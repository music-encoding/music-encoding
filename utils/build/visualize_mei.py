import os
import sys
import xml.etree.ElementTree as ET


def parse_xml(file_path):
    tree = ET.parse(file_path)
    root = tree.getroot()
    return root


def load_mei_modules(script_dir, modules_path):
    modules_dir = os.path.join(script_dir, modules_path)
    module_file_paths = get_module_file_paths(modules_dir)
    return parse_xml_files(module_file_paths)


def parse_xml_files(file_paths):
    return [parse_xml(file_path) for file_path in file_paths]


def get_module_file_paths(modules_dir):
    return [os.path.join(modules_dir, file)
            for file in os.listdir(modules_dir) if file.endswith(".xml")]


def find_spec_by_ident(modules, ident):
    spec_types = [
        "moduleSpec",
        "macroSpec",
        "classSpec",
        "elementSpec"
    ]

    for module in modules:
        for spec_type in spec_types:
            for spec in module.findall(f".//{{http://www.tei-c.org/ns/1.0}}{spec_type}"):
                spec_id = spec.get("ident")
                if spec_id == ident:
                    return spec
    return None


def append_graph_member(graph, modules, ident):
    spec = find_spec_by_ident(modules, ident)

    if spec is None:
        not_found_label = f"NotFound: {ident}"
        not_found_node = f"NotFound[{not_found_label}]"
        graph.append(not_found_node)
        print(not_found_label)
        return

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
            append_graph_member(graph, modules, member_of_id)


def generate_mermaid_graph_for_ident(modules, ident):
    graph = ["graph LR"]
    append_graph_member(graph, modules, ident)

    return graph


def write_mermaid_graph_to_file(graph, output_path):
    with open(output_path, "w", encoding="utf-8") as f:
        f.write("```mermaid\n")
        f.write("\n".join(graph))
        f.write("\n```")


def visualize_mei(ident):
    script_dir = os.path.dirname(os.path.abspath(__file__))
    mei_modules = load_mei_modules(script_dir, "../../source/modules")
    mermaid_graph = generate_mermaid_graph_for_ident(mei_modules, ident)

    output_path = os.path.join(script_dir, "visualizations", ident + ".md")
    write_mermaid_graph_to_file(mermaid_graph, output_path)


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python visualize_mei.py <ident>")
        sys.exit(1)
    input_ident = sys.argv[1]
    visualize_mei(input_ident)
