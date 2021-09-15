# Command args: $1
KEYWORD=$1

# Show all pods containing the keyword
run() {
    CMD_OUTPUT=$(kubectl get pod | grep $KEYWORD | awk '{ printf "%-50s %s\n", $1, $3 }')
    echo "$CMD_OUTPUT"
}

run
