import argparse
import os
import sys
import pprint
from typing import Dict
import logging

import verovio
from lxml import etree

IMAGES_PATH = "../../build/assets/images/GeneratedImages"

MEI_NS: Dict = {'mei': 'http://www.music-encoding.org/ns/mei'}

VRV_OPTIONS: Dict = {
   'scale': 10,
   'pageWidth': 1500,
   'adjustPageHeight': True,
   'adjustPageWidth': True,
   'footer': 'none',
   'header':'none',
   'openControlEvents': True,
   'outputFormatRaw': True,
   'removeIds': True,
   'svgFormatRaw': True,
   'svgHtml5': True,
   'svgRemoveXlink': True,
   'svgViewBox': True,
    'xmlIdSeed': 1
}

if __name__ == "__main__":
    description = """
        Renders SVG for the MEI examples. Will generate any new examples found; to
        re-generate all examples use the '--clean' option.
    """
    parser = argparse.ArgumentParser(description=description)
    parser.add_argument("--clean", action="store_true", help="Re-generate all examples.")
    verbose_group = parser.add_mutually_exclusive_group()
    verbose_group.add_argument("--verbose", "-v", action="store_true")
    verbose_group.add_argument("--debug", "-d", action="store_true")

    args = parser.parse_args()
    if args.debug:
        level_msg: str = "Debug"
        level = logging.DEBUG
    elif args.verbose:
        level_msg: str = "Info"
        level = logging.INFO
    else:
        level_msg: str = "Error"
        level = logging.ERROR

    logging.basicConfig(format="[%(asctime)s] [%(levelname)8s] %(message)s (%(filename)s:%(lineno)s)",
                        level=level)
    log = logging.getLogger(__name__)
    log.info("Running at logging level %s", level_msg)

    verovio.enableLog(verovio.LOG_DEBUG)
    tk = verovio.toolkit()
    # version of the toolkit
    log.info("Using Verovio %s", tk.getVersion())

    # keep all the options to be able to reset them for each example
    defaultOptions: Dict = tk.getDefaultOptions()
    # Overwrite the default options with our locally-defined options
    defaultOptions.update(VRV_OPTIONS)

    # Will remove extraneous whitespace
    et_parser = etree.XMLParser(remove_blank_text=True)

    for file in os.listdir(IMAGES_PATH):
        # Skip everything that is not an .mei or .xml file
        if not(file.endswith(".mei")) and not(file.endswith(".xml")): continue
        
        options: Dict = defaultOptions.copy()

        mei_file = os.path.join(IMAGES_PATH, file)
        svg_file = os.path.join(IMAGES_PATH, f"{file}.svg")

        if os.path.exists(svg_file) and os.path.exists(mei_file) and not args.clean:
            log.info("This example already exists, and we're not running in cleaning mode. Skipping.")
            continue

        # Download the MEI file from the given url
        mei_example: str = ""
        with open(mei_file) as file:
            mei_example = file.read()

        # parse the MEI file to XML
        log.debug("Parsing downloaded text to XML")
        tree = None
        meta = None
        try:
            tree = etree.fromstring(bytes(mei_example.encode("utf-8")), parser=et_parser)
            # try to get the extMeta tag and load the options if existing
            meta = tree.findtext(".//mei:meiHead/mei:extMeta", namespaces=MEI_NS)
        except:
            log.info("Could not parse file")

        # This is currently not used be in-place of having rendering options in <extMeta>
        if meta:
            # Overwrite any pre-defined options with the options from the MEI file.
            log.info("Found some locally-defined meta options: %s", meta)
            metaOptions = meta
            options.update(metaOptions)

        log.debug("Running Verovio with the following options: %s", pprint.pformat(options))
        tk.setOptions(options)
        tk.loadData(mei_example)

        svg: str = tk.renderToSVG(1)

        with open(svg_file, 'w') as f:
            f.write(svg)

        log.debug("Finished processing %s", mei_file)

    sys.exit()
