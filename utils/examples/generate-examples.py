import argparse
import os
import sys
import pprint
import logging

import verovio

IMAGES_PATH = "../../build/assets/images/GeneratedImages"

VRV_OPTIONS: dict = {
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

success: bool = True

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

    log.debug("Running Verovio with the following options: %s", pprint.pformat(VRV_OPTIONS))
    tk.setOptions(VRV_OPTIONS)

    for file in os.listdir(IMAGES_PATH):
        # Skip everything that is not an .mei or .xml file
        if not file.endswith(".mei") and not file.endswith(".xml"): 
            continue

        mei_file = os.path.join(IMAGES_PATH, file)
        svg_file = os.path.join(IMAGES_PATH, f"{file}.svg")

        if os.path.exists(svg_file) and os.path.exists(mei_file) and not args.clean:
            log.info("This example already exists, and we're not running in cleaning mode. Skipping.")
            continue

        # Download the MEI file from the given url
        mei_example: str = ""
        with open(mei_file) as f:
            mei_example = f.read()

        if not tk.loadData(mei_example):
            log.error("Failed to load %s", mei_file)
            success = False
            continue

        svg: str = tk.renderToSVG(1)

        if svg:
            with open(svg_file, 'w') as f:
                f.write(svg)
                log.info("Successfully rendered %s", svg_file)
        else:
            log.error("Failed to render %s", mei_file)
            success = False

        log.debug("Finished processing %s", mei_file)
    
    if not success:
        sys.exit(1)

    sys.exit()
