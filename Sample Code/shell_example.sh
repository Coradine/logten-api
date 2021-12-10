#!/bin/bash
#
# A simple shell script to read in a LogTen API package json file, format it, and open
# the LogTen API URL to 'addEntities' contained within the package json.
#
# To use, invoke with the file to be processed:
#
#  % ./shell_example.sh my_flight_data.json
#
# Requires 'jq' https://stedolan.github.io/jq/
# Requires LogTen to be installed.
# Coradine Aviation 2021-12-10
# Sample version 1.0
# From https://is.gd/ltp_api
##

TARGET_FILE=${1:-"example.json"}

# Read in the given JSON file, URI encode it and output it in raw and compacted format
PACKAGE=$(jq -rc '.|@uri' "${TARGET_FILE}")
# Append the processed PACKAGE to the 'addEntities' LogTen API URL
URL="logten://v2/addEntities?package=${PACKAGE}"
# Tell the OS to open the URL (which will launch LogTen appropriately)
open "$URL"
