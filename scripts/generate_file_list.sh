#!/bin/bash

# Script to generate a list of files and directories

# Verbesserungen:
# list of filetree output to a file
# outputfile name pattern should be filetreelist_(path with - instead of / and maximum depth 3)
# example: filetreelist_home-user-dotfiles
# if the start directory has more than 3 depth, 
# the outputfilename will reflect that with the number of depth
#
# Beispiel 1:
# "filetreelist_home-user-dotfiles-3" 
# enthält den pfad 
# "home/user/dotfiles/folder1/folder2/folder3"
# 
# Beispiel 2:
# /media/custom/folder/depth1
# das file muss nun so benannt werden: 
# filetreelist_media-custom-folder-1.txt
#
# Beispiel 3:
# /media/custom/folder/depth1/depth2/depth3/depth4
# das file muss nun so benannt werden: 
# filetreelist_media-custom-folder-4.txt

# Default output file
output_file="$HOME/file_list.txt"

# Default directory to start from
start_dir="$HOME"

# Function to print usage
print_usage() {
    echo "Usage: $0 [-o output_file] [-d start_directory]"
    echo "  -o: Specify output file (default: $output_file)"
    echo "  -d: Specify start directory (default: $start_dir)"
}

# Parse command line options
while getopts ":o:d:h" opt; do
    case $opt in
        o) output_file="$OPTARG" ;;
        d) start_dir="$OPTARG" ;;
        h) print_usage; exit 0 ;;
        \?) echo "Invalid option: -$OPTARG" >&2; print_usage; exit 1 ;;
    esac
done

# Check if start directory exists
if [ ! -d "$start_dir" ]; then
    echo "Error: Directory $start_dir does not exist." >&2
    exit 1
fi

# Generate file list
echo "Generating file list..."
find "$start_dir" -type d -o -type f > "$output_file"

echo "File list generated at: $output_file"