#!/bin/bash
set -e -u -o pipefail

# Initialize command counter and timestamp
COMMAND_INDEX=0
ISO_TIMESTAMP=$(date -u +"%Y-%m-%dT%H-%M-%SZ")

status() {
    echo
    echo "================================================================================"
    echo "$@"
    echo "================================================================================"
    echo
}

trace() {
    echo "$ $*"
    if [ "${TCPDUMP:-}" ]; then
        COMMAND_INDEX=$((COMMAND_INDEX + 1))
        COMMAND_BASENAME=$(basename $(echo "$*" | awk '{print $1}'))
        TRACE_FILE="/traces/${ISO_TIMESTAMP}-${COMMAND_INDEX}-${COMMAND_BASENAME}"
        mkdir -p /traces
        tcpdump -s 0 -w "${TRACE_FILE}" &
        sleep 0.5
    fi
    eval "$*"
    if [ "${TCPDUMP:-}" ]; then
        sleep 0.5
        kill -TERM %1
        echo "-----Packets captured during $*-----"
        if [[ -s "${TRACE_FILE}" ]]; then
            # tcpdump read can sometimes fail
            tcpdump -r "${TRACE_FILE}" || true
        else
            echo "(no packets captured)"
        fi
        echo '---- end packets ----'
    fi

}


if [ "${RUN_CURL_METADATA:-}" ]; then
    status "Curling metadata service"
    trace time curl --connect-timeout 3 http://169.254.169.254:80 || echo "failed"
fi

status "version check"
trace gcloud version

status "SETUP 1. Log in with gcloud auth **application-default** login"
trace gcloud auth application-default login

if [ -z "${SKIP_FIRST_TEST:-}" ]; then
    status "TEST 1: run auth-test.cjs works but slow"
    trace time node auth-test.cjs
    if [ "${RUN_SLOW_TEST_AGAIN:-}" ]; then
        sleep 1
        status "TEST 1B: run the test again"
        trace time node auth-test.cjs
    fi
else
    status "TEST 1: Skipping first test"
fi

if [ -z "${SKIP_GCLOUD_AUTH_LOGIN:-}" ]; then
    status "SETUP 2: Login in with gcloud auth login"
    trace gcloud auth login
else
    status "SETUP 2: Skipping gcloud auth login (SKIP_GCLOUD_AUTH_LOGIN is set)"
fi

if [ -z "${SKIP_GCLOUD_CONFIG_SET_PROJECT:-}" ]; then
    status "SETUP 4: Set gcloud project"
    trace gcloud config set project ${GCLOUD_PROJECT_ID}
else
    status "SETUP 4: Skipping gcloud config set project (SKIP_GCLOUD_CONFIG_SET_PROJECT is set)"
fi

status "TEST 2: run auth-test.cjs, now fast"
trace time node auth-test.cjs

