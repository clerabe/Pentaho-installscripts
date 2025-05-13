#!/bin/sh

BASEDIR=$(cd "$(dirname "$0")" && pwd)

if [ -z "$PENTAHO_HOME" ]; then
  SET_PENTAHO_ENV="$BASEDIR/../lib/set_pentaho_env.sh"

  if [ -f $SET_PENTAHO_ENV ]; then
    . $SET_PENTAHO_ENV
  else
    echo "Error: $SET_PENTAHO_ENV not found"
    exit 1
  fi
fi

echo "installing openlineage plugin"

PLUGINDIR=${BASEDIR}/plugins
OPENLINEAGE_ZIP="*openlineage*.zip"

KETTLE_PROPERTIES=~/.kettle/kettle.properties

OPENLINEAGE_DIR=$PENTAHO_HOME/openlineage
OPENLINEAGE_CFG=${OPENLINEAGE_DIR}/config.yml
OPENLINEAGE_OUT=${OPENLINEAGE_DIR}/openlineage.out

INSTALL_SERVERDIR=${PENTAHO_SYSTEM}/kettle/plugins
INSTALL_PDIDIR=${PDI_HOME}/plugins

install_plugin() {
  WD=$1

  if [ -d ${WD} ]; then
    cd ${WD}

    unzip -q $(ls *${OPENLINEAGE_ZIP})

    plugin=$(find * -type d | head -1)

    if [ -d "${plugin}" ]; then
      cd ${plugin}

      instscript=./install.sh

      if [ -x ${instscript} ]; then
        if [ -d ${PENTAHO_SERVER} ]; then
          echo "--- installing $plugin in ${PENTAHO_SERVER} ---"
          (yes | ${instscript} ${PENTAHO_SERVER})
          echo "---\n"
        fi

        if [ -d ${PDI_HOME} ]; then
          echo "--- installing $plugin in ${PDI_HOME} ---"
          (yes | ${instscript} ${PDI_HOME})
          echo "---\n"
        fi
      else
        warning "no installer (${instscript}) found; skipping installation\n"
      fi

    else
      warning "no installer directory ${plugininst} found; skipping installation\n"
    fi
  else
    error "workdir $WDs does not exist"
    exit 1
  fi
}

update_kettle_properties() {
  if [ -f ${KETTLE_PROPERTIES} ]; then
    cp ${KETTLE_PROPERTIES} ${KETTLE_PROPERTIES}.bak$$
    TMPFILE=${KETTLE_PROPERTIES}.tmp$$

    egrep -v '^KETTLE_OPEN_LINEAGE_CONFIG_FILE|^KETTLE_OPEN_LINEAGE_ACTIVE' ${KETTLE_PROPERTIES} >${TMPFILE}
    echo "KETTLE_OPEN_LINEAGE_CONFIG_FILE=${OPENLINEAGE_CFG}" >>${TMPFILE}
    echo "KETTLE_OPEN_LINEAGE_ACTIVE=true" >>${TMPFILE}

    mv ${TMPFILE} ${KETTLE_PROPERTIES}
  else
    warning "no kettle properties file (${KETTLE_PROPERTIES}) found\n"
  fi
}

openlineage_outdir() {
  mkdir -p ${OPENLINEAGE_DIR}

  cat >${OPENLINEAGE_CFG} <<EOF
version: 0.0.1
consumers:
  console:
  file:
    - path: ${OPENLINEAGE_OUT}
  http:
    - name: Marquez
      url: http://localhost:5001
    - name: PDC
      url: https://pdc.example.com
      endpoint: /lineage/api/events
      authenticationParameters:
        endpoint: /keycloak/realms/pdc/protocol/openid-connect/token
        username: admin
        password: Encrypted 2be98afc86af09788a816a3758fc0fc9b
        client_id: pdc-client-in-keycloak
        scope: openid

EOF

}

if [ -d ${PLUGINDIR} ]; then
  WORKDIR=${BASEDIR}/work.$$

  for plugin in $(ls ${PLUGINDIR}/${OPENLINEAGE_ZIP}); do
    mkdir -p ${WORKDIR}

    cp ${plugin} ${WORKDIR}

    install_plugin ${WORKDIR}

    rm -rf ${WORKDIR}
  done
  
  update_kettle_properties

  openlineage_outdir

else
  error "Plugin directory (${PLUGINDIR}) not found"
fi
