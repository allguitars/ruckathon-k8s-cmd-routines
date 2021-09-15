# Function arg $1: Start Time
cal_time_passed() {
    NOW=$(date +%s)
    ((TIME_PASSED = NOW - $1))

    echo $TIME_PASSED
}

# Command arg $1: Time Limit
TIME_LIMIT=$1
START=$(date +%s)

while [[ $(cal_time_passed $START) -lt $TIME_LIMIT ]]; do
    echo $(date +%s)
    sleep 1
done
