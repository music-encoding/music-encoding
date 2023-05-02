#!/bin/sh
echo ""
echo "Purging old build artifacts and lib"
echo "==================================="
ant reset
echo "Building MEI Schemata and HTML Guidelines"
echo "========================================="
docker run --rm -it --name mei-ant-worker -v $(PWD):/opt/music-encoding ghcr.io/music-encoding/docker-mei:latest /opt/music-encoding/entrypoint_ant-worker.sh