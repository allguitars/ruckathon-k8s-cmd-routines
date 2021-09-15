KEYWORD=$1
CMD_OUTPUT=$(kubectl get pod | grep $KEYWORD | awk '{ printf "%-50s %s\n", $1, $3 }')

# Check if all pods are "Running". Breaks if hitting the first failed test.

echo "$CMD_OUTPUT"

STATUS=false

while IFS= read -r line; do
    if [[ $line == *"Running"* ]]; then
        STATUS=true; continue
    else 
        STATUS=false; break
    fi
done <<< $CMD_OUTPUT


echo $STATUS