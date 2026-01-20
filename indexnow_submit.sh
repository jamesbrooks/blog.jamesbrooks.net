#!/bin/bash
set -e

KEY="55d3fb243ad5467e886b2d78026386e8"

LATEST_URL=$(curl -s "https://blog.jamesbrooks.net/sitemap.xml" | \
    tr '\n' ' ' | sed 's/<url>/\n/g' | grep '/posts/' | \
    sed -n 's/.*<loc>\([^<]*\)<\/loc>.*<lastmod>\([^<]*\)<\/lastmod>.*/\2 \1/p' | \
    sort -r | head -1 | awk '{print $2}')

echo "Submitting: $LATEST_URL"
curl -sf "https://api.indexnow.org/indexnow?url=${LATEST_URL}&key=${KEY}" && echo "Done"
