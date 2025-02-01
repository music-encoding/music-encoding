"""Update the versions in BUILD_COMMANDLINE.md with the versions from build.properties."""
import argparse
import re
from typing import Dict, List

# Global variables
BUILD_PROPERTIES_FILE = 'build.properties'
BUILD_COMMANDLINE_FILE = 'BUILD_COMMANDLINE.md'
DOCKER_FILE = 'Dockerfile'

VERSION_KEYS = [
    'prince.version',
    'saxon.version',
    'schematron.version',
    'stylesheets.version',
    'verovio.version',
    'xerces.version'
]

BUILD_COMMANDLINE_FILE_PATTERNS = {
    r'\|Prince XML\|.*\|': "|Prince XML|{prince.version}|",
    r'\|Saxon HE\*\|.*\|': "|Saxon HE*|{saxon.version}|",
    r'\|TEI Stylesheets\*\|.*\|': "|TEI Stylesheets*|{stylesheets.version}|",
    r'\|Verovio Toolkit\|.*\|': "|Verovio Toolkit|{verovio.version}|",
    r'\|Xerces\*\|.*\|': "|Xerces*|Synchrosoft patched version {xerces.version}|"
}

DOCKER_FILE_PATTERNS = {
    r'ARG PRINCE_VERSION=.*': "ARG PRINCE_VERSION={prince.version}",
    r'ARG SAXON_VERSION=.*': "ARG SAXON_VERSION={saxon.version}",
    r'ARG SCHEMATRON_VERSION=.*': "ARG SCHEMATRON_VERSION={schematron.version}",
    r'ARG XERCES_VERSION=.*': "ARG XERCES_VERSION={xerces.version}"
}


def read_file(file_path: str) -> str:
    """
    Reads the contents of the file at the given path and return it as a string.

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


def write_file(file_path: str, content: str):
    """
    Writes the given content to the specified file.

    Args:
        file_path (str): The path to the file.
        content (str): The content to write.
    """
    try:
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(content)
    except IOError as e:
        raise IOError(f"Error writing to file: {file_path}") from e


def extract_version(properties: str, key: str) -> str:
    """
    Extracts the value of a given key from the properties string.

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


def extract_versions_from_properties_file(file_path: str, keys: List[str]) -> Dict[str, str]:
    """
    Reads and extracts versions from the properties file.

    Args:
        file_path (str): The path to the properties file.
        keys (List[str]): The list of keys to extract versions for.

    Returns:
        (Dict[str, str]) The extracted versions.
    """
    properties = read_file(file_path)
    return {key: extract_version(properties, key) for key in keys}


def replace_versions(content: str, replacements: Dict[str, str]) -> str:
    """
    Replaces a pattern in the given content based on the replacements dictionary.

    Args:
        content (str): The content to update.
        replacements (Dict[str, str]): The patterns and their replacements.

    Returns:
        (str) The updated content.
    """
    for pattern, replacement in replacements.items():
        content = re.sub(pattern, replacement, content)
    return content


def create_replacements(versions: Dict[str, str], patterns: Dict[str, str]) -> Dict[str, str]:
    """
    Creates the replacements dictionary based on the given patterns and versions.

    Args:
        versions (Dict[str, str]): The extracted versions.
        patterns (Dict[str, str]): The patterns to replace.

    Returns:
        (Dict[str, str]) The replacements dictionary.
    """
    def custom_format(replacement: str, versions: Dict[str, str]) -> str:
        """
        Custom format function to replace the keys in the replacement string.
        """
        for key, value in versions.items():
            replacement = replacement.replace(f'{{{key}}}', value)
        return replacement

    return {pattern: custom_format(replacement, versions)
            for pattern, replacement in patterns.items()}


def update_file_versions(file_path: str, patterns: Dict[str, str], versions: Dict[str, str]):
    """
    Updates the versions in the specified file content.

    Args:
        file_path (str): The path to the file to update.
        replacements (Dict[str, str]): The patterns and their replacements.
    """
    content = read_file(file_path)
    replacements = create_replacements(versions, patterns)
    updated_content = replace_versions(content, replacements)
    write_file(file_path, updated_content)


def update_build_versions(update_markdown: bool, update_docker: bool):
    """
    Updates build versions with the versions from build.properties.
    """
    versions = extract_versions_from_properties_file(BUILD_PROPERTIES_FILE, VERSION_KEYS)

    if update_markdown:
        update_file_versions(BUILD_COMMANDLINE_FILE, BUILD_COMMANDLINE_FILE_PATTERNS, versions)

    if update_docker:
        update_file_versions(DOCKER_FILE, DOCKER_FILE_PATTERNS, versions)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Update build versions in markdown and Dockerfile.")
    parser.add_argument('--markdown', action='store_true', help="Update only the markdown file.")
    parser.add_argument('--docker', action='store_true', help="Update only the Dockerfile.")
    args = parser.parse_args()

    should_update_markdown = args.markdown or not args.docker
    should_update_docker = args.docker or not args.markdown

    update_build_versions(should_update_markdown, should_update_docker)
