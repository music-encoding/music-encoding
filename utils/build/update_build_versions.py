"""Update the versions in BUILD_COMMANDLINE.md with the versions from build.properties."""
import re
from typing import Dict

# Global variables for file paths
BUILD_PROPERTIES_FILE = 'build.properties'
BUILD_COMMANDLINE_FILE = 'BUILD_COMMANDLINE.md'


def read_file(file_path: str) -> str:
    """
    Read the contents of the file at the given path and return it as a string.

    Args:
        file_path (str): The path to the file to read.

    Returns:
        (str) The contents of the file as a string.
    """
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            return f.read()
    except FileNotFoundError as e:
        raise FileNotFoundError(f"File not found: {file_path}") from e


def extract_version(properties: str, key: str) -> str:
    """
    Extract the version number from the properties string using the given key.

    Args:
        properties (str): The properties string to search.
        key (str): The key to search for in the properties string.

    Returns:
        (str) The version number as a string.
    """
    match = re.search(rf'{key}=(.*)', properties)
    if match:
        return match.group(1)

    raise ValueError(f"Version for {key} not found in properties file.")


def update_versions_in_markdown(build_md: str, versions: Dict[str, str]) -> str:
    """
    Update the versions in the markdown content.

    Args:
        build_md (str): The markdown content to update.
        versions (Dict[str, str]): The versions to update the markdown content with.

    Returns:
        (str) The updated markdown content.
    """
    replacements = {
        r'\|Prince XML\|.*\|': f"|Prince XML|{versions['prince.version']}|",
        r'\|Saxon HE\*\|.*\|': f"|Saxon HE*|{versions['saxon.version']}|",
        r'\|TEI Stylesheets\*\|.*\|': f"|TEI Stylesheets*|{versions['stylesheets.version']}|",
        r'\|Verovio Toolkit\|.*\|': f"|Verovio Toolkit|{versions['verovio.version']}|",
        r'\|Xerces\*\|.*\|': f"|Xerces*|Synchrosoft patched version {versions['xerces.version']}|"
    }

    for pattern, replacement in replacements.items():
        build_md = re.sub(pattern, replacement, build_md)

    print("Updated versions in BUILD_COMMANDLINE.md:")
    print(versions)

    return build_md


def update_build_versions():
    """
    Update BUILD_COMMANDLINE.md with the versions from build.properties.
    """
    # Read versions from build.properties
    properties = read_file(BUILD_PROPERTIES_FILE)

    keys = [
        'prince.version',
        'saxon.version',
        'stylesheets.version',
        'verovio.version',
        'xerces.version'
    ]

    versions = {key: extract_version(properties, key) for key in keys}

    # Read BUILD_COMMANDLINE.md
    build_md = read_file(BUILD_COMMANDLINE_FILE)

    # Update versions in BUILD_COMMANDLINE.md
    updated_build_md = update_versions_in_markdown(build_md, versions)

    # Write updated BUILD_COMMANDLINE.md
    with open(BUILD_COMMANDLINE_FILE, 'w', encoding='utf-8') as f:
        f.write(updated_build_md)


if __name__ == "__main__":
    update_build_versions()
