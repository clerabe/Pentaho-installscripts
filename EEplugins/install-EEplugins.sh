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

    plugzip=$(ls *${EEINSTSUFFIX})
    plugin=$(basename ${plugzip} ${EEINSTSUFFIX})
    plugininst=${plugin}/installer.jar

    unzip -q ${plugzip}

    if [ -f ${plugininst} ]; then
      if [ -d ${INSTALL_SERVERDIR} ]; then
        echo "\n--- installing $plugin in ${INSTALL_SERVERDIR} ---"
        java -DINSTALL_PATH=${INSTALL_SERVERDIR} -DEULA_ACCEPT=true -jar ${plugininst} -options-system
        echo "---"
      fi

      if [ -d ${INSTALL_PDIDIR} ]; then
        echo "\n--- installing $plugin in ${INSTALL_PDIDIR} ---"
        java -DINSTALL_PATH=${INSTALL_PDIDIR} -DEULA_ACCEPT=true -jar ${plugininst} -options-system
        echo "---"
      fi
    else
      echo "WARNING: installer ${plugininst} not found; skipping installation"
    fi
  else
    echo "Error: workdir $WDs does not exist"
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
  echo "Plugin directory (${PLUGINDIR}) not found"
fi
