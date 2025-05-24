#!/bin/bash

function help() {
    echo -e 'Execute COMMANDS repeatedly until it succeeds (default interval 0s)'
    echo -e 'Usage:'
    echo -e "\t$0 [-h|--help]"
    echo -e "\t$0 [-i|--interval=SECS] [--] \"COMMANDS\""
    echo -e "\t$0 [-i|--interval SECS] [--] \"COMMANDS\""
}

# parse options
options=$(getopt -o hi: -l help,interval: -n "$0" -- "$@")
if [[ -z "$@" || $? -ne 0 ]]; then
    help
    exit 1
fi
eval set -- "$options"

INTERVAL=0
while true; do
    case "$1" in
    -i | --interval)
        shift; # The arg is next in position args
        INTERVAL=$1
        if ! [[ ${INTERVAL} -ge 0 && ${INTERVAL} =~ ^[0-9]+$ ]]; then
            echo "Wrong interval"
            exit 1
        fi
        ;;
    -h | --help)
        help
        exit 1
        ;;
    --)
        shift
        break
        ;;
    esac
    shift
done

# exec commands
CMD="$@"
status=1
ATTEMPTS=0
while [[ ${status} -ne 0 ]]; do
    ((ATTEMPTS += 1))
    timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    echo "---------------- Attempt #${ATTEMPTS} [${timestamp}]"
    echo "Running command: ${CMD}"
    eval "${CMD}"
    status=$?

    if [[ ${status} -ne 0 && ${INTERVAL} -gt 0 ]]; then
        sleep ${INTERVAL}
    fi
done

echo -----
echo "Command \"${CMD}\" succeeded."
echo "Total attempts: ${ATTEMPTS}"
