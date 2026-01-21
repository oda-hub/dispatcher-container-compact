ARG PIXI_VERSION=0.63.1
FROM ghcr.io/prefix-dev/pixi:${PIXI_VERSION}-bookworm AS build

ARG FROZEN=yes
ARG DISPATCHER_ENV_VARIANT=default

RUN apt-get update && apt-get install -y git curl gcc

WORKDIR /app
COPY . .

RUN pixi config set --local run-post-link-scripts insecure
RUN if [ "${FROZEN:-yes}" = "yes" ]; then \
    echo "Installing frozen ${DISPATCHER_ENV_VARIANT} environment" ;\
    pixi install --frozen -e ${DISPATCHER_ENV_VARIANT:-default} ;\
  else \
    echo "Installing ${DISPATCHER_ENV_VARIANT} environment unlocked" ;\
    pixi install -e ${DISPATCHER_ENV_VARIANT:-default} ;\
  fi
RUN pixi shell-hook -s bash > shell-hook
RUN sh /app/dummy-data-loader.sh 

FROM debian:bookworm-slim AS runtime

# these will be mounted at runtime
ENV DISPATCHER_CONFIG_FILE=/dispatcher/conf/conf_env.yml
ENV CDCI_OSA_PLUGIN_CONF_FILE=/dispatcher/conf/conf.d/osa_data_server_conf.yml
ENV CDCI_SPIACS_PLUGIN_CONF_FILE=/dispatcher/conf/conf.d/spiacs_data_server_conf.yml 
ENV CDCI_POLAR_PLUGIN_CONF_FILE=/dispatcher/conf/conf.d/polar_data_server_conf.yml
ENV CDCI_NB2W_PLUGIN_CONF_FILE=/dispatcher/conf/conf.d/nb_data_server_conf.yml
# the following are not really used anymore
ENV CDCI_ANTARES_PLUGIN_CONF_FILE=/dispatcher/conf/conf.d/antares_data_server_conf.yml
ENV CDCI_LEGACYSURVEY_PLUGIN_CONF_FILE=/dispatcher/conf/conf.d/legacysurvey_data_server_conf.yml
ENV CDCI_GW_PLUGIN_CONF_FILE=/dispatcher/conf/conf.d/gw_data_server_conf.yml

COPY --from=build /app/.pixi/envs/default /app/.pixi/envs/default
COPY --from=build --chmod=0755 /app/entrypoint.sh /app/entrypoint.sh
COPY --from=build /data/. /data/.

USER 1000
WORKDIR /data/dispatcher_scratch

ENTRYPOINT ["/app/entrypoint.sh"]
