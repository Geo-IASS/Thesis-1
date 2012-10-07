#!/bin/sh
OUTPUT_PDF="$(dirname $0)/../src/thesis.pdf"
if [ -f $OUTPUT_PDF ]; then
    pdftotext $OUTPUT_PDF - | egrep -e '\w\w\w+' | iconv -f ISO-8859-15 -t UTF-8 | wc -w
else
    echo "File not found: $OUTPUT_PDF" >&2
    exit 1
fi
