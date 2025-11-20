#!/bin/bash

echo -e "\033[31mworking in $PWD\033[0m"

if [ -z "$@" ]; then
    if [ ${DISPATCHER_GUNICORN:-no} == "yes" ]; then
        gunicorn \
            "cdci_data_analysis.flask_app.app:conf_app(\"${DISPATCHER_CONFIG_FILE}\")" \
            --bind 0.0.0.0:8000 \
            --workers 8 \
            --preload \
            --timeout 900 \
            --limit-request-line 0 \
            --log-level debug
    else
        run_osa_cdci_server \
            -conf_file ${DISPATCHER_CONFIG_FILE} \
            -debug \
            -use_gunicorn 2>&1
    fi
else
    exec "$@"
fi