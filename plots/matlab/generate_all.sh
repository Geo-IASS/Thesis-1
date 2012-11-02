#!/bin/bash

################################################################################
#
# Generate all MATLAB profiling plots from the CSV data file.
#
################################################################################

source $(dirname $0)/common.sh

echo "Generating MATLAB profiling plots..."
for PLOT in $PLOTS; do
    OUTPUT=$(get_output_name $PLOT)
    SCRIPT=$(get_script_name $PLOT)
    echo "$(basename ${SCRIPT}) --> $(basename ${OUTPUT})"
	perl "$SCRIPT" "$OUTPUT" $@
done