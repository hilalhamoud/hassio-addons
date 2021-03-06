#!/usr/bin/env bashio

CLIENT_JSON=/data/client.json
CRED_JSON=/data/cred.json

CLIENT_SECRETS=$(bashio::config 'client_secrets')
MODEL_ID=$(bashio::config 'model_id')
PROJECT_ID=$(bashio::config 'project_id')

# check if a new assistant file exists
if bashio::fs.file_exists "/share/${CLIENT_SECRETS}"; then
    bashio::log.info "Installing/Updating service client_secrets file"
    cp -f "/share/${CLIENT_SECRETS}" "${CLIENT_JSON}"
fi

if ! bashio::fs.file_exists "${CRED_JSON}" && bashio::fs.file_exists "${CLIENT_JSON}";
then
    bashio::log.info "Starting WebUI for handling OAuth2..."
    python3 /hassio_oauth.py "${CLIENT_JSON}" "${CRED_JSON}"
elif ! bashio::fs.file_exists "${CRED_JSON}"; then
    bashio::exit.nok "You need initialize Google Assistant with a client secret JSON!"
fi

basio::log.info "Starting Hass.io GAssisant SDK..."
exec python3 /hassio_gassistant.py \
    "${CRED_JSON}" "${PROJECT_ID}" "${MODEL_ID}" < /dev/null
