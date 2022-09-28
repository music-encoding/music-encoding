#!/bin/sh
echo ""
echo "Purging old build artifacts and lib"
echo "==================================="
ant reset
echo "Building MEI Schemata and HTML Guidelines"
echo "========================================="
docker run --rm -it --name mei-ant-worker -v $(PWD):/opt/music-encoding ghcr.io/bwbohl/docker-mei:latest /opt/music-encoding/entrypoint_ant-worker.sh
# in future use ghcr.io/bwbohl/docker-mei:latest ot corresponding repo if moved to music-encoding
# alternatively use following line if you need to emulate thte plattform
#docker run --platform=linux/amd64 --rm -it --name mei-ant-worker -v $(PWD):/opt/music-encoding ghcr.io/bwbohl/docker-mei:latest /opt/music-encoding/entrypoint_ant-worker.sh