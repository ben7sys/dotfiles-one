#!/bin/bash

# _template.sh: A template for new scripts

## Enable debug mode if needed
# set -x

## Enable strict mode. (error will cause the script to stop)
set -eo pipefail

# Source the config file always. 
source "$(dirname "$0")/config.sh"

# Functions are in the functions.sh file which is sourced in the config.sh file
# --- START SCRIPT ---
