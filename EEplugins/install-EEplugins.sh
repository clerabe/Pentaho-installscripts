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

echo "installing EE plugins"

PLUGINDIR=${BASEDIR}/plugins
EEINSTSUFFIX="-dist.zip"

INSTALL_SERVERDIR=${PENTAHO_SYSTEM}/kettle/plugins
INSTALL_PDIDIR=${PDI_HOME}/plugins

install_plugin() {
  WD=$1

  if [ -d ${WD} ]; then
    cd ${WD}

    unzip -q $(ls *${EEINSTSUFFIX})

    plugin=$(find * -type d | head -1)

    if [ -d "${plugin}" ]; then
      cd ${plugin}
      
      instjar=./installer.jar

      if [ -f ${instjar} ]; then
        if [ -d ${INSTALL_SERVERDIR} ]; then
          echo "--- installing $plugin in ${INSTALL_SERVERDIR} ---"
          java -DINSTALL_PATH=${INSTALL_SERVERDIR} -DEULA_ACCEPT=true -jar ${instjar} -options-system
          echo "---\n"
        fi

        if [ -d ${INSTALL_PDIDIR} ]; then
          echo "--- installing $plugin in ${INSTALL_PDIDIR} ---"
          java -DINSTALL_PATH=${INSTALL_PDIDIR} -DEULA_ACCEPT=true -jar ${instjar} -options-system
          echo "---\n"
        fi
      else
        warning "no installer (${instjar}) found; skipping installation\n$"
      fi
    else
      warning "no installer directory ${plugininst} found; skipping installation\n"
    fi
  else
    error "workdir $WDs does not exist"
    exit 1
  fi
}

if [ -d ${PLUGINDIR} ]; then
  WORKDIR=${BASEDIR}/work.$$

  for plugin in $(ls ${PLUGINDIR}/*${EEINSTSUFFIX}); do
    mkdir -p ${WORKDIR}

    cp ${plugin} ${WORKDIR}

    install_plugin ${WORKDIR}

    rm -rf ${WORKDIR}
  done
else
  error "Plugin directory (${PLUGINDIR}) not found"
fi
