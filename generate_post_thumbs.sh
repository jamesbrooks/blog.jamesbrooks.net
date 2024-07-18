#!/bin/bash

# BG_COLOR=$(magick $1 -resize 1200x -gravity South -crop 1x10+0+0 -format '%[pixel:p{0,0}]' info:-)

# magick $1 -filter Lanczos -resize 1200x -sharpen 0x1.0 -gravity North -crop 1200x630+0+0 +repage \
#     \( -size 1200x315 gradient:none-$BG_COLOR -append \
#        -size 1200x315 xc:$BG_COLOR \) \
#     -gravity South -compose Over -composite $(echo $1 | sed 's/\(.*\)\.\(.*\)/\1_output.\2/')



#!/bin/bash


# Function to process files
process_file() {
  echo "Processing file: $1"

  # set variable of output filename
  OUTPUT_FILE=$(echo $1 | sed 's/_orig//')

  # skip if the output file already exists
  if [[ -f "$OUTPUT_FILE" ]]; then
    echo "Output file already exists: $OUTPUT_FILE"
    return
  fi

  BG_COLOR=$(magick $1 -resize 1200x -gravity South -crop 1x10+0+0 -format '%[pixel:p{0,0}]' info:-)

  magick $1 -filter Lanczos -resize 1200x -sharpen 0x1.0 -gravity North -crop 1200x630+0+0 +repage \
    \( -size 1200x315 gradient:none-$BG_COLOR -append \
       -size 1200x315 xc:$BG_COLOR \) \
    -gravity South -compose Over -composite $OUTPUT_FILE

}

# Recursive function to traverse directories
traverse_dir() {
    local dir="$1"
    local file
    for file in "$dir"/*; do
        if [[ -d "$file" ]]; then
            traverse_dir "$file"
        elif [[ -f "$file" ]]; then
            # Check if the file is named thumb_orig.png
            if [[ "$(basename "$file")" == "thumb_orig.png" ]]; then
                process_file "$file"
            fi
        fi
    done
}

# Start traversal from the specified directory
traverse_dir "./assets/img/posts"
