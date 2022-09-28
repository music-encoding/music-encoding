#!/bin/sh
echo ""
echo "########################################################################"
echo "# Welcome to the music-encoding testbed for building all MEI artifacts #"
echo "########################################################################"

(exec "./build_ant.sh")

(exec "./build_generated-images.sh")

(exec "./build_prince.sh")
