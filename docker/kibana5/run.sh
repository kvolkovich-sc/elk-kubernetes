#!/bin/bash

addgroup sudo
adduser -D -g '' kibana
adduser kibana sudo
chown -R kibana /kibana/optimize
echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Run Kibana, using environment variables to set longopts defining Kibana's
# configuration.
#
# eg. Setting the environment variable:
#
#       ELASTICSEARCH_STARTUPTIMEOUT=60
#
# will cause Kibana to be invoked with:
#
#       --elasticsearch.startupTimeout=60

kibana_vars=(
    elasticsearch.customHeaders
    elasticsearch.password
    elasticsearch.pingTimeout
    elasticsearch.preserveHost
    elasticsearch.requestHeadersWhitelist
    elasticsearch.requestTimeout
    elasticsearch.shardTimeout
    elasticsearch.ssl.ca
    elasticsearch.ssl.cert
    elasticsearch.ssl.key
    elasticsearch.ssl.verify
    elasticsearch.startupTimeout
    elasticsearch.url
    elasticsearch.username
    kibana.defaultAppId
    kibana.index
    logging.dest
    logging.quiet
    logging.silent
    logging.verbose
    ops.interval
    pid.file
    server.basePath
    server.host
    server.maxPayloadBytes
    server.name
    server.port
    server.ssl.cert
    server.ssl.key
)

longopts=''
for kibana_var in ${kibana_vars[*]}; do
    # 'elasticsearch.url' -> 'ELASTICSEARCH_URL'
    env_var=$(echo ${kibana_var^^} | tr . _)

    # Indirectly lookup env var values via the name of the var.
    # REF: http://tldp.org/LDP/abs/html/bashver2.html#EX78
    value=${!env_var}
    if [[ -n $value ]]; then
      longopt="--${kibana_var}=${value}"
      longopts+=" ${longopt}"
    fi
done

gosu kibana /kibana/bin/kibana ${longopts} &
PID=$!
trap 'kill -TERM ${PID}' INT TERM
echo "Started Kibana (${PID})"
wait ${PID}
