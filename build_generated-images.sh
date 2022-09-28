#!/bin/sh
echo ""
echo "Generating Example Images from MEI"
echo "=================================="
docker run --rm -it -v $(pwd)/build/assets/images/GeneratedImages:/data edirom/staticverovioconverter:latest
# alternatively use following line if you need to emulate thte plattform
#docker run --platform=linux/amd64 --rm -it -v $(pwd)/build/assets/images/GeneratedImages:/data edirom/staticverovioconverter:latest
# in future use edirom/staticverovioconverter:latest

echo "Copy generated images to dist"
echo "============================="
ant copy-generated-images
