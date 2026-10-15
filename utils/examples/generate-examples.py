import argparse
import sys
import pprint
import logging
from pathlib import Path

import verovio

IMAGES_PATH = Path("../../build/assets/images/GeneratedImages")

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

    for mei_file in IMAGES_PATH.glob("*.mei"):
        svg_file = mei_file.with_suffix(".svg")

        if svg_file.exists() and mei_file.exists() and not args.clean:
            log.info("%s already exists, and we're not running in cleaning mode. Skipping.", svg_file.name)
            continue

        # Download the MEI file from the given url
        mei_example: str = mei_file.read_text()

        if not tk.loadData(mei_example):
            log.error("Failed to load %s", mei_file.name)
            success = False
            continue

        svg: str = tk.renderToSVG(1)

        if svg:
            svg_file.write_text(svg)
            log.info("Successfully rendered %s", svg_file.name)
        else:
            log.error("Failed to render %s", mei_file.name)
            success = False

        log.debug("Finished processing %s", mei_file.name)
    
    if not success:
        sys.exit(1)

    sys.exit()
