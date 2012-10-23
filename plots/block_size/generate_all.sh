#!/bin/sh

PLOTS="
    distance_calls
    function_execution_time
    function_run_time_complexity
    legend
    total_execution_time
    total_run_time_complexity
    vectors_pruned
"

for PLOT in $PLOTS; do
	OUTPUT="$(dirname $0)/${PLOT}.tex"
	SCRIPT="$(dirname $0)/${OUTPUT}.pl"
    echo "$(basename ${SCRIPT}) --> $(basename ${OUTPUT})"
	perl "$SCRIPT" "$OUTPUT"
done