#!/bin/sh

# Function args: $1
test_status_running() {
    STATUS=false
    # Check if all pods are "Running". Breaks if hitting the first failed test.
    while IFS= read -r line; do
        if [[ $line == *"Running"* ]]; then
            STATUS=true; continue
        else 
            STATUS=false; break
        fi
    done <<< "$1"

    echo $STATUS  # Return the status
}

# Show all pods containing the keyword
get_pod() {
    echo "$(kubectl get pod | grep $KEYWORD | awk '{ printf "%-50s %s\n", $1, $3 }')"
}

# Function arg $1: Start Time
cal_time_passed() {
    NOW=$(date +%s)
    ((TIME_PASSED = NOW - $1))

    echo $TIME_PASSED
}

### Entry point
clear

# Command args: $1
KEYWORD=$1
TIME_LIMIT=$2

# ----- Keep testing until the status becomes Running, or time runs out -----
i=0
TIME_PASSED=0
START=$(date +%s)

OUTPUT=$(get_pod)
echo -e "\n\n\n\n\n$OUTPUT"

while [[ $(test_status_running "$OUTPUT") == false ]] && [[ $TIME_PASSED -lt $TIME_LIMIT ]]; do   # Still not All Running AND not timed out yet

    TIME_PASSED=$(cal_time_passed $START)
    echo -e "\nTime passed: $TIME_PASSED"

    # Take a rest
    sleep 0.5

    # Get all pods containing the keyword
    OUTPUT=$(get_pod)
    clear
    echo -e "\n\n\n\n\n$OUTPUT"
done

# TIME_PASSED=$(cal_time_passed $START)
echo -e "\nThis run took $(cal_time_passed $START) sec."
